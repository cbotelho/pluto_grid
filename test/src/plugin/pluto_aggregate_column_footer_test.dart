import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;

  late PublishSubject<PlutoNotifierEvent> subject;

  buildWidget({
    required PlutoColumn column,
    required FilteredList<PlutoRow> rows,
    required PlutoAggregateColumnType type,
    PlutoAggregateColumnGroupedRowType groupedRowType =
        PlutoAggregateColumnGroupedRowType.all,
    PlutoAggregateColumnIterateRowType iterateRowType =
        PlutoAggregateColumnIterateRowType.filteredAndPaginated,
    PlutoAggregateFilter? filter,
    String? locale,
    String? format,
    List<InlineSpan> Function(String)? titleSpanBuilder,
    AlignmentGeometry? alignment,
    EdgeInsets? padding,
    bool enabledRowGroups = false,
  }) {
    return PlutoWidgetTestHelper('PlutoAggregateColumnFooter : ',
        (tester) async {
      stateManager = MockPlutoGridStateManager();

      subject = PublishSubject<PlutoNotifierEvent>();

      when(stateManager.streamNotifier).thenAnswer((_) => subject);

      when(stateManager.configuration)
          .thenReturn(const PlutoGridConfiguration());

      when(stateManager.refRows).thenReturn(rows);

      when(stateManager.enabledRowGroups).thenReturn(enabledRowGroups);

      when(stateManager.iterateAllMainRowGroup)
          .thenReturn(rows.originalList.where((r) => r.isMain));

      when(stateManager.iterateFilteredMainRowGroup)
          .thenReturn(rows.filterOrOriginalList.where((r) => r.isMain));

      when(stateManager.iterateMainRowGroup)
          .thenReturn(rows.where((r) => r.isMain));

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoAggregateColumnFooter(
              rendererContext: PlutoColumnFooterRendererContext(
                stateManager: stateManager,
                column: column,
              ),
              type: type,
              groupedRowType: groupedRowType,
              iterateRowType: iterateRowType,
              filter: filter,
              format: format ?? '#,###',
              locale: locale,
              titleSpanBuilder: titleSpanBuilder,
              alignment: alignment,
              padding: padding,
            ),
          ),
        ),
      );
    });
  }

  group('number ??????.', () {
    final columns = [
      PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.sum,
    ).test('?????? ?????? ?????? sum ?????? 0??? ????????? ??????.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.average,
    ).test('?????? ?????? ?????? average ?????? 0??? ????????? ??????.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.min,
    ).test('?????? ?????? ?????? min ?????? ??????????????? ??????????????? ??????.', (tester) async {
      final found = find.text('');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.max,
    ).test('?????? ?????? ?????? max ?????? ??????????????? ??????????????? ??????.', (tester) async {
      final found = find.text('');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: []),
      type: PlutoAggregateColumnType.count,
    ).test('?????? ?????? ?????? max ?????? 0??? ??????????????? ??????.', (tester) async {
      final found = find.text('0');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
    ).test('?????? ?????? ?????? sum ?????? ????????? ?????? 6,000??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('6,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.average,
    ).test('?????? ?????? ?????? average ?????? ????????? ?????? 2,000??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('2,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.min,
    ).test('?????? ?????? ?????? min ?????? ????????? ?????? 1,000??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('1,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.max,
    ).test('?????? ?????? ?????? max ?????? ????????? ?????? 3,000??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('3,000');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
    ).test('?????? ?????? ?????? count ?????? ????????? ?????? 3??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('3');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
      filter: (cell) => cell.value > 1000,
    ).test('filter ??? ?????? ??? ?????? count ?????? ?????? ????????? ?????? 2??? ?????? ????????? ??????.', (tester) async {
      final found = find.text('2');

      expect(found, findsOneWidget);
    });

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.count,
      format: 'Total : #,###',
    ).test(
      '?????? ?????? ?????? count ?????? ????????? ????????? ?????? Total : 3??? ?????? ????????? ??????.',
      (tester) async {
        final found = find.text('Total : 3');

        expect(found, findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      titleSpanBuilder: (text) {
        return [
          const WidgetSpan(child: Text('Left ')),
          WidgetSpan(child: Text('Value : $text')),
          const WidgetSpan(child: Text(' Right')),
        ];
      },
    ).test(
      'titleSpanBuilder ??? ?????? ?????? sum ?????? ????????? ????????? ?????? '
      'Left Value : 6,000 Right ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Left '), findsOneWidget);
        expect(find.text('Value : 6,000'), findsOneWidget);
        expect(find.text(' Right'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
    ).test(
      '????????? ?????? ??? ?????? ?????? ??? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
    ).test(
      '????????????????????? ?????? ??? ?????? ?????????????????? ??? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('3,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
    ).test(
      'iterateRowType ??? all ??? ?????? ????????????????????? ??????????????? ?????? ?????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000)
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.filtered,
    ).test(
      'iterateRowType ??? filtered ??? ?????? ?????????????????? ??? ????????? ???????????? ????????? ??? ????????? ????????? ?????? ?????? ??????.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(cells: {'column': PlutoCell(value: 1000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
    ).test(
      'iterateRowType ??? all ??? ?????? ????????? ??????????????? ?????? ?????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('6,000'), findsOneWidget);
      },
    );
  });

  group('RowGroups', () {
    final columns = [
      PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.number(),
      ),
    ];

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
                children: FilteredList(
              initialList: [
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
              ],
            ))),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? all ??? ?????? '
      'Value : 10,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
                children: FilteredList(
              initialList: [
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
              ],
            ))),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? expandedAll ?????? ???????????? ????????? ?????? '
      'Value : 6,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 6,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedAll,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? expandedAll ?????? ???????????? ????????? ?????? '
      'Value : 10,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.rows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? rows ??? ?????? '
      'Value : 9,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 9,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: false,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? expandedRows ?????? ???????????? ????????? ?????? '
      'Value : 5,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ]),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.expandedRows,
      enabledRowGroups: true,
      titleSpanBuilder: (text) {
        return [
          WidgetSpan(child: Text('Value : $text')),
        ];
      },
    ).test(
      'GroupedRowType ??? expandedRows ?????? ???????????? ????????? ?????? '
      'Value : 9,000 ??? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('Value : 9,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      '????????? ?????? ??? ?????? ????????? ?????? ??? ????????? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      '????????????????????? ?????? ??? ?????? ?????????????????? ??? ????????? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('7,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.all,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'iterateRowType ??? all ??? ?????? ????????? ??????????????? ?????? ?????? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('10,000'), findsOneWidget);
      },
    );

    buildWidget(
      column: columns.first,
      rows: FilteredList<PlutoRow>(initialList: [
        PlutoRow(
            cells: {'column': PlutoCell(value: 1000)},
            type: PlutoRowType.group(
              children: FilteredList(
                initialList: [
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                  PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
                ],
              ),
              expanded: true,
            )),
        PlutoRow(cells: {'column': PlutoCell(value: 2000)}),
        PlutoRow(cells: {'column': PlutoCell(value: 3000)}),
      ])
        ..setFilter((element) => element.cells['column']!.value > 1000)
        ..setFilterRange(FilteredListRange(0, 2)),
      type: PlutoAggregateColumnType.sum,
      iterateRowType: PlutoAggregateColumnIterateRowType.filtered,
      groupedRowType: PlutoAggregateColumnGroupedRowType.all,
      enabledRowGroups: true,
    ).test(
      'iterateRowType ??? filtered ??? ?????? ????????????????????? ???????????? ????????? ??? ????????? ????????? ?????? ????????? ??????.',
      (tester) async {
        expect(find.text('5,000'), findsOneWidget);
      },
    );
  });
}
