class AppState {
  var selectedIntensity = 3;
  int selectedMetaTileIndexTile = 0;
  int selectedTileIndexBackground = 0;
  bool tileMode = true; // edit tile or map
  bool showGridTile = true;
  bool floodMode = false;
  bool showGridBackground = true;
  var tileBuffer = <int>[]; // copy / past tiles buffer
  AppState({required this.selectedIntensity});

  copyWith(int? selectedIntensity) =>
      AppState(selectedIntensity: selectedIntensity ?? this.selectedIntensity);
}
