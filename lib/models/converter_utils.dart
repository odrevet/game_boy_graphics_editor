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