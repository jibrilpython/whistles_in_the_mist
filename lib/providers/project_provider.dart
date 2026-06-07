import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';
import 'package:whistles_in_the_mist/providers/image_provider.dart';
import 'package:whistles_in_the_mist/providers/input_provider.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<SafeworkingInstrumentModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'wim_safeworking_entries_v1';
  final _uuid = const Uuid();
  final _random = Random();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final decoded = jsonDecode(jsonString) as List<dynamic>;
        entries = decoded
            .map(
              (item) => SafeworkingInstrumentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading safeworking entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  String _generateSerial(
    SafeworkingCategory category,
    LineConfigurationAssignment line,
  ) {
    final categoryCode = category.name
        .replaceAll(RegExp('[^A-Z]'), '')
        .padRight(5, 'X')
        .substring(0, 5);
    final lineCode = line.name
        .replaceAll(RegExp('[^A-Z]'), '')
        .padRight(4, 'R')
        .substring(0, 4);
    final number = 1000 + _random.nextInt(8999);
    final suffix = String.fromCharCode(65 + _random.nextInt(26));
    return 'WIM-$categoryCode-$number-$lineCode-$suffix';
  }

  SafeworkingInstrumentModel _fromInput(
    WidgetRef ref, {
    SafeworkingInstrumentModel? existing,
  }) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    return SafeworkingInstrumentModel(
      id: existing?.id ?? _uuid.v4(),
      interlockingSerialCode: p.interlockingSerialCode.trim().isNotEmpty
          ? p.interlockingSerialCode.trim()
          : existing?.interlockingSerialCode ??
                _generateSerial(
                  p.safeworkingCategory,
                  p.lineConfigurationAssignment,
                ),
      safeworkingCategory: p.safeworkingCategory,
      artisanHallmark: p.artisanHallmark,
      artisanHallmarkCustom: p.artisanHallmarkCustom,
      lineConfigurationAssignment: p.lineConfigurationAssignment,
      tokenMetallurgyGeometry: p.tokenMetallurgyGeometry,
      lockingMechanismConfiguration: p.lockingMechanismConfiguration,
      communicationVoltageMetrics: p.communicationVoltageMetrics,
      housingComposition: p.housingComposition,
      physicalProportions: p.physicalProportions,
      era: p.era,
      lineProvenance: p.lineProvenance,
      lineProvenanceCustom: p.lineProvenanceCustom,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : (existing?.photoPath ?? p.photoPath),
      tags: List<String>.from(p.tags),
      dateAdded: existing?.dateAdded ?? p.dateAdded,
    );
  }

  void addEntry(WidgetRef ref) {
    entries.add(_fromInput(ref));
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    if (index < 0 || index >= entries.length) return;
    entries[index] = _fromInput(ref, existing: entries[index]);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    if (index < 0 || index >= entries.length) return;
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    if (index < 0 || index >= entries.length) return;
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];
    p.interlockingSerialCode = entry.interlockingSerialCode;
    p.safeworkingCategory = entry.safeworkingCategory;
    p.artisanHallmark = entry.artisanHallmark;
    p.artisanHallmarkCustom = entry.artisanHallmarkCustom;
    p.lineConfigurationAssignment = entry.lineConfigurationAssignment;
    p.tokenMetallurgyGeometry = entry.tokenMetallurgyGeometry;
    p.lockingMechanismConfiguration = entry.lockingMechanismConfiguration;
    p.communicationVoltageMetrics = entry.communicationVoltageMetrics;
    p.housingComposition = entry.housingComposition;
    p.physicalProportions = entry.physicalProportions;
    p.era = entry.era;
    p.lineProvenance = entry.lineProvenance;
    p.lineProvenanceCustom = entry.lineProvenanceCustom;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;
    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
