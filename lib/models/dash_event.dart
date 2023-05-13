import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:spartan_dash_flutter/models/dash_layout.dart';
import 'package:spartan_dash_flutter/models/widgets.dart';

part 'dash_event.freezed.dart';
part 'dash_event.g.dart';

@Freezed(unionKey: 'type')
class DashEvent with _$DashEvent {
  const DashEvent._();

  @FreezedUnionValue('layout')
  const factory DashEvent.layout({
    required DashLayout layout
  }) = DashLayoutEvent;
  @FreezedUnionValue('widget')
  const factory DashEvent.widget({
    required WidgetData widget
  }) = WidgetEvent;

  factory DashEvent.fromJson(Map<String, Object?> json)
  => _$DashEventFromJson(json);
}
