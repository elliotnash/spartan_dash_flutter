import 'package:cbor/simple.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:spartan_dash_flutter/util/cbor_extensions.dart';

part 'widgets.freezed.dart';
part 'widgets.g.dart';

enum ToggleType {
  slider,
  button
}

@Freezed(unionKey: 'type')
class WidgetData with _$WidgetData {
  const WidgetData._();

  @FreezedUnionValue('selector')
  const factory WidgetData.selector({
    required String name,
    required String uuid,
    required Map<String, String> options,
    required String? selected,
  }) = SelectorData;

  @FreezedUnionValue('toggle')
  const factory WidgetData.toggle({
    required String name,
    required String uuid,
    required ToggleType toggleType,
    required String text,
    required bool checked,
    String? checkedText,
  }) = ToggleData;

  factory WidgetData.fromJson(Map<String, Object?> json)
  => _$WidgetDataFromJson(json);

  factory WidgetData.fromCbor(List<int> data)
  => _$WidgetDataFromJson((cbor.decode(data) as Map<dynamic, dynamic>).toJsonMap());

  List<int> toCbor() {
    return cbor.encode(toJson());
  }
}

// class SelectorWidget (
// name: String,
// val options: Map<String, String>,
// selected: String
// ) : SpartanWidget(name) {
//   var selected by mutableStateOf(selected)
// }
