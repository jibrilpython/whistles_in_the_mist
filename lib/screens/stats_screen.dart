import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';
import 'package:whistles_in_the_mist/providers/project_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  SafeworkingSystemFilter? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final topPadding = MediaQuery.paddingOf(context).top;
    if (entries.isEmpty) {
      return Scaffold(backgroundColor: kBackground, body: _empty());
    }
    final filterCounts = <SafeworkingSystemFilter, int>{};
    final lineCounts = <LineConfigurationAssignment, int>{};
    final makerCounts = <String, int>{};
    int totalCompleteness = 0;
    for (final e in entries) {
      filterCounts[filterForCategory(e.safeworkingCategory)] =
          (filterCounts[filterForCategory(e.safeworkingCategory)] ?? 0) + 1;
      lineCounts[e.lineConfigurationAssignment] =
          (lineCounts[e.lineConfigurationAssignment] ?? 0) + 1;
      makerCounts[e.hallmarkDisplay] =
          (makerCounts[e.hallmarkDisplay] ?? 0) + 1;
      totalCompleteness += e.archiveCompleteness;
    }
    final averageCompleteness = (totalCompleteness / entries.length).round();
    final recent = List<SafeworkingInstrumentModel>.from(entries)
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                topPadding + 16.h,
                20.w,
                140.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOGBOOK ANALYTICS',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.7,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'SAFEWORKING\nREGISTER',
                    style: GoogleFonts.archivo(
                      color: kPrimaryText,
                      fontSize: 42.sp,
                      height: .9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      _metric('UNITS', entries.length.toString(), kAccent),
                      _metric('MAKERS', makerCounts.length.toString(), kGold),
                      _metric(
                        'COMPLETE',
                        '$averageCompleteness%',
                        kSecondaryText,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _section('SYSTEM SEPARATION'),
                  _systemBars(filterCounts, entries.length),
                  if (_selectedFilter != null)
                    _filterReadout(
                      _selectedFilter!,
                      filterCounts,
                      entries.length,
                    ),
                  SizedBox(height: 24.h),
                  _section('LINE CONFIGURATION'),
                  _lineSpider(lineCounts, entries.length),
                  SizedBox(height: 24.h),
                  _section('HALLMARK FOOTPRINT'),
                  _ranking(makerCounts, entries.length),
                  SizedBox(height: 24.h),
                  _section('RECENT ENTRIES'),
                  ...recent
                      .take(5)
                      .map(
                        (e) => _recentTile(
                          e,
                          entries.indexWhere((x) => x.id == e.id),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) => Expanded(
    child: Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(vertical: 15.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.ibmPlexMono(
              color: color,
              fontSize: 23.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 8.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _section(String label) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Text(
      label,
      style: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
      ),
    ),
  );

  Widget _systemBars(Map<SafeworkingSystemFilter, int> data, int total) =>
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: _panel(),
        child: Column(
          children: SafeworkingSystemFilter.values.map((filter) {
            final count = data[filter] ?? 0;
            final frac = total == 0 ? 0.0 : count / total;
            final color = filterColor(filter);
            final selected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = selected ? null : filter);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(selected ? 10.w : 0),
                decoration: BoxDecoration(
                  color: selected ? color.withAlpha(14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92.w,
                      child: Text(
                        filter.label.toUpperCase(),
                        style: GoogleFonts.ibmPlexSans(
                          color: selected ? color : kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        child: LinearProgressIndicator(
                          value: frac,
                          minHeight: 16.h,
                          color: color,
                          backgroundColor: kOutline,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '$count',
                      style: GoogleFonts.ibmPlexMono(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
  Widget _filterReadout(
    SafeworkingSystemFilter filter,
    Map<SafeworkingSystemFilter, int> data,
    int total,
  ) {
    final count = data[filter] ?? 0;
    final percent = total == 0 ? 0 : (count / total * 100).round();
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: filterColor(filter).withAlpha(18),
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: filterColor(filter).withAlpha(60)),
      ),
      child: Text(
        '${filter.label}: $count records, $percent% of the archive.',
        style: GoogleFonts.ibmPlexSans(color: kPrimaryText, fontSize: 13.sp),
      ),
    );
  }

  Widget _lineSpider(Map<LineConfigurationAssignment, int> data, int total) =>
      Container(
        height: 250.h,
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: _panel(),
        child: CustomPaint(painter: _SpiderPainter(data, total)),
      );
  Widget _ranking(Map<String, int> data, int total) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 5 and group the rest into "Other"
    final topN = sorted.take(5).toList();
    final othersCount = sorted.skip(5).fold<int>(0, (sum, e) => sum + e.value);
    if (othersCount > 0) {
      topN.add(MapEntry('Other / Minor Foundries', othersCount));
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _panel(),
      child: Column(
        children: topN.map((e) {
          final frac = total == 0 ? 0.0 : e.value / total;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: GoogleFonts.ibmPlexSans(
                      color: kPrimaryText,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 120.w,
                  child: LinearProgressIndicator(
                    value: frac,
                    color: kGold,
                    backgroundColor: kOutline,
                    minHeight: 8.h,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${e.value}',
                  style: GoogleFonts.ibmPlexMono(
                    color: kGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _recentTile(SafeworkingInstrumentModel entry, int index) =>
      GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': index},
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 9.h),
          padding: EdgeInsets.all(13.w),
          decoration: _panel(),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: categoryColor(entry.safeworkingCategory).withAlpha(22),
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                ),
                child: Text(
                  tokenAbbrev(entry.safeworkingCategory),
                  style: GoogleFonts.ibmPlexMono(
                    color: categoryColor(entry.safeworkingCategory),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.interlockingSerialCode,
                      style: GoogleFonts.ibmPlexMono(
                        color: kAccent,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      entry.safeworkingCategory.label,
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kSecondaryText),
            ],
          ),
        ),
      );
  BoxDecoration _panel() => BoxDecoration(
    color: kPanelBg,
    borderRadius: BorderRadius.circular(kRadiusSubtle),
    border: Border.all(color: kOutline),
  );
  Widget _empty() => Center(
    child: Text(
      'NO DATA YET.',
      style: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 13.sp,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _SpiderPainter extends CustomPainter {
  final Map<LineConfigurationAssignment, int> data;
  final int total;
  _SpiderPainter(this.data, this.total);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    final axes = LineConfigurationAssignment.values;
    final grid = Paint()
      ..color = kOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()
      ..color = kAccent.withAlpha(45)
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = kAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (var i = 0; i < axes.length; i++) {
        final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
        final p =
            center +
            Offset(math.cos(angle), math.sin(angle)) * (radius * ring / 4);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, grid);
    }
    final shape = Path();
    for (var i = 0; i < axes.length; i++) {
      final count = data[axes[i]] ?? 0;
      final frac = total == 0 ? 0.0 : count / total;
      final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
      final p =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              radius *
              (.25 + frac * .75);
      i == 0 ? shape.moveTo(p.dx, p.dy) : shape.lineTo(p.dx, p.dy);
    }
    shape.close();
    canvas.drawPath(shape, fill);
    canvas.drawPath(shape, line);

    // Draw labels at the vertices
    for (var i = 0; i < axes.length; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / axes.length;
      final labelP =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 24.w);

      final textPainter = TextPainter(
        text: TextSpan(
          text: axes[i].label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(maxWidth: 80.w);
      textPainter.paint(
        canvas,
        labelP - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpiderPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.total != total;
}
