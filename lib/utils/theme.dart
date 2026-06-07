import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kAccent,
  scaffoldBackgroundColor: kBackground,
  colorScheme: const ColorScheme.light(
    primary: kAccent,
    secondary: kGold,
    surface: kPanelBg,
    onSurface: kPrimaryText,
    onPrimary: Colors.white,
    error: kError,
    outline: kOutline,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
    titleTextStyle: GoogleFonts.archivo(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      letterSpacing: 0.6,
    ),
    iconTheme: const IconThemeData(color: kPrimaryText),
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.archivo(
      fontSize: 48.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 0.95,
    ),
    displayMedium: GoogleFonts.archivo(
      fontSize: 36.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
      height: 1.0,
    ),
    headlineMedium: GoogleFonts.archivo(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: kPrimaryText,
    ),
    titleLarge: GoogleFonts.ibmPlexSans(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: kPrimaryText,
    ),
    bodyMedium: GoogleFonts.ibmPlexSans(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: kPrimaryText,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.ibmPlexSans(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: kSecondaryText,
    ),
    labelMedium: GoogleFonts.ibmPlexMono(
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
      color: kSecondaryText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kPanelBg,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      borderSide: const BorderSide(color: kAccent, width: kStrokeWeightMedium),
    ),
    hintStyle: GoogleFonts.ibmPlexSans(color: kSecondaryText, fontSize: 13.sp),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 28.w),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kRadiusPill)),
      ),
      textStyle: GoogleFonts.ibmPlexSans(
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
      ),
    ),
  ),
  cardTheme: const CardThemeData(
    color: kPanelBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(kRadiusSubtle)),
      side: BorderSide(color: kOutline),
    ),
  ),
  dividerTheme: const DividerThemeData(color: kOutline, thickness: 1),
  useMaterial3: true,
);
