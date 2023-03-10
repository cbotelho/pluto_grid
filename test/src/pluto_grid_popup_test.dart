import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';
import '../helper/test_helper_util.dart';
import '../matcher/pluto_object_matcher.dart';
import '../mock/mock_methods.dart';

void main() {
  const buttonText = 'open grid popup';

  const columnWidth = PlutoGridSettings.columnWidth;

  late PlutoGridStateManager stateManager;

  Future<void> build({
    required WidgetTester tester,
    List<PlutoColumn> columns = const [],
    List<PlutoRow> rows = const [],
    List<PlutoColumnGroup>? columnGroups,
    PlutoOnChangedEventCallback? onChanged,
    PlutoOnSelectedEventCallback? onSelected,
    PlutoOnSortedEventCallback? onSorted,
    PlutoOnRowCheckedEventCallback? onRowChecked,
    PlutoOnRowDoubleTapEventCallback? onRowDoubleTap,
    PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap,
    PlutoOnRowsMovedEventCallback? onRowsMoved,
    PlutoOnColumnsMovedEventCallback? onColumnsMoved,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    Widget? noRowsWidget,
    PlutoRowColorCallback? rowColorCallback,
    PlutoColumnMenuDelegate? columnMenuDelegate,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
    PlutoGridMode mode = PlutoGridMode.normal,
    TextDirection textDirection = TextDirection.ltr,
  }) async {
    await TestHelperUtil.changeWidth(
      tester: tester,
      width: 1000,
      height: 450,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Directionality(
            textDirection: textDirection,
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    PlutoGridPopup(
                      context: context,
                      columns: columns,
                      rows: rows,
                      columnGroups: columnGroups,
                      onLoaded: (event) => stateManager = event.stateManager,
                      onChanged: onChanged,
                      onSelected: onSelected,
                      onSorted: onSorted,
                      onRowChecked: onRowChecked,
                      onRowDoubleTap: onRowDoubleTap,
                      onRowSecondaryTap: onRowSecondaryTap,
                      onRowsMoved: onRowsMoved,
                      onColumnsMoved: onColumnsMoved,
                      createHeader: createHeader,
                      createFooter: createFooter,
                      noRowsWidget: noRowsWidget,
                      rowColorCallback: rowColorCallback,
                      columnMenuDelegate: columnMenuDelegate,
                      configuration: configuration,
                      mode: mode,
                    );
                  },
                  child: const Text(buttonText),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'Directionality.ltr ??? ??????, '
      'stateManager.isLTR, isRTL ??? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.ltr,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, true);
    expect(stateManager.isRTL, false);
  });

  testWidgets(
      'Directionality.rtl ??? ??????, '
      'stateManager.isLTR, isRTL ??? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      textDirection: TextDirection.rtl,
    );

    await tester.tap(find.text(buttonText));

    await tester.pumpAndSettle();

    expect(stateManager.isLTR, false);
    expect(stateManager.isRTL, true);
  });

  testWidgets(
    'Directionality.rtl ??? ?????? ????????? ????????? RTL ?????? ????????? ??????.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstColumn = find.text('title0');
      final firstStartPosition = tester.getTopRight(firstColumn);

      final secondColumn = find.text('title1');
      final secondStartPosition = tester.getTopRight(secondColumn);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll.horizontal!.offset;

      final lastColumn = find.text('title9');
      final lastStartPosition = tester.getTopRight(lastColumn);

      // ?????? ????????? dx ??? ????????? ????????? ?????? ?????? ????????? ????????? ?????? ?????? ?????? ??????.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // ????????? ????????? ?????? 9??? ????????? ???????????? ???????????? ??? ????????? ??????.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets(
    'Directionality.rtl ??? ?????? ?????? ????????? RTL ?????? ????????? ??????.',
    (tester) async {
      final columns = ColumnHelper.textColumn('title', count: 10);
      final rows = RowHelper.count(10, columns);

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        textDirection: TextDirection.rtl,
      );

      await tester.tap(find.text(buttonText));

      await tester.pumpAndSettle();

      final firstCell = find.text('title0 value 0');
      final firstStartPosition = tester.getTopRight(firstCell);

      final secondCell = find.text('title1 value 0');
      final secondStartPosition = tester.getTopRight(secondCell);

      stateManager.moveScrollByColumn(PlutoMoveDirection.right, 8);
      await tester.pumpAndSettle();

      final scrollOffset = stateManager.scroll.horizontal!.offset;

      final lastCell = find.text('title9 value 0');
      final lastStartPosition = tester.getTopRight(lastCell);

      // ?????? ?????? dx ??? ????????? ????????? ?????? ?????? ????????? ?????? ?????? ?????? ?????? ??????.
      expect(firstStartPosition.dx - secondStartPosition.dx, columnWidth);

      // ????????? ?????? ?????? 9??? ?????? ???????????? ???????????? ??? ????????? ??????.
      expect(
        firstStartPosition.dx - lastStartPosition.dx,
        (columnWidth * 9) - scrollOffset,
      );
    },
  );

  testWidgets('??? ?????? ?????? ?????? onChanged ????????? ???????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnChangedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onChanged: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    await tester.tap(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();
    await tester.enterText(cell, 'test value');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.value, 'test value');
    expect(event!.columnIdx, 0);
    expect(event!.rowIdx, 0);
  });

  testWidgets('mode ??? select ??? ???????????? ?????? ?????? ????????? onSelected ????????? ?????? ????????? ??????.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSelectedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSelected: (e) => event = e,
      mode: PlutoGridMode.select,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title1 value 3');
    await tester.tap(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 3);
    expect(event!.cell!.value, 'title1 value 3');
  });

  testWidgets('mode ??? selectWithOneTap ??? ???????????? ?????? ????????? onSelected ????????? ?????? ????????? ??????.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSelectedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSelected: (e) => event = e,
      mode: PlutoGridMode.selectWithOneTap,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2 value 4');
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 4);
    expect(event!.cell!.value, 'title2 value 4');
  });

  testWidgets('????????? ????????? onSorted ????????? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnSortedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onSorted: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2');
    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.ascending);
    expect(event!.oldSort, PlutoColumnSort.none);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.descending);
    expect(event!.oldSort, PlutoColumnSort.ascending);

    await tester.tap(cell);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.column.title, 'title2');
    expect(event!.column.sort, PlutoColumnSort.none);
    expect(event!.oldSort, PlutoColumnSort.descending);
  });

  testWidgets(
      'PlutoColumn.enableRowChecked ??? true ??? ???????????? '
      '?????? ??????????????? ?????? ?????? onRowChecked ????????? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowChecked = true;

    PlutoGridOnRowCheckedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowChecked: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 1');
    final checkbox = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(PlutoBaseCell)),
      matching: find.byType(Checkbox),
    );
    await tester.tap(checkbox);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 1);
    expect(event!.isChecked, true);
    expect(event!.isAll, false);
    expect(event!.isRow, true);
  });

  testWidgets('?????? ?????? ????????? onRowDoubleTap ????????? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnRowDoubleTapEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowDoubleTap: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title2 value 2');
    await tester.tap(cell);
    await tester.pump(kDoubleTapMinTime);
    await tester.tap(cell);
    await tester.pumpAndSettle();

    expect(event, isNotNull);
    expect(event!.rowIdx, 2);
    expect(event!.cell.value, 'title2 value 2');
  });

  testWidgets('Secondary ????????? ????????? onRowSecondaryTap ????????? ?????? ????????? ??????.',
      (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    PlutoGridOnRowSecondaryTapEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowSecondaryTap: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title3 value 5');
    await tester.tap(cell, buttons: kSecondaryButton);
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.rowIdx, 5);
    expect(event!.cell.value, 'title3 value 5');
  });

  testWidgets('?????? ????????? ?????? onRowsMoved ????????? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    columns[0].enableRowDrag = true;

    PlutoGridOnRowsMovedEvent? event;

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onRowsMoved: (e) => event = e,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final cell = find.text('title0 value 0');
    final dragIcon = find.descendant(
      of: find.ancestor(of: cell, matching: find.byType(PlutoBaseCell)),
      matching: find.byType(Icon),
    );
    // ??? ?????? ?????? 45 * 2 (2??? ??? ????????? ?????????)
    await tester.drag(dragIcon, const Offset(0, 90));
    await tester.pump();

    expect(event, isNotNull);
    expect(event!.idx, 2);
    expect(event!.rows.length, 1);
    expect(event!.rows[0].cells['title0']!.value, 'title0 value 0');
  });

  testWidgets('createHeader ????????? ????????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final headerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createHeader: (_) => ColoredBox(color: Colors.cyan, key: headerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final header = find.byKey(headerKey);
    expect(header, findsOneWidget);
  });

  testWidgets('createFooter ????????? ????????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    final footerKey = GlobalKey();

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      createFooter: (_) => ColoredBox(color: Colors.cyan, key: footerKey),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final footer = find.byKey(footerKey);
    expect(footer, findsOneWidget);
  });

  testWidgets('rowColorCallback ??? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      configuration: const PlutoGridConfiguration(
          style: PlutoGridStyleConfig(
        enableRowColorAnimation: true,
      )),
      rowColorCallback: (context) {
        return context.rowIdx % 2 == 0 ? Colors.pink : Colors.cyan;
      },
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final containers = find
        .descendant(
          of: find.byType(PlutoBaseRow),
          matching: find.byType(AnimatedContainer),
        )
        .evaluate();

    final colors = containers.map(
      (e) =>
          ((e.widget as AnimatedContainer).decoration as BoxDecoration).color,
    );

    expect(colors.elementAt(0), Colors.pink);
    expect(colors.elementAt(1), Colors.cyan);
    expect(colors.elementAt(2), Colors.pink);
    expect(colors.elementAt(3), Colors.cyan);
  });

  testWidgets('columnMenuDelegate ??? ?????? ??? ?????? ?????? ????????? ?????? ????????? ??????.', (tester) async {
    final columns = ColumnHelper.textColumn('title', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      columnMenuDelegate: _TestColumnMenu(),
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final column = find.text('title0');
    final menuIcon = find.descendant(
      of: find.ancestor(of: column, matching: find.byType(PlutoBaseColumn)),
      matching: find.byType(PlutoGridColumnIcon),
    );

    await tester.tap(menuIcon);
    await tester.pump();

    expect(find.text('test menu 1'), findsOneWidget);
    expect(find.text('test menu 2'), findsOneWidget);
  });

  testWidgets('????????? ?????? ?????? ?????? onColumnsMoved ????????? ?????? ????????? ??????.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    stateManager.toggleFrozenColumn(columns[1], PlutoColumnFrozen.start);
    await tester.pump();

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 1 && e.visualIdx == 0 && e.columns.length == 1;
    }))).called(1);
  });

  testWidgets('????????? ?????? ?????? ?????? onColumnsMoved ????????? ?????? ????????? ??????.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    stateManager.toggleFrozenColumn(columns[1], PlutoColumnFrozen.end);
    await tester.pump();

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 1 && e.visualIdx == 9 && e.columns.length == 1;
    }))).called(1);
  });

  testWidgets('????????? ??????????????? ???????????? onColumnsMoved ????????? ?????? ????????? ??????.', (tester) async {
    final mock = MockMethods();
    final columns = ColumnHelper.textColumn('column', count: 10);
    final rows = RowHelper.count(10, columns);

    await build(
      tester: tester,
      columns: columns,
      rows: rows,
      onColumnsMoved: mock.oneParamReturnVoid<PlutoGridOnColumnsMovedEvent>,
    );

    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();

    final sampleColumn = find.text('column1');

    await tester.drag(sampleColumn, const Offset(400, 0));

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(mock.oneParamReturnVoid(
        PlutoObjectMatcher<PlutoGridOnColumnsMovedEvent>(rule: (e) {
      return e.idx == 3 && e.visualIdx == 3 && e.columns.length == 1;
    }))).called(1);
  });

  group('noRowsWidget', () {
    testWidgets('?????? ?????? ?????? noRowsWidget ??? ????????? ????????? ??????.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <PlutoRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('?????? ???????????? ?????? noRowsWidget ??? ????????? ????????? ??????.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = RowHelper.count(10, columns);
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsNothing);

      stateManager.removeAllRows();

      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);
    });

    testWidgets('?????? ???????????? ?????? noRowsWidget ??? ????????? ?????? ????????? ??????.', (tester) async {
      final columns = ColumnHelper.textColumn('column', count: 10);
      final rows = <PlutoRow>[];
      const noRowsWidget = Center(
        key: ValueKey('NoRowsWidget'),
        child: Text('There are no rows.'),
      );

      await build(
        tester: tester,
        columns: columns,
        rows: rows,
        noRowsWidget: noRowsWidget,
      );

      await tester.tap(find.text(buttonText));
      await tester.pumpAndSettle();

      expect(find.byKey(noRowsWidget.key!), findsOneWidget);

      stateManager.appendNewRows();

      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      expect(find.byKey(noRowsWidget.key!), findsNothing);
    });
  });
}

class _TestColumnMenu implements PlutoColumnMenuDelegate {
  @override
  List<PopupMenuEntry> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return [
      const PopupMenuItem(
        value: 'test1',
        height: 36,
        enabled: true,
        child: Text('test menu 1'),
      ),
      const PopupMenuItem(
        value: 'test2',
        height: 36,
        enabled: true,
        child: Text('test menu 2'),
      ),
    ];
  }

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required selected,
  }) {}
}
