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

  await SystemTheme.accentColor.load();

  if (isDesktop) {
    await Window.initialize();
    await WindowManager.instance.ensureInitialized();

    await Window.setEffect(effect: WindowEffect.mica);
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
  const SplitData(
    uuid: "1",
    top: "2",
    bottom: "2",
  ),
  const ToggleData(
      name: "Robot Status",
      uuid: "2",
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
        column: 0,
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
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return SizedBox(
        height: kMacOSTitleBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(kAppTitle),
          ],
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return SizedBox(
        height: kWindowsTitleBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(kAppTitle),
          ],
        ),
      );
    } else {
      return Container();
    }
    // For switch expressions
    // return switch (defaultTargetPlatform) {
    //   TargetPlatform.android => Container();
    //   _ => Container()
    // }
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth ~/ kWidgetWidth;
        final rows = constraints.maxHeight ~/ kWidgetHeight;

        return Padding(
          padding: const EdgeInsets.all(kGridPadding).copyWith(top: 2),
          child: SpannableGrid(
            columns: columns,
            rows: rows,
            editingStrategy: SpannableGridEditingStrategy.disabled(),
            style: const SpannableGridStyle(
              backgroundColor: Colors.transparent,
              contentOpacity: 1,
              spacing: kGridPadding,
            ),
            // filter widgets to only those inside grid
            cells: layout.widgets.where((e) => e.column >= 0
                && e.column < columns
                && e.row >= 0
                && e.row < rows
            ).map((e) {
              // Clamp the span to within the grid.
              final columnSpan = e.columnSpan.clamp(1, columns - e.column);
              final rowSpan = e.rowSpan.clamp(1, rows - e.row);

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

    if (data is SelectorData) {
      return SelectorWidget(data, _onDataChanged);
    } else if (data is ToggleData) {
      return ToggleWidget(data, _onDataChanged);
    } else if (data is SplitData) {
      return SplitWidget(data);
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

class WidgetCard extends StatelessWidget {
  final Widget child;
  final String? title;
  const WidgetCard({
    required this.child,
    this.title,
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
        Expanded(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Card(
              child: child,
            ),
          ),
        ),
      ],
    );
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
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(data.checked ? data.checkedText ?? data.text : data.text),
            ),
          ),
        ),
      ),
    );
  }
}

class SplitWidget extends StatelessWidget {
  final SplitData data;
  const SplitWidget(this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChild(data.top),
        const SizedBox(height: kGridPadding * 2),
        _buildChild(data.bottom),
      ],
    );
  }

  Widget _buildChild(String? uuid) {
    return Flexible(
      flex: 1,
      child: uuid == null ? Container() : SpartanWidget(uuid),
    );
  }
}

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
