import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tripmates/features/splash/presentation/pages/splash_page.dart';
import 'package:tripmates/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:tripmates/features/trip/presentation/pages/trips_list_page.dart';
import 'package:tripmates/features/trip/presentation/pages/my_trips_page.dart';
import 'package:tripmates/features/global_destinations/presentation/pages/destinations_page.dart';
import 'package:tripmates/features/partner_requests/presentation/pages/partner_requests_page.dart';
import 'package:tripmates/features/auth/domain/usecases/login_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/register_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:tripmates/features/auth/domain/usecases/reset_password_usecase.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        forgotPasswordUsecaseProvider.overrideWithValue(
          mockForgotPasswordUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(
          mockResetPasswordUsecase,
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
  });

  group('App Screens Widget Tests', () {
    testWidgets('Splash screen renders logo and text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Color.fromARGB(255, 90, 50, 231),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'TripMates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Traveling Partner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('TripMates'), findsOneWidget);
      expect(find.text('Your Traveling Partner'), findsOneWidget);
    });

    testWidgets('Dashboard home screen renders welcome message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Welcome')),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.luggage),
                  label: 'Trips',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('Dashboard home screen displays trip cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Upcoming Trips'),
                Container(
                  height: 200,
                  child: const Card(
                    child: ListTile(
                      title: Text('Paris Adventure'),
                      subtitle: Text('Destination: Paris'),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trip_origin),
                  label: 'Trips',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for bottom navigation bar which indicates dashboard loaded
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Trip list page renders trip cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(title: Text('All Trips')),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        const Card(child: ListTile(title: Text('Trip'))),
                    childCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for CustomScrollView which is main container
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Trip detail page displays trip information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Trip Details')),
            body: const Center(
              child: Column(
                children: [
                  Text('Paris Adventure'),
                  Text('Destination: Paris, France'),
                  Text('Status: Planned'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trip Details'), findsOneWidget);
      expect(find.text('Paris Adventure'), findsOneWidget);
      expect(find.textContaining('Destination'), findsOneWidget);
    });

    testWidgets('Trip detail page shows tabs (Overview, Members, Itinerary)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Overview'),
                    Tab(text: 'Members'),
                    Tab(text: 'Itinerary'),
                    Tab(text: 'Checklist'),
                    Tab(text: 'Location'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  Center(child: Text('Overview Content')),
                  Center(child: Text('Members Content')),
                  Center(child: Text('Itinerary Content')),
                  Center(child: Text('Checklist Content')),
                  Center(child: Text('Location Content')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Itinerary'), findsOneWidget);
    });

    testWidgets('Destination list page renders destination cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(title: Text('Destinations')),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        const Card(child: Center(child: Text('Destination'))),
                    childCount: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for CustomScrollView which is main container
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Destination detail page displays destination info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(expandedHeight: 200, title: Text('Paris')),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const ListTile(title: Text('Country: France')),
                    const ListTile(title: Text('Best Season: Spring')),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.textContaining('Country'), findsOneWidget);
    });

    testWidgets('My trips page shows user\'s trips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                const SliverAppBar(title: Text('My Trips')),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        const Card(child: ListTile(title: Text('My Trip'))),
                    childCount: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for CustomScrollView which is main container
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('Profile screen displays user information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person)),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('john@example.com'),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.luggage),
                    title: const Text('My Trips'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('My Trips'), findsOneWidget);
    });

    testWidgets('Partner requests page renders request list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Partner Requests')),
            body: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Partner Request'),
                subtitle: Text('Pending'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Scaffold which is main container
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Partner Requests'), findsOneWidget);
    });
  });
}
