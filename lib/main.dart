import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:spannable_grid/spannable_grid.dart';
import 'package:spartan_dash_flutter/const.dart';
import 'package:spartan_dash_flutter/models/dash_layout.dart';
import 'package:spartan_dash_flutter/models/widgets.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return const [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      const [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    await SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await Window.initialize();
    await Window.setEffect(effect: WindowEffect.mica);
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      // Hide title bar
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setMinimumSize(const Size(600, 400));
      await windowManager.show();
    });
  }

  runApp(const SpartanDash());
}

class SpartanDash extends StatelessWidget {
  const SpartanDash({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      theme: FluentThemeData(
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final widgets = [
  const SelectorData(
    name: "Drive Mode",
    uuid: "0",
    options: {
      "arcade": "Arcade",
      "curvature": "Curvature"
    },
    selected: "arcade",
  ),
  const ToggleData(
    name: "Robot Status",
    uuid: "1",
    toggleType: ToggleType.slider,
    text: "Robot working",
    checked: false
  ),
];

class _HomePageState extends State<HomePage> {
  final layout = const DashLayout(
    columns: 3,
    rows: 2,
    widgets: [
      WidgetPlacement(
        widgetUuid: "0",
        column: 0,
        row: 0,
        columnSpan: 1,
        rowSpan: 1,
      ),
      WidgetPlacement(
        widgetUuid: "1",
        column: 2,
        row: 1,
        columnSpan: 1,
        rowSpan: 1,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleBar(),
        Expanded(
          child: SafeArea(
            child: _buildGrid(),
          )
        ),
      ],
    );
  }

  Widget _buildTitleBar() {
    return Container(
      height: 28,
      // color: FluentTheme.of(context).accentColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(kAppTitle),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    const double gridPadding = 4;
    return Padding(
      padding: const EdgeInsets.all(gridPadding).copyWith(top: 2),
      child: SpannableGrid(
        columns: layout.columns,
        rows: layout.rows,
        editingStrategy: SpannableGridEditingStrategy.disabled(),
        style: const SpannableGridStyle(
          backgroundColor: Colors.transparent,
          contentOpacity: 1,
          spacing: gridPadding,
        ),
        // filter widgets to only those inside grid
        cells: layout.widgets.where((e) => e.column >= 0
            && e.column < layout.columns
            && e.row >= 0
            && e.row < layout.rows
        ).map((e) {
          // Clamp the span to within the grid.
          final columnSpan = e.columnSpan.clamp(1, layout.columns - e.column);
          final rowSpan = e.rowSpan.clamp(1, layout.rows - e.row);

          return SpannableGridCellData(
            id: e,
            column: e.column+1,
            row: e.row+1,
            columnSpan: columnSpan,
            rowSpan: rowSpan,
            child: SpartanWidget(e.widgetUuid),
          );
        }).toList(),
      ),
    );
  }
}

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(data.name),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Card(
              child: _buildContent(data),
            ),
          ),
        ),
      ],
    );
  }

  void _onDataChanged(WidgetData data) {
    setState(() {
      widgets[widgets.indexWhere((e) => e.uuid == data.uuid)] = data;
    });
  }

  Widget _buildContent(WidgetData data) {
    if (data is SelectorData) {
      return SelectorWidget(data, _onDataChanged);
    } else if (data is ToggleData) {
      return ToggleWidget(data, _onDataChanged);
    } else {
      return const UnsupportedWidget();
    }
  }
}

class SelectorWidget extends StatelessWidget {
  final SelectorData data;
  final void Function(SelectorData) onChanged;
  const SelectorWidget(this.data, this.onChanged, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}

class ToggleWidget extends StatelessWidget {
  final ToggleData data;
  final void Function(ToggleData) onChanged;
  const ToggleWidget(this.data, this.onChanged, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
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
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(data.checked ? data.checkedText ?? data.text : data.text),
          ),
        ),
      ),
    );
  }
}

class UnsupportedWidget extends StatelessWidget {
  const UnsupportedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Unsupported Widget"),
    );
  }
}
