import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spartan_dash_flutter/models/dash_event.dart';
import 'package:spartan_dash_flutter/models/dash_layout.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'event_provider.g.dart';

@riverpod
Stream<DashEvent> event(EventRef ref) async* {
  // Connect to an API using sockets, and decode the output
  final socket = WebSocketChannel.connect(
    Uri.parse('ws://localhost:5810/ws'),
  );

  ref.onDispose(socket.sink.close);

  await for (final message in socket.stream) {
    final List<dynamic> json = jsonDecode(message);
    for (final Map<String, dynamic> eventJson in json) {
      final event = DashEvent.fromJson(eventJson);
      print("We got an event: $event");
      yield event;
    }
  }
}

@riverpod
class Layout extends _$Layout {
  @override
  DashLayout build() {
    ref.listen(eventProvider, (prev, next) {
      final event = next.valueOrNull;
      if (event is DashLayoutEvent) {
        // PRINT EVENT
        state = event.layout;
      }
    });
    return const DashLayout(
        columns: 4,
        rows: 3,
        widgets: [],
    );
  }
}
