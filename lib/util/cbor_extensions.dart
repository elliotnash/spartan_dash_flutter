extension JsonMap on Map<dynamic, dynamic> {
  dynamic _convertValue(dynamic value) {
    if (value is Map<dynamic, dynamic>) {
      return value.toJsonMap();
    } else if (value is Iterable<dynamic>) {
      return [
        for (final entry in value)
          _convertValue(entry)
      ];
    } else {
      return value;
    }
  }
  Map<String, dynamic> toJsonMap() {
    return {
      for (final entry in entries)
        entry.key as String: _convertValue(entry.value)
    };
  }
}
