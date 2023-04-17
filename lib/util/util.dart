extension HexPrint on List<int> {
  String toHexString() =>
      map((e) => e.toRadixString(16).padLeft(2, '0')).join(" ");
}