import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'widgets.freezed.dart';
part 'widgets.g.dart';

enum ToggleStyle {
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
    required ToggleStyle style,
    required String text,
    required bool checked,
    String? checkedText,
  }) = ToggleData;

  factory WidgetData.fromJson(Map<String, Object?> json)
  => _$WidgetDataFromJson(json);
}
