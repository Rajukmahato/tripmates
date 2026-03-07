import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Tests - Basic Smoke Tests', () {
    testWidgets('MaterialApp can be created', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      );
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Scaffold with AppBar renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test App')),
            body: const Center(child: Text('Body')),
          ),
        ),
      );
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('Text input field works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TextField(
                decoration: InputDecoration(hintText: 'Enter text'),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Button can be tapped', (WidgetTester tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => tapCount++,
                child: const Text('Tap Me'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapCount, 1);
    });

    testWidgets('ListView renders items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => Text('Item $index'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('Floating action button renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Body')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Form with validation works', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TextFormField(
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('Dialog can be shown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const Text('Home'))),
      );

      showDialog(
        context: tester.element(find.byType(Scaffold)),
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Test Dialog'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Test Dialog'), findsOneWidget);
    });

    testWidgets('CircularProgressIndicator animates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('IconButton can be tapped', (WidgetTester tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: IconButton(
                onPressed: () => tapCount++,
                icon: const Icon(Icons.favorite),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets('Checkbox toggles value', (WidgetTester tester) async {
      bool isChecked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(isChecked, isTrue);
    });

    testWidgets('Switch toggles value', (WidgetTester tester) async {
      bool isOn = false;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Switch(
                value: isOn,
                onChanged: (value) {
                  setState(() {
                    isOn = value;
                  });
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(isOn, isTrue);
    });

    testWidgets('Slider updates value', (WidgetTester tester) async {
      double sliderValue = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pump();
      expect(sliderValue, greaterThan(0));
    });

    testWidgets('DropdownButton changes selected item', (
      WidgetTester tester,
    ) async {
      String selectedValue = 'One';
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: DropdownButton<String>(
                value: selectedValue,
                items: const [
                  DropdownMenuItem(value: 'One', child: Text('One')),
                  DropdownMenuItem(value: 'Two', child: Text('Two')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedValue = value ?? 'One';
                  });
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Two').last);
      await tester.pumpAndSettle();
      expect(selectedValue, 'Two');
    });

    testWidgets('Navigator pushes new page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Second Page')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go Next'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go Next'));
      await tester.pumpAndSettle();
      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('Navigator pops back to first page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (innerContext) => Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(innerContext).pop(),
                              child: const Text('Back'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Page'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Page'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open Page'), findsOneWidget);
    });

    testWidgets('SnackBar is shown after button tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Saved')));
                  },
                  child: const Text('Show SnackBar'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('ExpansionTile expands and shows content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExpansionTile(
              title: Text('More'),
              children: [Text('Expanded Content')],
            ),
          ),
        ),
      );

      expect(find.text('Expanded Content'), findsNothing);
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Expanded Content'), findsOneWidget);
    });

    testWidgets('BottomNavigationBar changes selected index', (
      WidgetTester tester,
    ) async {
      int currentIndex = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(currentIndex, 1);
    });
  });
}
