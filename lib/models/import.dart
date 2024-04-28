List<int> convertBytesToDecimals(List<int> content) {
  String values = "";

  // Convert each byte to a hexadecimal string
  for (int byte in content) {
    values += byte.toRadixString(16).padLeft(2, '0');
  }
  var data = <int>[];

  // Convert hexadecimal string to decimal
  for (var index = 0; index < values.length; index += 2) {
    data.add(int.parse("${values[index]}${values[index + 1]}", radix: 16));
  }

  return data;
}

List<int> transpose(List<int> raw, int height, int width) {
  List<int> transposed = List<int>.filled(height * width, 0);

  int x = 0;
  int y = 0;
  for (int index = 0; index < raw.length; index++) {
    transposed[(y * width) + x] = raw[index];

    y++;
    if (y >= height) {
      y = 0;
      x++;
    }
  }

  return transposed;
}
