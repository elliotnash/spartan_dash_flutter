import 'package:fluent_ui/fluent_ui.dart';

import '../../models/widgets.dart';
import '../widget_card.dart';

class SelectorWidget extends StatelessWidget {
  final SelectorData data;
  final void Function(SelectorData) onChanged;
  const SelectorWidget(this.data, this.onChanged, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetCard(
      title: data.name,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: double.infinity,
          child: ComboBox(
            value: data.selected,
            onChanged: (selected) {
              if (selected != data.selected) {
                onChanged(data.copyWith(selected: selected));
              }
            },
            items: [
              for (final option in data.options.entries)
                ComboBoxItem(
                  value: option.key,
                  child: Text(option.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}