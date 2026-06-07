import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';
import 'package:whistles_in_the_mist/providers/image_provider.dart';
import 'package:whistles_in_the_mist/providers/project_provider.dart';
import 'package:whistles_in_the_mist/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return const Scaffold(body: Center(child: Text('INSTRUMENT NOT FOUND')));
    }
    final entry = projectProv.entries[index];
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final hasImage =
        imagePath != null &&
        entry.photoPath.isNotEmpty &&
        File(imagePath).existsSync();
    final color = categoryColor(entry.safeworkingCategory);
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              projectProv.fillInput(ref, index);
              Navigator.pushNamed(
                context,
                '/add_screen',
                arguments: {'isEdit': true, 'currentIndex': index},
              );
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _delete(context, projectProv),
            icon: const Icon(Icons.delete_outline, color: kError),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 320.h,
              margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              decoration: BoxDecoration(
                color: kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                border: Border.all(color: kOutline),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.file(File(imagePath), fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        Icons.account_tree_outlined,
                        color: color,
                        size: 72.sp,
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 130.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  entry.interlockingSerialCode,
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  entry.safeworkingCategory.label.toUpperCase(),
                  style: GoogleFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 32.sp,
                    height: .95,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${entry.hallmarkDisplay} - ${entry.era.isEmpty ? 'Era unrecorded' : entry.era}',
                  style: GoogleFonts.ibmPlexSans(
                    color: kSecondaryText,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                _clearanceCard(entry),
                SizedBox(height: 20.h),
                _section('MECHANICAL SPECIFICATION'),
                _spec(
                  'Line Assignment',
                  entry.lineConfigurationAssignment.label,
                  Icons.route_outlined,
                  kAccent,
                ),
                _spec(
                  'Token Metallurgy',
                  entry.tokenMetallurgyGeometry,
                  Icons.token_outlined,
                  kGold,
                ),
                _spec(
                  'Locking Mechanism',
                  entry.lockingMechanismConfiguration.label,
                  Icons.lock_outline,
                  color,
                ),
                _spec(
                  'Communication Voltage',
                  entry.communicationVoltageMetrics,
                  Icons.bolt_outlined,
                  kAccent,
                ),
                _spec(
                  'Housing Composition',
                  entry.housingComposition.label,
                  Icons.inventory_2_outlined,
                  kSecondaryText,
                ),
                _spec(
                  'Physical Proportions',
                  entry.physicalProportions,
                  Icons.straighten_outlined,
                  kGold,
                ),
                SizedBox(height: 18.h),
                _section('LINE PROVENANCE'),
                _note(entry.provenanceDisplay),
                if (entry.notes.isNotEmpty) _note(entry.notes),
                if (entry.tags.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: entry.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag.toUpperCase()),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearanceCard(SafeworkingInstrumentModel entry) => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: kOutline),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ARCHIVE COMPLETENESS',
                style: GoogleFonts.ibmPlexMono(
                  color: kSecondaryText,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusPill),
                child: LinearProgressIndicator(
                  value: entry.archiveCompleteness / 100,
                  minHeight: 8.h,
                  color: kAccent,
                  backgroundColor: kOutline,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        Text(
          '${entry.archiveCompleteness}%',
          style: GoogleFonts.ibmPlexMono(
            color: kAccent,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
  Widget _section(String label) => Padding(
    padding: EdgeInsets.only(bottom: 10.h),
    child: Text(
      label,
      style: GoogleFonts.ibmPlexMono(
        color: kSecondaryText,
        fontSize: 10.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    ),
  );
  Widget _spec(String label, String value, IconData icon, Color color) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: 9.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(String text) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(15.w),
    decoration: BoxDecoration(
      color: kPanelBg,
      borderRadius: BorderRadius.circular(kRadiusSubtle),
      border: Border.all(color: kOutline),
    ),
    child: Text(
      text,
      style: GoogleFonts.ibmPlexSans(
        color: kPrimaryText,
        fontSize: 14.sp,
        height: 1.55,
      ),
    ),
  );
  void _delete(BuildContext context, ProjectNotifier projectProv) => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove record?'),
      content: const Text('This will remove the instrument from the archive.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            projectProv.deleteEntry(index);
            Navigator.pop(ctx);
            Navigator.pop(context);
          },
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}
