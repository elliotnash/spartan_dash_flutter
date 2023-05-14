import 'package:fluent_ui/fluent_ui.dart';
import 'package:spartan_dash_flutter/main.dart';

import '../models/widgets.dart';
import 'spartan_widgets/selector_widget.dart';
import 'spartan_widgets/toggle_widget.dart';
import 'spartan_widgets/unsupported_widget.dart';

class SpartanWidget extends StatefulWidget {
  final String uuid;
  const SpartanWidget(this.uuid, {
    super.key,
  });

  @override
  State<SpartanWidget> createState() => _SpartanWidgetState();
}

class _SpartanWidgetState extends State<SpartanWidget> {
  @override
  Widget build(BuildContext context) {
    final data = widgets.firstWhere((e) => e.uuid == widget.uuid);

    if (data is SelectorData) {
      return SelectorWidget(data, _onDataChanged);
    } else if (data is ToggleData) {
      return ToggleWidget(data, _onDataChanged);
    } else {
      return const UnsupportedWidget();
    }
  }

  void _onDataChanged(WidgetData data) {
    setState(() {
      widgets[widgets.indexWhere((e) => e.uuid == data.uuid)] = data;
    });
  }
}
