import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';
import 'package:whistles_in_the_mist/providers/project_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

const Color _bgDark = Color(0xFF0A0E11);
const Color _brassLight = Color(0xFFE5C07B);
const Color _brassMid = Color(0xFFC29B57);
const Color _brassDark = Color(0xFF7A5C2E);
const Color _wireColor = Color(0xFF8B5A2B);
const Color _pulseColor = Color(0xFF5EE89A);
const Color _ivory = Color(0xFFEDE5D4);

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  final Map<String, _DialNode> _nodes = {};
  final List<_Wire> _wires = [];
  final List<_Pulse> _pulses = [];

  String? _selectedId;
  String? _dragId;
  Offset? _pointerDownPos;
  bool _dragged = false;

  double _clock = 0;
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_step)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _syncNodes(List<SafeworkingInstrumentModel> entries, Size size) {
    if (size == Size.zero) return;
    final center = Offset(size.width / 2, size.height / 2 + 40);

    // Add new nodes
    for (final e in entries) {
      if (!_nodes.containsKey(e.id)) {
        final r = math.Random();
        final offset = Offset(
          (r.nextDouble() - 0.5) * 150,
          (r.nextDouble() - 0.5) * 150,
        );
        _nodes[e.id] = _DialNode(id: e.id, pos: center + offset, entry: e);
      } else {
        _nodes[e.id]!.entry = e;
      }
    }

    // Remove deleted nodes
    _nodes.removeWhere((id, _) => !entries.any((e) => e.id == id));

    // Rebuild wires (chain per LineConfigurationAssignment)
    _wires.clear();
    final grouped = <LineConfigurationAssignment, List<_DialNode>>{};
    for (final node in _nodes.values) {
      grouped
          .putIfAbsent(node.entry.lineConfigurationAssignment, () => [])
          .add(node);
    }
    for (final group in grouped.values) {
      for (int i = 0; i < group.length - 1; i++) {
        _wires.add(_Wire(group[i], group[i + 1]));
      }
    }
  }

  void _step(Duration elapsed) {
    if (!mounted || _size == Size.zero) return;
    _clock = elapsed.inMilliseconds / 1000.0;

    final nodesList = _nodes.values.toList();
    final center = Offset(_size.width / 2, _size.height / 2 + 40);

    // 1. Repulsion (Nodes push apart)
    for (int i = 0; i < nodesList.length; i++) {
      for (int j = i + 1; j < nodesList.length; j++) {
        final a = nodesList[i];
        final b = nodesList[j];
        final delta = a.pos - b.pos;
        double dist = delta.distance;
        if (dist < 1) dist = 1;
        if (dist < 180) {
          final force = (180 - dist) * 0.08;
          final f = (delta / dist) * force;
          a.vel += f;
          b.vel -= f;
        }
      }
    }

    // 2. Springs (Wires pull together)
    for (final wire in _wires) {
      final delta = wire.b.pos - wire.a.pos;
      double dist = delta.distance;
      if (dist < 1) dist = 1;
      final force = (dist - 120) * 0.03;
      final f = (delta / dist) * force;
      wire.a.vel += f;
      wire.b.vel -= f;
    }

    // 3. Gravity & Integration
    for (final node in nodesList) {
      if (_dragId == node.id) {
        node.vel = Offset.zero;
        continue;
      }
      final delta = center - node.pos;
      node.vel += delta * 0.004; // Gentle pull to center

      // Keep inside bounds & away from header
      if (node.pos.dx < 40) node.vel += const Offset(3, 0);
      if (node.pos.dx > _size.width - 40) node.vel -= const Offset(3, 0);
      if (node.pos.dy < 180) node.vel += const Offset(0, 4); // Avoid header
      if (node.pos.dy > _size.height - 100) node.vel -= const Offset(0, 3);

      node.vel *= 0.82; // Friction
      node.pos += node.vel;

      node.pulseGlow = math.max(0.0, node.pulseGlow - 0.03);
    }

    // 4. Pulses
    for (int i = _pulses.length - 1; i >= 0; i--) {
      final p = _pulses[i];
      p.progress += 0.04;
      if (p.progress >= 1.0) {
        p.target.pulseGlow = 1.0;
        p.target.vel += Offset(
          (math.Random().nextDouble() - 0.5) * 12,
          (math.Random().nextDouble() - 0.5) * 12,
        );
        HapticFeedback.lightImpact();
        _pulses.removeAt(i);
      }
    }

    setState(() {});
  }

  void _onPointerDown(PointerDownEvent e) {
    _pointerDownPos = e.localPosition;
    _dragged = false;

    _DialNode? hit;
    for (final node in _nodes.values) {
      if ((node.pos - e.localPosition).distance < 30) {
        hit = node;
        break;
      }
    }

    if (hit != null) {
      _dragId = hit.id;
      hit.vel = Offset.zero;
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_pointerDownPos != null &&
        (e.localPosition - _pointerDownPos!).distance > 8) {
      _dragged = true;
    }

    if (_dragId != null) {
      final node = _nodes[_dragId];
      if (node != null) {
        node.pos = e.localPosition;
      }
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    if (!_dragged && _pointerDownPos != null) {
      // It's a tap
      _DialNode? hit;
      for (final node in _nodes.values) {
        if ((node.pos - e.localPosition).distance < 30) {
          hit = node;
          break;
        }
      }

      if (hit != null) {
        setState(() {
          _selectedId = hit!.id;
        });
        _triggerPulse(hit);
        HapticFeedback.selectionClick();
      } else {
        setState(() {
          _selectedId = null;
        });
      }
    }

    _dragId = null;
    _pointerDownPos = null;
  }

  void _triggerPulse(_DialNode startNode) {
    startNode.pulseGlow = 1.0;
    for (final wire in _wires) {
      if (wire.a == startNode) {
        _pulses.add(_Pulse(source: wire.a, target: wire.b));
      } else if (wire.b == startNode) {
        _pulses.add(_Pulse(source: wire.b, target: wire.a));
      }
    }
  }

  Color _colorForLineConfig(LineConfigurationAssignment config) {
    switch (config) {
      case LineConfigurationAssignment.singleLineAbsolute:
        return kAccent; // Emerald Green
      case LineConfigurationAssignment.doubleLineBlock:
        return kGold; // Brass/Brown
      case LineConfigurationAssignment.junctionInterlocking:
        return const Color(0xFF384D7A); // Caledon Blue
      case LineConfigurationAssignment.bankerEngineTerritory:
        return const Color(0xFF735832); // Meridian Bronze
      case LineConfigurationAssignment.tunnelBlockSection:
        return const Color(0xFF485245); // Northmoor Dark Green
      case LineConfigurationAssignment.yardLimitRelease:
        return const Color(0xFF687A87); // Steel Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final pad = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: _bgDark,
      body: entries.isEmpty ? _emptyState() : _networkView(entries, pad),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_outlined, color: _ivory.withAlpha(80), size: 56),
            const SizedBox(height: 20),
            Text(
              'THE BLOCK REGISTER',
              style: GoogleFonts.archivo(
                color: _ivory,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No tokens on the network.',
              style: GoogleFonts.ibmPlexMono(
                color: _brassMid,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Text(
                'Catalogue an instrument on the Line tab. It will appear here as a live brass dial connected to its section network.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  color: _ivory.withAlpha(160),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _networkView(
    List<SafeworkingInstrumentModel> entries,
    EdgeInsets pad,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        _syncNodes(entries, _size);

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _NetworkPainter(
                  nodes: _nodes.values.toList(),
                  wires: _wires,
                  pulses: _pulses,
                  clock: _clock,
                  selectedId: _selectedId,
                  colorMapper: _colorForLineConfig,
                ),
              ),
              Positioned(
                top: pad.top + 16,
                left: 20,
                right: 20,
                child: _header(entries.length),
              ),
              if (_selectedId != null) _detailSheet(entries),
            ],
          ),
        );
      },
    );
  }

  Widget _header(int count) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUTE MAP',
            style: GoogleFonts.ibmPlexMono(
              color: _brassMid,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
            ),
          ),
          Text(
            'The Block Register',
            style: GoogleFonts.archivo(
              color: _ivory,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count live dial${count == 1 ? '' : 's'} on the grid',
            style: GoogleFonts.ibmPlexSans(
              color: _ivory.withAlpha(140),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _brassDark.withAlpha(100)),
            ),
            child: Text(
              'Drag dials to arrange · Tap to send telegraph pulse',
              style: GoogleFonts.ibmPlexSans(
                color: _pulseColor.withAlpha(200),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailSheet(List<SafeworkingInstrumentModel> entries) {
    final entry = entries.where((e) => e.id == _selectedId).firstOrNull;
    if (entry == null) return const SizedBox.shrink();
    final idx = entries.indexOf(entry);
    final accent = _colorForLineConfig(entry.lineConfigurationAssignment);

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 88,
      child: GestureDetector(
        onTap: () {}, // Prevent taps from falling through to the canvas
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xF012181F),
              borderRadius: BorderRadius.circular(kRadiusMedium),
              border: Border.all(color: accent.withAlpha(200), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withAlpha(60),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withAlpha(160),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.interlockingSerialCode,
                        style: GoogleFonts.ibmPlexMono(
                          color: _brassLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedId = null),
                      child: Icon(
                        Icons.close,
                        color: _ivory.withAlpha(160),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.safeworkingCategory.label,
                  style: GoogleFonts.archivo(
                    color: _ivory,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.lineConfigurationAssignment.label} · ${entry.provenanceDisplay}',
                  style: GoogleFonts.ibmPlexSans(
                    color: _ivory.withAlpha(150),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/info_screen',
                      arguments: {'index': idx},
                    ),
                    child: const Text(
                      'Inspect instrument',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Physics Models ────────────────────────────────────────────────────────

class _DialNode {
  _DialNode({required this.id, required this.pos, required this.entry});
  final String id;
  Offset pos;
  Offset vel = Offset.zero;
  SafeworkingInstrumentModel entry;

  double needleAngle = 0;
  double pulseGlow = 0;
}

class _Wire {
  _Wire(this.a, this.b);
  final _DialNode a;
  final _DialNode b;
}

class _Pulse {
  _Pulse({required this.source, required this.target});
  final _DialNode source;
  final _DialNode target;
  double progress = 0;
}

// ── Custom Painter ────────────────────────────────────────────────────────

class _NetworkPainter extends CustomPainter {
  _NetworkPainter({
    required this.nodes,
    required this.wires,
    required this.pulses,
    required this.clock,
    required this.selectedId,
    required this.colorMapper,
  });

  final List<_DialNode> nodes;
  final List<_Wire> wires;
  final List<_Pulse> pulses;
  final double clock;
  final String? selectedId;
  final Color Function(LineConfigurationAssignment) colorMapper;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Blueprint Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D131A),
    );
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Wires
    final wirePaint = Paint()
      ..color = _wireColor.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (final wire in wires) {
      final p1 = wire.a.pos;
      final p2 = wire.b.pos;
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 + 20);
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, p2.dx, p2.dy);
      canvas.drawPath(path, wirePaint);
    }

    // 3. Pulses
    for (final pulse in pulses) {
      final p1 = pulse.source.pos;
      final p2 = pulse.target.pos;
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2 + 20);
      double t = pulse.progress;
      double u = 1 - t;
      Offset pos = p1 * (u * u) + mid * (2 * u * t) + p2 * (t * t);

      canvas.drawCircle(
        pos,
        8,
        Paint()
          ..color = _pulseColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
    }

    // 4. Dials
    for (final node in nodes) {
      _paintDial(canvas, node);
    }
  }

  void _paintDial(Canvas canvas, _DialNode node) {
    final center = node.pos;
    final rect = Rect.fromCircle(center: center, radius: 28);

    // Shadow
    canvas.drawCircle(
      center,
      26,
      Paint()
        ..color = Colors.black.withAlpha(180)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Outer Brass Bezel
    canvas.drawCircle(
      center,
      28,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [_brassLight, _brassDark, _brassLight],
          [0.0, 0.5, 1.0],
        ),
    );

    // Inner Bezel Depth
    canvas.drawCircle(
      center,
      23,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.bottomRight,
          rect.topLeft,
          [_brassDark, _brassMid],
          [0.0, 1.0],
        ),
    );

    // Dial Face
    Color faceColor = colorMapper(node.entry.lineConfigurationAssignment);
    canvas.drawCircle(center, 21, Paint()..color = faceColor);

    // Ticks
    final tickPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 12; i++) {
      double angle = i * math.pi / 6;
      canvas.drawLine(
        center + Offset(math.cos(angle) * 16, math.sin(angle) * 16),
        center + Offset(math.cos(angle) * 21, math.sin(angle) * 21),
        tickPaint,
      );
    }

    // Needle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    double speed = node.vel.distance;
    double targetAngle = speed * 0.15;
    node.needleAngle = ui.lerpDouble(node.needleAngle, targetAngle, 0.15)!;
    canvas.rotate(
      node.needleAngle + math.sin(clock * 15 + node.id.hashCode) * 0.08,
    );

    final needlePath = Path()
      ..moveTo(-1.5, 0)
      ..lineTo(0, -16)
      ..lineTo(1.5, 0)
      ..lineTo(0, 4)
      ..close();
    canvas.drawPath(needlePath, Paint()..color = const Color(0xFFE05A47));
    canvas.drawCircle(Offset.zero, 3, Paint()..color = _brassLight);
    canvas.restore();

    // Glass Glare
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 20),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [Colors.white.withAlpha(180), Colors.transparent],
          [0.0, 1.0],
        ),
    );

    // Pulse Glow
    if (node.pulseGlow > 0) {
      canvas.drawCircle(
        center,
        28,
        Paint()
          ..color = _pulseColor.withAlpha((node.pulseGlow * 140).toInt())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }

    // Selection Ring
    if (node.id == selectedId) {
      canvas.drawCircle(
        center,
        34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = _pulseColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter old) => true;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
