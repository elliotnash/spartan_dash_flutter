import 'package:fluent_ui/fluent_ui.dart';

import '../widget_card.dart';

class UnsupportedWidget extends StatelessWidget {
  const UnsupportedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const WidgetCard(
      child: Center(
        child: Text("Unsupported Widget"),
      ),
    );
  }
}