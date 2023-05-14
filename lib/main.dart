import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spannable_grid/spannable_grid.dart';
import 'package:spartan_dash_flutter/const.dart';
import 'package:spartan_dash_flutter/models/dash_event.dart';
import 'package:spartan_dash_flutter/models/dash_layout.dart';
import 'package:spartan_dash_flutter/models/widgets.dart';
import 'package:spartan_dash_flutter/providers/event_provider.dart';
import 'package:spartan_dash_flutter/widgets/spartan_widget.dart';
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

    windowManager.waitUntilReadyToShow().then((_) async {
      // Hide title bar
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setMinimumSize(const Size(600, 400));
      // Enable transparent (mica) effect
      await Window.setEffect(effect: WindowEffect.mica);
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
    const navTheme = NavigationPaneThemeData(
        backgroundColor: Colors.transparent
    );
    return ProviderScope(
      child: FluentApp(
        theme: FluentThemeData(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          navigationPaneTheme: navTheme,
        ),
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          navigationPaneTheme: navTheme,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
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
      style: ToggleStyle.slider,
      text: "Robot working",
      checked: false
  ),
];

class _HomePageState extends State<HomePage> {
  final layout = const DashLayout(
    columns: 3,
    rows: 2,
    widgets: [
      WidgetPlacement.split(
        widgetUuid: "0",
        column: 0,
        row: 0,
        position: SplitPosition.top,
      ),
      WidgetPlacement.split(
        widgetUuid: "0",
        column: 0,
        row: 0,
        position: SplitPosition.bottom,
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

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitleBar(),
        Expanded(
          child: SafeArea(
            child: NavigationView(
              pane: NavigationPane(
                selected: selectedIndex,
                onChanged: (index) => setState(() => selectedIndex = index),
                displayMode: PaneDisplayMode.compact,
                items: [
                  PaneItemHeader(header: const Text("Tabs")),
                  PaneItem(
                      icon: Icon(material.Icons.tab),
                    title: Text("Tab 1"),
                    body: _buildGrid()
                  ),
                  PaneItem(
                    icon: Icon(material.Icons.tab),
                    title: Text("Tab 2"),
                    body: _buildGrid()
                  )
                ],
                footerItems: [
                  PaneItemHeader(header: const Text("More")),
                  PaneItem(
                      icon: Icon(FluentIcons.settings),
                      title: Text("Settings"),
                      body: _buildGrid()
                  ),
                ]
              )
            )
          )
        ),
      ],
    );
  }

  Widget _buildTitleBar() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => SizedBox(
        height: kMacOSTitleBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final events = ref.watch(eventProvider);
                return events.when(
                    loading: () => const ProgressRing(),
                    error: (error, st) => Text(error.toString()),
                    data: (event) {
                      if (event is DashLayoutEvent) {
                        return Text(event.layout.toString());
                      } else if (event is WidgetEvent) {
                        return Text(event.widget.name);
                      } else {
                        return Container();
                      }
                    }
                );
              },
            ),
            // Text(kAppTitle)
          ],
        ),
      ),
      TargetPlatform.windows => SizedBox(
        height: kWindowsTitleBarHeight,
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: kWindowsTitlePadding),
                child: Text(kAppTitle),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: kWindowsTitleBarHeight,
                child: WindowCaption(
                  brightness: FluentTheme.of(context).brightness,
                  backgroundColor: Colors.transparent,
                ),
              ),
            )
          ],
        ),
      ),
      _ => Container()
    };
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth ~/ kWidgetWidth;
        final rows = constraints.maxHeight ~/ kWidgetHeight;

        return Padding(
          padding: const EdgeInsets.all(kGridPadding).copyWith(top: 2),
          child: SpannableGrid(
            columns: columns * 2,
            rows: rows * 2,
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
            ).map((placement) {
              var columnSpan = 1;
              var rowSpan = 1;
              if (placement is FullWidgetPlacement) {
                columnSpan = placement.columnSpan;
                rowSpan = placement.rowSpan;
              }

              // Clamp the span to within the grid.
              columnSpan = columnSpan.clamp(1, columns - placement.column);
              rowSpan = rowSpan.clamp(1, rows - placement.row);

              return SpannableGridCellData(
                id: placement,
                column: (placement.column * 2) + 1,
                row: (placement.row * 2) +
                    ((placement is SplitWidgetPlacement
                        && placement.position == SplitPosition.bottom
                    ) ? 2 : 1),
                columnSpan: columnSpan * 2,
                rowSpan: rowSpan * ((placement is SplitWidgetPlacement) ? 1 : 2),
                child: SpartanWidget(placement.widgetUuid),
              );
            }).toList(),
          ),
        );
      }
    );
  }
}
