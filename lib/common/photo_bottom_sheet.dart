import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whistles_in_the_mist/providers/image_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

void photoBottomSheet(
  BuildContext context,
  ImageNotifier imageProv,
  int index,
  WidgetRef ref,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PhotoBottomSheetContent(imageProv: imageProv),
  );
}

class _PhotoBottomSheetContent extends StatelessWidget {
  final ImageNotifier imageProv;
  const _PhotoBottomSheetContent({required this.imageProv});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kRadiusMedium),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: kOutline,
              borderRadius: BorderRadius.circular(kRadiusPill),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            'VISUAL RECORD',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Instrument Photograph',
            style: GoogleFonts.archivo(
              color: kPrimaryText,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          _option(
            context,
            Icons.camera_alt_outlined,
            'TAKE PHOTOGRAPH',
            'Document the token, staff, keyway, or cabinet face.',
            ImageSource.camera,
            kAccent,
          ),
          SizedBox(height: 10.h),
          _option(
            context,
            Icons.photo_library_outlined,
            'SELECT FROM LIBRARY',
            'Attach an existing archive image.',
            ImageSource.gallery,
            kGold,
          ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    IconData icon,
    String label,
    String sublabel,
    ImageSource source,
    Color color,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await imageProv.pickImage(source: source);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withAlpha(24),
                borderRadius: BorderRadius.circular(kRadiusSubtle),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    sublabel,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 11.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: kSecondaryText,
              size: 12.sp,
            ),
          ],
        ),
      ),
    );
  }
}
