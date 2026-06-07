import 'package:flutter/material.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';

const Color kBackground = Color(0xFFF1F2F0);
const Color kPrimaryText = Color(0xFF0F1410);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF6B7268);
const Color kAccent = Color(0xFF2D6A3F);
const Color kOutline = Color(0xFFE4E6E2);
const Color kGold = Color(0xFF8B4A1C);
const Color kError = Color(0xFFC0392B);
const Color kAccentSurface = Color(0x1A2D6A3F);
const Color kGoldSurface = Color(0x1A8B4A1C);

const double kSpacingS = 12.0;
const double kSpacingM = 16.0;
const double kSpacingL = 20.0;
const double kRadiusSubtle = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium = 20.0;
const double kRadiusPill = 999.0;
const double kStrokeWeight = 1.0;
const double kStrokeWeightMedium = 1.5;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 3),
  blurRadius: 14,
  spreadRadius: -8,
  color: Color(0x260F1410),
);
const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 14),
  blurRadius: 34,
  spreadRadius: -20,
  color: Color(0x330F1410),
);
const BoxShadow kShadowSignal = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -12,
  color: Color(0x552D6A3F),
);
const BoxShadow kShadowOrange = kShadowSignal;

Color categoryColor(SafeworkingCategory category) {
  switch (category) {
    case SafeworkingCategory.electricTrainStaff:
      return kAccent;
    case SafeworkingCategory.tabletInstrument:
      return const Color(0xFF43775B);
    case SafeworkingCategory.mechanicalKeyToken:
      return kGold;
    case SafeworkingCategory.annettsLockKey:
      return const Color(0xFF6A5132);
    case SafeworkingCategory.permissiveBlockIndicator:
      return const Color(0xFF49656E);
    case SafeworkingCategory.lockAndBlockMachine:
      return const Color(0xFF31483A);
    case SafeworkingCategory.trainOrderTablet:
      return const Color(0xFF687A87);
  }
}

Color filterColor(SafeworkingSystemFilter filter) {
  switch (filter) {
    case SafeworkingSystemFilter.staffTicket:
      return kAccent;
    case SafeworkingSystemFilter.electricToken:
      return const Color(0xFF43775B);
    case SafeworkingSystemFilter.lockBlock:
      return const Color(0xFF31483A);
    case SafeworkingSystemFilter.keyToken:
      return kGold;
    case SafeworkingSystemFilter.trainOrder:
      return const Color(0xFF687A87);
  }
}

Color hallmarkColor(ArtisanHallmark hallmark) {
  switch (hallmark) {
    case ArtisanHallmark.ironTrack:
      return kAccent;
    case ArtisanHallmark.vanguard:
      return kGold;
    case ArtisanHallmark.sovereign:
      return const Color(0xFF49656E);
    case ArtisanHallmark.caledon:
      return const Color(0xFF384D7A);
    case ArtisanHallmark.northmoor:
      return const Color(0xFF485245);
    case ArtisanHallmark.meridian:
      return const Color(0xFF735832);
    case ArtisanHallmark.westinghouseStyle:
      return const Color(0xFF2F5D73);
    case ArtisanHallmark.other:
      return kSecondaryText;
  }
}

String tokenAbbrev(SafeworkingCategory category) {
  switch (category) {
    case SafeworkingCategory.electricTrainStaff:
      return 'STAFF';
    case SafeworkingCategory.tabletInstrument:
      return 'TAB';
    case SafeworkingCategory.mechanicalKeyToken:
      return 'KEY';
    case SafeworkingCategory.annettsLockKey:
      return 'ANN';
    case SafeworkingCategory.permissiveBlockIndicator:
      return 'PBI';
    case SafeworkingCategory.lockAndBlockMachine:
      return 'L&B';
    case SafeworkingCategory.trainOrderTablet:
      return 'ORD';
  }
}
