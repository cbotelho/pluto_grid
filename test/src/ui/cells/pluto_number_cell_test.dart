import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/ui.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  group('PlutoNumberCell', () {
    late PlutoGridStateManager stateManager;

    buildWidget({
      dynamic number = 0,
      bool negative = true,
      String format = '#,###',
      bool applyFormatOnInit = true,
      bool allowFirstDot = false,
      String locale = 'en_US',
    }) {
      return PlutoWidgetTestHelper('build number cell.', (tester) async {
        Intl.defaultLocale = locale;

        stateManager = MockPlutoGridStateManager();

        when(stateManager.configuration).thenReturn(
          const PlutoGridConfiguration(),
        );

        when(stateManager.isEditing).thenReturn(true);

        when(stateManager.keepFocus).thenReturn(true);

        when(stateManager.keyManager).thenReturn(PlutoGridKeyManager(
          stateManager: stateManager,
        ));

        final PlutoColumn column = PlutoColumn(
          title: 'column title',
          field: 'column_field_name',
          type: PlutoColumnType.number(
            negative: negative,
            format: format,
            applyFormatOnInit: applyFormatOnInit,
            allowFirstDot: allowFirstDot,
          ),
        );

        when(stateManager.currentColumn).thenReturn(column);

        final PlutoCell cell = PlutoCell(value: number);

        final PlutoRow row = PlutoRow(
          cells: {
            'column_field_name': cell,
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoNumberCell(
                stateManager: stateManager,
                cell: cell,
                column: column,
                row: row,
              ),
            ),
          ),
        );
      });
    }

    buildWidget(
      number: 0,
      negative: true,
      format: '#,###',
      applyFormatOnInit: true,
      allowFirstDot: false,
    ).test(
      '????????? 0 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('0'), findsOneWidget);
      },
    );

    buildWidget(
      number: 1234.02,
      negative: true,
      format: '#,###',
      applyFormatOnInit: true,
      allowFirstDot: false,
    ).test(
      'locale ??? ???????????? ?????? 1234.02 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('1234.02'), findsOneWidget);
      },
    );

    buildWidget(
      number: 1234.02,
      negative: true,
      format: '#,###.##',
      applyFormatOnInit: true,
      allowFirstDot: false,
      locale: 'da_DK',
    ).test(
      'locale ??? ????????? ???????????? ???????????? ?????? 1234,02 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('1234,02'), findsOneWidget);
      },
    );
  });

  group('DecimalTextInputFormatter', () {
    updatedValue({
      required String oldValue,
      required String newValue,
      required int decimalRange,
      required bool activatedNegativeValues,
      required bool allowFirstDot,
      String decimalSeparator = '.',
    }) {
      final oldText = TextEditingValue(text: oldValue);

      final newText = TextEditingValue(text: newValue);

      final formatter = DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegativeValues,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      );

      return formatter.formatEditUpdate(oldText, newText).text;
    }

    test(
      'decimalRange ??? 2, decimalSeparator ??? ????????? ?????? 123.01 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '123.01',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
            decimalSeparator: ',',
          ),
          '0',
        );
      },
    );

    test(
      'decimalRange ??? 2, decimalSeparator ??? ????????? ?????? 123,01 ??? ???????????? 123,01 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '123,01',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
            decimalSeparator: ',',
          ),
          '123,01',
        );
      },
    );

    test(
      'decimalRange ??? 0, decimalSeparator ??? ????????? ?????? 123,01 ??? ???????????? 123 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '123',
            newValue: '123,01',
            decimalRange: 0,
            activatedNegativeValues: true,
            allowFirstDot: false,
            decimalSeparator: ',',
          ),
          '123',
        );
      },
    );

    test(
      'decimalRange ??? 2 ??? ???????????? 0.12 ??? ???????????? 0.12 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0.12',
        );
      },
    );

    test(
      'decimalRange ??? 2 ??? ???????????? 0.123 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '0.123',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues ??? true ??? ???????????? -0.12 ??? ???????????? -0.12 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '-0.12',
        );
      },
    );

    test(
      'activatedNegativeValues ??? false ??? ???????????? -0.12 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: false,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues ??? true, allowFirstDot ??? false ??? ????????????, '
      '.0.12 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues ??? true, allowFirstDot ??? true ??? ????????????, '
      '.0.12 ??? ???????????? .0.12 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '.0.12',
        );
      },
    );

    test(
      'activatedNegativeValues ??? true, allowFirstDot ??? true ??? ????????????, '
      '..0.12 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '..0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues ??? true, allowFirstDot ??? true ??? ????????????, '
      '-.0.12 ??? ???????????? 0 ??? ?????? ????????? ??????.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '0',
        );
      },
    );
  });
}
