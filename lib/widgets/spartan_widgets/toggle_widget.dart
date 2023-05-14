import 'package:fluent_ui/fluent_ui.dart';

import '../../const.dart';
import '../../models/widgets.dart';
import '../widget_card.dart';

class ToggleWidget extends StatelessWidget {
  final ToggleData data;
  final void Function(ToggleData) onChanged;
  const ToggleWidget(this.data, this.onChanged, {
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
          child: ToggleButton(
            checked: data.checked,
            onChanged: (checked) {
              if (checked != data.checked) {
                onChanged(data.copyWith(checked: checked));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: kToggleButtonWidgetPadding),
              child: Text(data.checked ? data.checkedText ?? data.text : data.text),
            ),
          ),
        ),
      ),
    );
  }
}