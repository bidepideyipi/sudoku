import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku/data/models/sudoku_puzzle.dart';
import 'package:sudoku/logic/providers/sudoku_game_provider.dart';
import 'package:sudoku/ui/pages/sudoku_home_page.dart';
import 'package:sudoku/main.dart';

void main() {
  group('Sudoku App Tests', () {
    testWidgets('App starts and displays Sudoku home page',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app displays the Sudoku title.
      expect(find.text('数独'), findsOneWidget);

      // Verify that the grid is displayed
      expect(find.byType(GridView), findsOneWidget);

      // Verify that control buttons are displayed
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb), findsOneWidget);
    });

    testWidgets('Provider initializes with easy puzzle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SudokuGameProvider()..newGame(Difficulty.easy),
          child: const MaterialApp(
            home: SudokuHomePage(),
          ),
        ),
      );

      await tester.pump();

      // Should display the puzzle
      expect(find.text('数独'), findsOneWidget);
    });

    testWidgets('Number pad is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Scroll to the bottom to find the number pad
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify that number buttons are displayed
      expect(find.text('1'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(find.text('9'), findsWidgets);
      expect(find.text('清除'), findsOneWidget);
    });

    testWidgets('New game button is present', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Scroll to find the control buttons
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify new game button exists
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
