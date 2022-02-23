class Background {
  int height;
  int width;
  List<int> data = [];

  Background(this.height, this.width, int fill) {
    data = List.filled(height * width, fill, growable: true);
  }
}
