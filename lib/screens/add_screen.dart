import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/common/photo_bottom_sheet.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/providers/image_provider.dart';
import 'package:whistles_in_the_mist/providers/input_provider.dart';
import 'package:whistles_in_the_mist/providers/project_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});
  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late final PageController _pageCtrl;
  int _currentPage = 0;
  int? _eraStartYear;
  int? _eraEndYear;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _hallmarkCtrl;
  late final TextEditingController _tokenCtrl;
  late final TextEditingController _voltageCtrl;
  late final TextEditingController _physicalCtrl;
  late final TextEditingController _provenanceCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _tagsCtrl;
  static const _pageTitles = ['Identity', 'Mechanism', 'Provenance'];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    final p = ref.read(inputProvider);
    final parsedEra = _parseEra(p.era);
    _eraStartYear = parsedEra.$1;
    _eraEndYear = parsedEra.$2;
    _serialCtrl = TextEditingController(text: p.interlockingSerialCode);
    _hallmarkCtrl = TextEditingController(text: p.artisanHallmarkCustom);
    _tokenCtrl = TextEditingController(text: p.tokenMetallurgyGeometry);
    _voltageCtrl = TextEditingController(text: p.communicationVoltageMetrics);
    _physicalCtrl = TextEditingController(text: p.physicalProportions);
    _provenanceCtrl = TextEditingController(text: p.lineProvenanceCustom);
    _notesCtrl = TextEditingController(text: p.notes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));
  }

  (int?, int?) _parseEra(String era) {
    if (era.trim().isEmpty) return (null, null);
    final range = RegExp(r'(\d{4})\s*[–-]\s*(\d{4})').firstMatch(era);
    if (range != null) {
      return (int.parse(range.group(1)!), int.parse(range.group(2)!));
    }
    final single = RegExp(r'(\d{4})').firstMatch(era);
    if (single != null) {
      final year = int.parse(single.group(1)!);
      return (year, year);
    }
    return (null, null);
  }

  String _formatEra(int startYear, int endYear) =>
      startYear == endYear ? '$startYear' : '$startYear – $endYear';

  String _eraDisplayLabel() {
    if (_eraStartYear == null || _eraEndYear == null) {
      final era = ref.read(inputProvider).era;
      return era.isNotEmpty ? era : 'Tap to select service years';
    }
    return _formatEra(_eraStartYear!, _eraEndYear!);
  }

  Future<void> _pickEra() async {
    final years = List.generate(
      DateTime.now().year - 1799,
      (index) => 1800 + index,
    );
    var startYear = _eraStartYear ?? 1890;
    var endYear = _eraEndYear ?? 1914;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusMedium),
              border: Border.all(color: kOutline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SERVICE ERA',
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Select the years this instrument saw active duty.',
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: _yearDropdown(
                        label: 'FROM',
                        value: startYear,
                        years: years,
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            startYear = value;
                            if (endYear < startYear) endYear = startYear;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16.sp,
                        color: kSecondaryText,
                      ),
                    ),
                    Expanded(
                      child: _yearDropdown(
                        label: 'TO',
                        value: endYear,
                        years: years.where((y) => y >= startYear).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() => endYear = value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      _eraStartYear = startYear;
      _eraEndYear = endYear;
    });
    ref.read(inputProvider).era = _formatEra(startYear, endYear);
  }

  Widget _yearDropdown({
    required String label,
    required int value,
    required List<int> years,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<int>(
          key: ValueKey('$label-$value'),
          initialValue: years.contains(value) ? value : years.first,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: years
              .map(
                (year) => DropdownMenuItem(
                  value: year,
                  child: Text(
                    '$year',
                    style: GoogleFonts.ibmPlexMono(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final ctrl in [
      _serialCtrl,
      _hallmarkCtrl,
      _tokenCtrl,
      _voltageCtrl,
      _physicalCtrl,
      _provenanceCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RegisteringDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 650));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
    ref.read(inputProvider).clearAll();
    ref.read(imageProvider).clearImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'EDIT INSTRUMENT' : 'RECORD INSTRUMENT'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _stepper(),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _identityPage(),
                      _mechanismPage(),
                      _provenancePage(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(left: 0, right: 0, bottom: 0, child: _bottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _stepper() => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
    child: Row(
      children: List.generate(_pageTitles.length, (i) {
        final active = i == _currentPage;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: i == _pageTitles.length - 1 ? 0 : 7.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: active ? kAccent : kOutline,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  _pageTitles[i].toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                    color: active ? kAccent : kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );

  Widget _identityPage() {
    final p = ref.watch(inputProvider);
    return _page(
      children: [
        _photoSection(),
        _sectionHeader('01 - IDENTIFICATION', Icons.fingerprint),
        _field(
          'INTERLOCKING SERIAL CODE',
          _serialCtrl,
          'Auto if left blank: WIM-BLOCK-7731-RAIL-Z',
          (v) => p.interlockingSerialCode = v,
        ),
        _subLabel('SAFEWORKING CATEGORY'),
        _chips<SafeworkingCategory>(
          SafeworkingCategory.values,
          p.safeworkingCategory,
          (v) => ref.read(inputProvider).safeworkingCategory = v,
          (v) => v.label,
          categoryColor,
        ),
        _field(
          'CUSTOM HALLMARK',
          _hallmarkCtrl,
          'e.g. Your fictional foundry name',
          (v) {
            p.artisanHallmark = ArtisanHallmark.other;
            p.artisanHallmarkCustom = v;
          },
        ),
      ],
    );
  }

  Widget _mechanismPage() {
    final p = ref.watch(inputProvider);
    return _page(
      children: [
        _sectionHeader('02 - LOCKING AND TOKEN SYSTEM', Icons.lock_outline),
        _subLabel('LINE CONFIGURATION ASSIGNMENT'),
        _chips<LineConfigurationAssignment>(
          LineConfigurationAssignment.values,
          p.lineConfigurationAssignment,
          (v) => ref.read(inputProvider).lineConfigurationAssignment = v,
          (v) => v.label,
          (_) => kAccent,
        ),
        _field(
          'TOKEN METALLURGY AND GEOMETRY',
          _tokenCtrl,
          "e.g. Solid brass with configuration 'A' rings",
          (v) => p.tokenMetallurgyGeometry = v,
          maxLines: 2,
        ),
        _subLabel('LOCKING MECHANISM CONFIGURATION'),
        _chips<LockingMechanismConfiguration>(
          LockingMechanismConfiguration.values,
          p.lockingMechanismConfiguration,
          (v) => ref.read(inputProvider).lockingMechanismConfiguration = v,
          (v) => v.label,
          (_) => kGold,
        ),
        _field(
          'COMMUNICATION VOLTAGE METRICS',
          _voltageCtrl,
          'e.g. 12V DC needle deflection; hand-cranked magneto',
          (v) => p.communicationVoltageMetrics = v,
          maxLines: 2,
        ),
        _subLabel('HOUSING COMPOSITION'),
        _chips<HousingComposition>(
          HousingComposition.values,
          p.housingComposition,
          (v) => ref.read(inputProvider).housingComposition = v,
          (v) => v.label,
          (_) => kSecondaryText,
        ),
        _field(
          'PHYSICAL PROPORTIONS',
          _physicalCtrl,
          'e.g. 141 cm column; 43 x 35 cm base; 62 kg dry mass',
          (v) => p.physicalProportions = v,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _provenancePage() {
    final p = ref.watch(inputProvider);
    return _page(
      children: [
        _sectionHeader('03 - ROUTE PROVENANCE', Icons.history_edu_outlined),
        _eraPicker(p),
        _subLabel('LINE PROVENANCE'),
        _chips<LineProvenance>(
          LineProvenance.values,
          p.lineProvenance,
          (v) => ref.read(inputProvider).lineProvenance = v,
          (v) => v.label,
          (_) => kAccent,
        ),
        _field(
          'CUSTOM LINE PROVENANCE',
          _provenanceCtrl,
          'e.g. Forgotten mountain pass branch line',
          (v) => p.lineProvenanceCustom = v,
          maxLines: 2,
        ),
        _field(
          'ARCHIVAL NOTES',
          _notesCtrl,
          'Operational story, missing seals, cabinet wear, exchange history...',
          (v) => p.notes = v,
          maxLines: 4,
        ),
        _field(
          'TAGS',
          _tagsCtrl,
          'staff, brass, tunnel, LNWR',
          (v) => p.tags = v
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        ),
      ],
    );
  }

  Widget _page({required List<Widget> children}) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 126.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.expand((w) => [w, SizedBox(height: 14.h)]).toList(),
    ),
  );

  Widget _photoSection() {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        height: 210.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgPath != null && File(imgPath).existsSync()
            ? Image.file(File(imgPath), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: kAccent, size: 30.sp),
                  SizedBox(height: 10.h),
                  Text(
                    'Upload instrument photograph',
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String label, IconData icon) => Row(
    children: [
      Icon(icon, color: kAccent, size: 16.sp),
      SizedBox(width: 8.w),
      Text(
        label,
        style: GoogleFonts.ibmPlexMono(
          color: kPrimaryText,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
  Widget _subLabel(String label) => Text(
    label,
    style: GoogleFonts.ibmPlexMono(
      color: kSecondaryText,
      fontSize: 9.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );
  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subLabel(label),
      SizedBox(height: 6.h),
      TextField(
        controller: ctrl,
        onChanged: onChanged,
        maxLines: maxLines,
        style: GoogleFonts.ibmPlexSans(color: kPrimaryText, fontSize: 14.sp),
        decoration: InputDecoration(hintText: hint),
      ),
    ],
  );

  Widget _eraPicker(InputNotifier p) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _subLabel('ERA'),
      SizedBox(height: 6.h),
      GestureDetector(
        onTap: _pickEra,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: 'Select active service years',
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: kAccent,
              size: 20.sp,
            ),
          ),
          child: Text(
            _eraDisplayLabel(),
            style: GoogleFonts.ibmPlexMono(
              color: _eraStartYear != null || p.era.isNotEmpty
                  ? kPrimaryText
                  : kSecondaryText,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _chips<T>(
    List<T> values,
    T current,
    ValueChanged<T> onSelected,
    String Function(T) label,
    Color Function(T) color,
  ) => Wrap(
    spacing: 8.w,
    runSpacing: 8.h,
    children: values.map((v) {
      final selected = v == current;
      final c = color(v);
      return GestureDetector(
        onTap: () => onSelected(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? c : kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(color: selected ? c : kOutline),
          ),
          child: Text(
            label(v),
            style: GoogleFonts.ibmPlexSans(
              color: selected ? Colors.white : kSecondaryText,
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _bottomNav() {
    final last = _currentPage == _pageTitles.length - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: kBackground.withAlpha(242),
        border: const Border(top: BorderSide(color: kOutline)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: () => _pageCtrl.previousPage(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          Expanded(
            child: ElevatedButton(
              onPressed: last
                  ? _save
                  : () => _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                    ),
              child: Text(
                last
                    ? (widget.isEdit
                          ? 'Update Archive Record'
                          : 'Commit to Archive')
                    : 'Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisteringDialog extends StatelessWidget {
  const _RegisteringDialog();
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusMedium),
        border: Border.all(color: kOutline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: kAccent),
          SizedBox(height: 16.h),
          Text(
            'SETTING LINE CLEAR',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}
