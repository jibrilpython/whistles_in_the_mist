import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/providers/user_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class InitialScreen extends ConsumerWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BlockDiagramPainter())),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 36.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'LINE CLEAR ARCHIVE',
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 110.h),
                    Text(
                      'WHISTLES\nIN THE\nMIST.',
                      style: GoogleFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 54.sp,
                        fontWeight: FontWeight.w800,
                        height: .9,
                        letterSpacing: -.8,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Catalog electric train staffs, tablet instruments, Annett keys, lock-and-block machines, and the mechanical tokens that guarded single-line sections before digital dispatch.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 15.sp,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: SafeworkingSystemFilter.values
                          .map(
                            (filter) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: filterColor(filter).withAlpha(24),
                                borderRadius: BorderRadius.circular(
                                  kRadiusPill,
                                ),
                                border: Border.all(
                                  color: filterColor(filter).withAlpha(90),
                                ),
                              ),
                              child: Text(
                                filter.label.toUpperCase(),
                                style: GoogleFonts.ibmPlexMono(
                                  color: filterColor(filter),
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 28.h),
                    GestureDetector(
                      onTap: () {
                        userProv.setFirstTimeUser(false);
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58.h,
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(kRadiusPill),
                          boxShadow: const [kShadowSignal],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Open Signal Box',
                              style: GoogleFonts.ibmPlexSans(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rail = Paint()
      ..color = kOutline
      ..strokeWidth = 1.4;
    final signal = Paint()
      ..color = kAccent.withAlpha(120)
      ..strokeWidth = 2.2;
    for (var y = size.height * .18; y < size.height; y += 82) {
      canvas.drawLine(Offset(24, y), Offset(size.width - 24, y), rail);
      for (var x = 42.0; x < size.width; x += 96) {
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = kPanelBg);
        canvas.drawCircle(Offset(x, y), 3, rail);
      }
    }
    for (var i = 0; i < 6; i++) {
      final x = size.width * (.16 + i * .14);
      final y = size.height * (.26 + math.sin(i) * .08);
      canvas.drawLine(Offset(x, y), Offset(x + 32, y - 28), signal);
      canvas.drawCircle(
        Offset(x + 32, y - 28),
        7,
        Paint()..color = kAccent.withAlpha(35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
