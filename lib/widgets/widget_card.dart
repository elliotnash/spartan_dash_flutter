import 'package:fluent_ui/fluent_ui.dart';
import 'package:spartan_dash_flutter/const.dart';

class WidgetCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool expanded;
  const WidgetCard({
    required this.child,
    this.title,
    this.expanded = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: kWidgetTitleLeftPadding,
              bottom: kWidgetTitleBottomPadding,
            ),
            child: Text(title!),
          ),
        if (expanded)
          Expanded(
            child: Card(
              child: child,
            ),
          )
        else
          Card(
            padding: const EdgeInsets.all(kWidgetPadding),
            child: child,
          ),
      ],
    );
  }
}
