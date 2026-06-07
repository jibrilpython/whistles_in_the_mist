import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:whistles_in_the_mist/models/project_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';
  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<SafeworkingInstrumentModel> filteredList(
    List<SafeworkingInstrumentModel> list,
  ) {
    if (searchQuery.isEmpty) return list;
    final query = searchQuery.toLowerCase();
    return list
        .where(
          (item) =>
              item.interlockingSerialCode.toLowerCase().contains(query) ||
              item.hallmarkDisplay.toLowerCase().contains(query) ||
              item.safeworkingCategory.label.toLowerCase().contains(query) ||
              item.safeworkingCategory.systemGroup.toLowerCase().contains(
                query,
              ) ||
              item.lineConfigurationAssignment.label.toLowerCase().contains(
                query,
              ) ||
              item.provenanceDisplay.toLowerCase().contains(query) ||
              item.notes.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
