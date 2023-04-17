import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:spannable_grid/spannable_grid.dart';
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

  final widgets = const [
    SelectorData(
      name: "Drive Mode",
      uuid: "0",
      options: {
        "arcade": "Arcade",
        "curvature": "Curvature"
      },
      selected: "arcade",
    ),
    ToggleData(
        name: "Robot Working",
        uuid: "1",
        toggleType: ToggleType.slider,
        enabled: false
    )
  ];

  @override
  Widget build(BuildContext context) {
    // return Center(
    //   child: FilledButton(
    //     onPressed: () {},
    //     child: const Text("HI"),
    //   )
    // );
    const double gridPadding = 4;
    return Padding(
      padding: const EdgeInsets.all(gridPadding),
      child: SpannableGrid(
        columns: layout.columns,
        rows: layout.rows,
        editingStrategy: SpannableGridEditingStrategy.disabled(),
        style: const SpannableGridStyle(
          backgroundColor: Colors.transparent,
          contentOpacity: 1,
          spacing: gridPadding,
        ),
        cells: layout.widgets.where((e) => e.column >= 0
            && e.column < layout.columns
            && e.row >= 0
            && e.row < layout.rows
        ).map((e) {
          // Clamp the span to within the grid.
          final columnEnd = (e.column + e.columnSpan).clamp(0, layout.columns);
          final rowEnd = (e.row + e.rowSpan).clamp(0, layout.rows);
          final columnSpan = columnEnd - e.column;
          final rowSpan = rowEnd - e.row;

          return SpannableGridCellData(
            id: e,
            column: e.column+1,
            row: e.row+1,
            columnSpan: columnSpan,
            rowSpan: rowSpan,
            child: Container(
              color: Colors.green,
            ),
          );
        }).toList(),
        //  [
        //   SpannableGridCellData(
        //     id: "0",
        //     column: 1,
        //     row: 1,
        //     columnSpan: 2,
        //     rowSpan: 2,
        //     child: Container(
        //       color: Colors.green,
        //     ),
        //   ),
        //   SpannableGridCellData(
        //     id: "1",
        //     column: 4,
        //     row: 3,
        //     child: Container(
        //       color: Colors.red,
        //     ),
        //   ),
        // ]
      ),
    );
  }
}
