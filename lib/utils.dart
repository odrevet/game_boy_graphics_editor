String toBinary(String value, int tileSize) {
  return int.parse(value).toRadixString(2).padLeft(tileSize, "0");
}

String binaryToHex(value) {
  return "0x${int.parse(value, radix: 2).toRadixString(16).padLeft(2, "0").toUpperCase()}";
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

List<String> getRawFromIntensity(List<int> intensity, int tileSize) {
  var raw = <String>[];

  var combined = "";
  for (var element in intensity) {
    combined += element.toRadixString(2).padLeft(2, "0");
  }

  for (var index = 0;
      index < combined.length ~/ tileSize * tileSize;
      index += tileSize * 2) {
    var lo = "";
    var hi = "";
    var combinedSub = combined.substring(index, index + tileSize * 2);

    for (var indexSub = 0; indexSub < tileSize * 2; indexSub += 2) {
      lo += combinedSub[indexSub];
      hi += combinedSub[indexSub + 1];
    }

    raw.add(binaryToHex(hi));
    raw.add(binaryToHex(lo));
  }

  return raw;
}
