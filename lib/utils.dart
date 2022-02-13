String toBinary(String value, int spriteSize) {
  return int.parse(value).toRadixString(2).padLeft(spriteSize, "0");
}

List<int> getIntensityFromRaw(List<String> values, int spriteSize) {
  var intensity = <int>[];

  for (var index = 0; index < values.length; index += 2) {
    var lo = toBinary(values[index], spriteSize);
    var hi = toBinary(values[index + 1], spriteSize);

    print("-> $lo and $hi");

    var combined = "";
    for (var index = 0; index < spriteSize; index++) {
      combined += hi[index] + lo[index];
    }

    for (var index = 0; index < spriteSize * 2; index += 2) {
      intensity.add(int.parse(combined[index] + combined[index + 1], radix: 2));
    }
  }

  return intensity;
}

String getRawFromIntensity(List<int> intensity, int spriteSize) {
  var raw = "";

  var combined = "";
  for (var element in intensity) {
    combined += element.toRadixString(2).padLeft(2, "0");
  }

  var lo = "";
  var hi = "";
  for (var index = 0; index < spriteSize * 2; index += 2) {
    lo += combined[index];
    hi += combined[index + 1];
  }

  print("<- $lo and $hi");

  raw += "0x${int.parse(lo, radix: 2).toRadixString(16).padLeft(2, "0")}";

  print(raw);
  
  return raw;
}
