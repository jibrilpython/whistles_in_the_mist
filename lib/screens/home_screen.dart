import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';
import 'package:whistles_in_the_mist/providers/image_provider.dart';
import 'package:whistles_in_the_mist/providers/input_provider.dart';
import 'package:whistles_in_the_mist/providers/project_provider.dart';
import 'package:whistles_in_the_mist/providers/search_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  SafeworkingSystemFilter? _selectedFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectProv = ref.watch(projectProvider);
    final allEntries = projectProv.entries;
    final byFilter = _selectedFilter == null
        ? allEntries
        : allEntries
              .where(
                (e) =>
                    filterForCategory(e.safeworkingCategory) == _selectedFilter,
              )
              .toList();
    final entries = ref.watch(searchProvider).filteredList(byFilter);
    final topPadding = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: kBackground,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 84.h,
        ),
        child: FloatingActionButton(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          onPressed: () {
            ref.read(inputProvider).clearAll();
            ref.read(imageProvider).clearImage();
            Navigator.pushNamed(context, '/add_screen');
          },
          child: const Icon(Icons.add),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, topPadding + 18.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BLOCK REGISTER',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      _countPill(allEntries.length),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildTitle(),
                  SizedBox(height: 18.h),
                  _searchBar(),
                  SizedBox(height: 14.h),
                  _filters(),
                ],
              ),
            ),
          ),
          if (entries.isEmpty)
            SliverToBoxAdapter(child: _emptyState())
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 140.h),
              sliver: SliverList.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final mainIndex = ref
                      .read(projectProvider)
                      .entries
                      .indexWhere((e) => e.id == entry.id);
                  return _instrumentCard(entry, mainIndex);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHISTLES',
          style: GoogleFonts.archivo(
            color: kPrimaryText,
            fontSize: 38.sp,
            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'IN THE ',
              style: GoogleFonts.archivo(
                color: kSecondaryText,
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              'MIST',
              style: GoogleFonts.archivo(
                color: kAccent,
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Container(
              width: 28.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Container(height: 1.h, color: kOutline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _countPill(int count) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
    decoration: BoxDecoration(
      color: kAccentSurface,
      borderRadius: BorderRadius.circular(kRadiusPill),
      border: Border.all(color: kAccent.withAlpha(70)),
    ),
    child: Text(
      '$count INSTRUMENT${count == 1 ? '' : 'S'}',
      style: GoogleFonts.ibmPlexMono(
        color: kAccent,
        fontSize: 9.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _searchBar() => TextField(
    controller: _searchController,
    onChanged: ref.read(searchProvider).setSearchQuery,
    style: GoogleFonts.ibmPlexMono(color: kPrimaryText, fontSize: 13.sp),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search, color: kSecondaryText),
      hintText: 'Search code, foundry, route, token...',
    ),
  );

  Widget _filters() => SizedBox(
    height: 36.h,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _filterChip('All', null),
        ...SafeworkingSystemFilter.values.map((f) => _filterChip(f.label, f)),
      ],
    ),
  );

  Widget _filterChip(String label, SafeworkingSystemFilter? filter) {
    final selected = _selectedFilter == filter;
    final color = filter == null ? kAccent : filterColor(filter);
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36.h,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: selected ? color : kOutline),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: selected ? Colors.white : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _instrumentCard(SafeworkingInstrumentModel entry, int index) {
    final color = categoryColor(entry.safeworkingCategory);
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final hasImage =
        imagePath != null &&
        entry.photoPath.isNotEmpty &&
        File(imagePath).existsSync();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
          boxShadow: const [kShadowSubtle],
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 140.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: color),
              SizedBox(
                width: 92.w,
                child: hasImage
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : CustomPaint(
                        painter: _TokenProfilePainter(
                          entry.safeworkingCategory,
                          color,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.interlockingSerialCode,
                              style: GoogleFonts.ibmPlexMono(
                                color: kAccent,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _completeness(entry.archiveCompleteness),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        entry.safeworkingCategory.label.toUpperCase(),
                        style: GoogleFonts.archivo(
                          color: kPrimaryText,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.hallmarkDisplay,
                        style: GoogleFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _miniPill(
                            tokenAbbrev(entry.safeworkingCategory),
                            color,
                          ),
                          _miniPill(
                            entry.lineConfigurationAssignment.label,
                            kGold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _completeness(int value) => Text(
    '$value%',
    style: GoogleFonts.ibmPlexMono(
      color: value > 70 ? kAccent : kGold,
      fontSize: 10.sp,
      fontWeight: FontWeight.w800,
    ),
  );
  Widget _miniPill(String text, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(kRadiusPill),
    ),
    child: Text(
      text,
      style: GoogleFonts.ibmPlexMono(
        color: color,
        fontSize: 8.sp,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _emptyState() => Padding(
    padding: EdgeInsets.only(top: 90.h),
    child: Center(
      child: Column(
        children: [
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: CustomPaint(painter: _LootIconPainter()),
          ),
          SizedBox(height: 24.h),
          Text(
            'NO INSTRUMENTS ON THIS LINE.',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TokenProfilePainter extends CustomPainter {
  final SafeworkingCategory category;
  final Color color;
  _TokenProfilePainter(this.category, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(185)
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (category) {
      case SafeworkingCategory.electricTrainStaff:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: size.width * .22,
              height: size.height * .74,
            ),
            Radius.circular(14.r),
          ),
          paint,
        );
        break;
      case SafeworkingCategory.tabletInstrument:
      case SafeworkingCategory.trainOrderTablet:
        canvas.drawCircle(Offset(cx, cy), size.width * .24, paint);
        canvas.drawCircle(
          Offset(cx, cy),
          size.width * .1,
          Paint()..color = kPanelBg,
        );
        break;
      case SafeworkingCategory.mechanicalKeyToken:
      case SafeworkingCategory.annettsLockKey:
        canvas.drawCircle(Offset(cx - 12, cy), 17, paint);
        canvas.drawRect(Rect.fromLTWH(cx - 8, cy - 5, 44, 10), paint);
        canvas.drawRect(Rect.fromLTWH(cx + 26, cy + 5, 8, 16), paint);
        break;
      case SafeworkingCategory.permissiveBlockIndicator:
      case SafeworkingCategory.lockAndBlockMachine:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: size.width * .56,
              height: size.height * .46,
            ),
            const Radius.circular(10),
          ),
          paint,
        );
        canvas.drawCircle(Offset(cx, cy), 15, Paint()..color = kPanelBg);
        break;
    }
    final line = Paint()
      ..color = kOutline
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (.2 + i * .18);
      canvas.drawLine(Offset(12, y), Offset(size.width - 12, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _TokenProfilePainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.color != color;
}

class _LootIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Drop Shadow
    canvas.drawCircle(
      c + Offset(0, 8.h),
      size.width * 0.4,
      Paint()
        ..color = Colors.black.withAlpha(35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Outer Brass Bezel
    canvas.drawCircle(
      c,
      size.width * 0.45,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [
            const Color(0xFFF7D070),
            const Color(0xFFB58434),
            const Color(0xFF6B4C1A),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // Inner Depth
    canvas.drawCircle(
      c,
      size.width * 0.36,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width, size.height),
          Offset.zero,
          [const Color(0xFF8C6222), const Color(0xFFD4A34A)],
          [0.0, 1.0],
        ),
    );

    // Center Core (Enamel/Brass face)
    canvas.drawCircle(
      c,
      size.width * 0.32,
      Paint()
        ..shader = ui.Gradient.radial(
          c - Offset(size.width * 0.1, size.height * 0.1),
          size.width * 0.35,
          [const Color(0xFFE8C36A), const Color(0xFFA6782B)],
          [0.0, 1.0],
        ),
    );

    // Keyhole Cutout (Dark void)
    final keyhole = Path()
      ..addOval(
        Rect.fromCircle(
          center: c - Offset(0, size.height * 0.06),
          radius: size.width * 0.09,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            c.dx - size.width * 0.05,
            c.dy - size.height * 0.04,
            size.width * 0.1,
            size.height * 0.2,
          ),
          Radius.circular(size.width * 0.02),
        ),
      );

    canvas.drawPath(keyhole, Paint()..color = const Color(0xFF2A241C));

    // Inner shadow for keyhole depth
    canvas.drawPath(
      keyhole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black.withAlpha(120),
    );

    // Glass/Metal Glare Reflection
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: size.width * 0.4),
      math.pi * 1.1,
      math.pi * 0.8,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          [Colors.white.withAlpha(180), Colors.transparent],
          [0.0, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _LootIconPainter old) => false;
}
