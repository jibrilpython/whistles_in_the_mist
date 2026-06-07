import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:whistles_in_the_mist/enum/my_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _interlockingSerialCode = '';
  SafeworkingCategory _safeworkingCategory =
      SafeworkingCategory.electricTrainStaff;
  ArtisanHallmark _artisanHallmark = ArtisanHallmark.other;
  String _artisanHallmarkCustom = '';
  LineConfigurationAssignment _lineConfigurationAssignment =
      LineConfigurationAssignment.singleLineAbsolute;
  String _tokenMetallurgyGeometry = '';
  LockingMechanismConfiguration _lockingMechanismConfiguration =
      LockingMechanismConfiguration.electromagneticTumbler;
  String _communicationVoltageMetrics = '';
  HousingComposition _housingComposition = HousingComposition.castIronBrass;
  String _physicalProportions = '';
  String _era = '';
  LineProvenance _lineProvenance = LineProvenance.mountainPass;
  String _lineProvenanceCustom = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get interlockingSerialCode => _interlockingSerialCode;
  SafeworkingCategory get safeworkingCategory => _safeworkingCategory;
  ArtisanHallmark get artisanHallmark => _artisanHallmark;
  String get artisanHallmarkCustom => _artisanHallmarkCustom;
  LineConfigurationAssignment get lineConfigurationAssignment =>
      _lineConfigurationAssignment;
  String get tokenMetallurgyGeometry => _tokenMetallurgyGeometry;
  LockingMechanismConfiguration get lockingMechanismConfiguration =>
      _lockingMechanismConfiguration;
  String get communicationVoltageMetrics => _communicationVoltageMetrics;
  HousingComposition get housingComposition => _housingComposition;
  String get physicalProportions => _physicalProportions;
  String get era => _era;
  LineProvenance get lineProvenance => _lineProvenance;
  String get lineProvenanceCustom => _lineProvenanceCustom;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set interlockingSerialCode(String v) {
    _interlockingSerialCode = v;
    notifyListeners();
  }

  set safeworkingCategory(SafeworkingCategory v) {
    _safeworkingCategory = v;
    notifyListeners();
  }

  set artisanHallmark(ArtisanHallmark v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set artisanHallmarkCustom(String v) {
    _artisanHallmarkCustom = v;
    notifyListeners();
  }

  set lineConfigurationAssignment(LineConfigurationAssignment v) {
    _lineConfigurationAssignment = v;
    notifyListeners();
  }

  set tokenMetallurgyGeometry(String v) {
    _tokenMetallurgyGeometry = v;
    notifyListeners();
  }

  set lockingMechanismConfiguration(LockingMechanismConfiguration v) {
    _lockingMechanismConfiguration = v;
    notifyListeners();
  }

  set communicationVoltageMetrics(String v) {
    _communicationVoltageMetrics = v;
    notifyListeners();
  }

  set housingComposition(HousingComposition v) {
    _housingComposition = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set era(String v) {
    _era = v;
    notifyListeners();
  }

  set lineProvenance(LineProvenance v) {
    _lineProvenance = v;
    notifyListeners();
  }

  set lineProvenanceCustom(String v) {
    _lineProvenanceCustom = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _interlockingSerialCode = '';
    _safeworkingCategory = SafeworkingCategory.electricTrainStaff;
    _artisanHallmark = ArtisanHallmark.other;
    _artisanHallmarkCustom = '';
    _lineConfigurationAssignment =
        LineConfigurationAssignment.singleLineAbsolute;
    _tokenMetallurgyGeometry = '';
    _lockingMechanismConfiguration =
        LockingMechanismConfiguration.electromagneticTumbler;
    _communicationVoltageMetrics = '';
    _housingComposition = HousingComposition.castIronBrass;
    _physicalProportions = '';
    _era = '';
    _lineProvenance = LineProvenance.mountainPass;
    _lineProvenanceCustom = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
