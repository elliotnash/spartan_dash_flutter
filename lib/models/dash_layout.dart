import 'package:cbor/simple.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:spartan_dash_flutter/util/cbor_extensions.dart';

part 'dash_layout.freezed.dart';
part 'dash_layout.g.dart';

@freezed
class DashLayout with _$DashLayout {
  const DashLayout._();

  const factory DashLayout({
    required int columns,
    required int rows,
    required List<WidgetPlacement> widgets,
  }) = _DashLayout;

  factory DashLayout.fromJson(Map<String, Object?> json)
      => _$DashLayoutFromJson(json);

  factory DashLayout.fromCbor(List<int> data)
      => _$DashLayoutFromJson((cbor.decode(data) as Map<dynamic, dynamic>).toJsonMap());

  List<int> toCbor() {
    return cbor.encode(toJson());
  }
}

enum SplitPosition {
  top,
  bottom
}

@Freezed(unionKey: 'type')
class WidgetPlacement with _$WidgetPlacement {
  @FreezedUnionValue('full')
  const factory WidgetPlacement({
    required String widgetUuid,
    required int column,
    required int row,
    required int columnSpan,
    required int rowSpan,
  }) = FullWidgetPlacement;

  @FreezedUnionValue('split')
  const factory WidgetPlacement.split({
    required String widgetUuid,
    required int column,
    required int row,
    required SplitPosition position,
  }) = SplitWidgetPlacement;

  factory WidgetPlacement.fromJson(Map<String, Object?> json)
      => _$WidgetPlacementFromJson(json);
}
