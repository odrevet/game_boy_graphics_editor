String toBinary(String value, int tileSize) {
  return int.parse(value).toRadixString(2).padLeft(tileSize, "0");
}

String binaryToHex(value) {
  return "0x${int.parse(value, radix: 2).toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

String decimalToHex(int value) {
  return "0x${value.toRadixString(16).padLeft(2, "0").toUpperCase()}";
}

List<int> getIntensityFromRaw(List<String> values, int tileSize) {
  var intensity = <int>[];

  for (var index = 0; index < values.length; index += 2) {
    var lo = toBinary(values[index], tileSize);
    var hi = toBinary(values[index + 1], tileSize);

    var combined = "";
    for (var index = 0; index < tileSize; index++) {
      combined += hi[index] + lo[index];
    }

    for (var index = 0; index < tileSize * 2; index += 2) {
      intensity.add(int.parse(combined[index] + combined[index + 1], radix: 2));
    }
  }

  return intensity;
}





