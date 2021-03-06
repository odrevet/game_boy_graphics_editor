String toBinary(String value) {
  return int.parse(value).toRadixString(2).padLeft(8, "0");
}

String binaryToHex(value) {
  return "0x${int.parse(value, radix: 2).toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

String decimalToHex(int value) {
  return "0x${value.toRadixString(16).padLeft(2, "0").toUpperCase()}";
}
