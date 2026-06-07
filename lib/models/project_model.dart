import 'package:whistles_in_the_mist/enum/my_enums.dart';

class SafeworkingInstrumentModel {
  String id;
  String interlockingSerialCode;
  SafeworkingCategory safeworkingCategory;
  ArtisanHallmark artisanHallmark;
  String artisanHallmarkCustom;
  LineConfigurationAssignment lineConfigurationAssignment;
  String tokenMetallurgyGeometry;
  LockingMechanismConfiguration lockingMechanismConfiguration;
  String communicationVoltageMetrics;
  HousingComposition housingComposition;
  String physicalProportions;
  String era;
  LineProvenance lineProvenance;
  String lineProvenanceCustom;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  SafeworkingInstrumentModel({
    required this.id,
    required this.interlockingSerialCode,
    required this.safeworkingCategory,
    required this.artisanHallmark,
    required this.artisanHallmarkCustom,
    required this.lineConfigurationAssignment,
    required this.tokenMetallurgyGeometry,
    required this.lockingMechanismConfiguration,
    required this.communicationVoltageMetrics,
    required this.housingComposition,
    required this.physicalProportions,
    required this.era,
    required this.lineProvenance,
    required this.lineProvenanceCustom,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  String get hallmarkDisplay =>
      artisanHallmark == ArtisanHallmark.other &&
          artisanHallmarkCustom.isNotEmpty
      ? artisanHallmarkCustom
      : artisanHallmark.label;

  String get provenanceDisplay =>
      lineProvenance == LineProvenance.other && lineProvenanceCustom.isNotEmpty
      ? lineProvenanceCustom
      : lineProvenance.label;

  int get archiveCompleteness {
    final values = [
      interlockingSerialCode,
      tokenMetallurgyGeometry,
      communicationVoltageMetrics,
      physicalProportions,
      era,
      notes,
      photoPath,
    ];
    final filled = values.where((value) => value.trim().isNotEmpty).length;
    return ((filled / values.length) * 100).round();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'interlockingSerialCode': interlockingSerialCode,
    'safeworkingCategory': safeworkingCategory.name,
    'artisanHallmark': artisanHallmark.name,
    'artisanHallmarkCustom': artisanHallmarkCustom,
    'lineConfigurationAssignment': lineConfigurationAssignment.name,
    'tokenMetallurgyGeometry': tokenMetallurgyGeometry,
    'lockingMechanismConfiguration': lockingMechanismConfiguration.name,
    'communicationVoltageMetrics': communicationVoltageMetrics,
    'housingComposition': housingComposition.name,
    'physicalProportions': physicalProportions,
    'era': era,
    'lineProvenance': lineProvenance.name,
    'lineProvenanceCustom': lineProvenanceCustom,
    'notes': notes,
    'photoPath': photoPath,
    'tags': tags,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory SafeworkingInstrumentModel.fromJson(Map<String, dynamic> json) =>
      SafeworkingInstrumentModel(
        id: json['id'] ?? '',
        interlockingSerialCode: json['interlockingSerialCode'] ?? '',
        safeworkingCategory:
            SafeworkingCategory.values
                .asNameMap()[json['safeworkingCategory']] ??
            SafeworkingCategory.electricTrainStaff,
        artisanHallmark:
            ArtisanHallmark.values.asNameMap()[json['artisanHallmark']] ??
            ArtisanHallmark.other,
        artisanHallmarkCustom: json['artisanHallmarkCustom'] ?? '',
        lineConfigurationAssignment:
            LineConfigurationAssignment.values
                .asNameMap()[json['lineConfigurationAssignment']] ??
            LineConfigurationAssignment.singleLineAbsolute,
        tokenMetallurgyGeometry: json['tokenMetallurgyGeometry'] ?? '',
        lockingMechanismConfiguration:
            LockingMechanismConfiguration.values
                .asNameMap()[json['lockingMechanismConfiguration']] ??
            LockingMechanismConfiguration.electromagneticTumbler,
        communicationVoltageMetrics: json['communicationVoltageMetrics'] ?? '',
        housingComposition:
            HousingComposition.values.asNameMap()[json['housingComposition']] ??
            HousingComposition.castIronBrass,
        physicalProportions: json['physicalProportions'] ?? '',
        era: json['era'] ?? '',
        lineProvenance:
            LineProvenance.values.asNameMap()[json['lineProvenance']] ??
            LineProvenance.mountainPass,
        lineProvenanceCustom: json['lineProvenanceCustom'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded: DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
