import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../helper/pluto_widget_test_helper.dart';
import '../matcher/pluto_object_matcher.dart';
import '../mock/mock_methods.dart';

final now = DateTime.now();

final mockListener = MockMethods();

void main() {
  late PlutoGridStateManager stateManager;

  buildPopup({
    required String format,
    required String headerFormat,
    DateTime? initDate,
    DateTime? startDate,
    DateTime? endDate,
    PlutoOnLoadedEventCallback? onLoaded,
    PlutoOnSelectedEventCallback? onSelected,
    double? itemHeight,
    PlutoGridConfiguration? configuration,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    final dateFormat = intl.DateFormat(format);

    final headerDateFormat = intl.DateFormat(headerFormat);

    return PlutoWidgetTestHelper('Build date picker.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Directionality(
              textDirection: textDirection,
              child: Builder(
                builder: (BuildContext context) {
                  return TextButton(
                    onPressed: () {
                      PlutoGridDatePicker(
                        context: context,
                        dateFormat: dateFormat,
                        headerDateFormat: headerDateFormat,
                        initDate: initDate,
                        startDate: startDate,
                        endDate: endDate,
                        onLoaded: onLoaded,
                        onSelected: onSelected,
                        itemHeight:
                            itemHeight ?? PlutoGridSettings.rowTotalHeight,
                        configuration:
                            configuration ?? const PlutoGridConfiguration(),
                      );
                    },
                    child: const Text('open date picker'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();
    });
  }

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'Directionality ??? ????????? ltr ????????? ??????.',
    (tester) async {
      expect(stateManager.isLTR, true);
      expect(stateManager.isRTL, false);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
    textDirection: TextDirection.rtl,
  ).test(
    'Directionality.rtl ??? ?????? ?????? ????????? ??????.',
    (tester) async {
      expect(stateManager.isLTR, false);
      expect(stateManager.isRTL, true);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 7, 27),
    textDirection: TextDirection.rtl,
  ).test(
    'Directionality.rtl ??? ?????? ?????? ?????? ????????? LTR ????????? ?????? ????????? ??????.',
    (tester) async {
      final day26 = find.ancestor(
        of: find.text('26'),
        matching: find.byType(PlutoBaseCell),
      );
      final day27 = find.ancestor(
        of: find.text('27'),
        matching: find.byType(PlutoBaseCell),
      );
      final day28 = find.ancestor(
        of: find.text('28'),
        matching: find.byType(PlutoBaseCell),
      );

      final day26Dx = tester.getTopRight(day26).dx;
      final day27Dx = tester.getTopRight(day27).dx;
      final day28Dx = tester.getTopRight(day28).dx;

      // ?????? ??????(??????)??? ?????? 26??? ???????????? ?????? ????????? ?????? 27??? ????????? ?????? ??? ??????.
      expect(day26Dx - day27Dx, PlutoGridDatePicker.dateCellWidth);
      expect(day27Dx - day28Dx, PlutoGridDatePicker.dateCellWidth);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    onLoaded: (event) => stateManager = event.stateManager,
  ).test(
    'DatePicker ??? autoSizeMode, resizeMode ??? ???????????? ????????? ??????.',
    (tester) async {
      expect(stateManager.enableColumnsAutoSize, false);

      expect(stateManager.activatedColumnsAutoSize, false);

      expect(
        stateManager.columnSizeConfig.autoSizeMode,
        PlutoAutoSizeMode.none,
      );

      expect(
        stateManager.columnSizeConfig.resizeMode,
        PlutoResizeMode.none,
      );
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '????????? ????????? ???????????? ????????? ?????? ????????? ??????.',
    (tester) async {
      final size = tester.getSize(find.byType(PlutoGrid));

      // 45 : ?????? ??? ??????, 7 : ???~???
      expect(size.width, greaterThan(45 * 7));

      // 6?????? ?????? ????????????.
      double rowsHeight = 6 * PlutoGridSettings.rowTotalHeight;

      // itemHeight * 2 = Header Height + Column Height
      double popupHeight = (PlutoGridSettings.rowTotalHeight * 2) +
          rowsHeight +
          PlutoGridSettings.totalShadowLineWidth +
          PlutoGridSettings.gridInnerSpacing;

      expect(size.height, popupHeight);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '???,?????? ???????????? IconButton ??? ?????? ????????? ??????.',
    (tester) async {
      expect(find.byType(IconButton), findsNWidgets(4));
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'initDate, startDate, endDate ??? ?????? ?????? ?????? ??????, '
    '?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(now);

      const firstDay = '1';

      expect(find.text(currentYearMonth), findsOneWidget);

      expect(find.text(firstDay), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    startDate: DateTime(2022, 5, 10),
  ).test(
    'startDate ??? ????????? ?????? ?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(DateTime(2022, 5, 10));

      expect(find.text(currentYearMonth), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(now.year, now.month, 20),
  ).test(
    'initDate ??? ????????? ?????? ?????? ????????? ?????? ????????? ??????.',
    (tester) async {
      const selectedDay = '20';

      final selectedDayText = find.text(selectedDay).first;

      final selectedDayTextWidget =
          selectedDayText.first.evaluate().first.widget as Text;

      final selectedDayTextStyle = selectedDayTextWidget.style as TextStyle;

      expect(selectedDayText, findsOneWidget);

      expect(selectedDayTextStyle.color, Colors.white);

      final selectedDayWidget = find
          .ancestor(
            of: selectedDayText,
            matching: find.byType(DecoratedBox),
          )
          .first;

      final selectedDayContainer =
          selectedDayWidget.first.evaluate().first.widget as DecoratedBox;

      final decoration = selectedDayContainer.decoration as BoxDecoration;

      expect(selectedDayWidget, findsOneWidget);

      expect(decoration.color, Colors.lightBlue);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '?????? ????????? 1?????? ???????????? ????????? ????????? ?????? ?????????, '
    '?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(now);

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('1'));

      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month - 1);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 30),
  ).test(
    '2022.6.30 ?????? ???????????? ????????? ????????? ????????? ????????????, '
    '?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 30));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);

      await tester.pumpAndSettle();

      final expectDate = DateTime(2022, 7);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 5),
  ).test(
    '2022.6.5 ?????? ???????????? ????????? ????????? ????????? ????????????, '
    '?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 5));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);

      await tester.pump();

      final expectDate = DateTime(2021, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
  ).test(
    '2022.6.11 ?????? ???????????? ????????? ????????? ???????????? ????????????, '
    '?????? ?????? ?????? ????????? ??????.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 11));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);

      await tester.pump();

      final expectDate = DateTime(2023, 6);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onSelected: mockListener.oneParamReturnVoid<PlutoGridOnSelectedEvent>,
  ).test(
    '2022.6.11 ?????? ???????????? ?????????, '
    'onSelected ????????? ?????? ????????? ??????.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.oneParamReturnVoid(argThat(
            PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (object) {
          return object.cell!.value == '2022-06-11';
        }))),
      ).called(1);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onLoaded: mockListener.oneParamReturnVoid<PlutoGridOnLoadedEvent>,
  ).test(
    '2022.6.11 ?????? ???????????? ?????????, '
    'onSelected ????????? ?????? ????????? ??????.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.oneParamReturnVoid(
          argThat(
            isA<PlutoGridOnLoadedEvent>(),
          ),
        ),
      ).called(1);
    },
  );
}
