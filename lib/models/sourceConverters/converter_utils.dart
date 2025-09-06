String hexToBinary(String value) {
  return int.parse(value).toRadixString(2).padLeft(8, "0");
}

String decToBinary(int value) {
  return value.toRadixString(2).padLeft(8, "0");
}

String binaryToHex(value) {
  return "0x${int.parse(value, radix: 2).toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

String decimalToHex(int value, {bool prefix = false}) {
  return "${prefix ? '0x' : ''}${value.toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

int binaryToDec(String value) {
  return int.parse(value, radix: 2);
}

List<int> hexToIntList(String hexString) {
  List<int> result = [];
  for (int i = 0; i < hexString.length; i += 2) {
    String hexPair = hexString.substring(i, i + 2);
    int decimalValue = int.parse(hexPair, radix: 16);
    result.add(decimalValue);
  }
  return result;
}

String formatHexPairs(String hexString) {
  if (hexString.length.isOdd) {
    hexString = "${hexString}0";
  }

  return hexString
      .replaceAllMapped(RegExp(r".."), (match) => '0x${match.group(0)} ')
      .trimRight()
      .replaceAll(' ', ', ');
}

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

List<int> transposeList(List<int> raw, int height, int width) {
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
