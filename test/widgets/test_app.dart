import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:restaurant_universal_app/core/firebase_providers.dart';
import 'package:restaurant_universal_app/features/auth/application/auth_provider.dart';
import 'package:restaurant_universal_app/l10n/app_localizations.dart';

class FakeUser implements User {
  FakeUser(this.uid, {this.isAnonymous = true});

  @override
  final String uid;

  @override
  final bool isAnonymous;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A signed-in session without Firebase: enough for the repositories, which
/// only need the current uid.
class FakeAuth implements FirebaseAuth {
  FakeAuth(this._user);

  final User? _user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps [child] at `/` inside the real localization and routing setup (in
/// English), backed by [db]. Other paths render a marker text with the path
/// so tests can assert on navigation.
Future<void> pumpTestApp(
  WidgetTester tester, {
  required Widget child,
  required FakeFirebaseFirestore db,
  String uid = 'customer-1',
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => child),
      GoRoute(
        path: '/:rest(.*)',
        builder: (_, state) => Scaffold(body: Text('route:${state.uri.path}')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(db),
        firebaseAuthProvider.overrideWithValue(FakeAuth(FakeUser(uid))),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await settle(tester);
}

/// Lets fake Firestore streams and writes deliver, then rebuilds. Avoids
/// pumpAndSettle, which never returns while a progress indicator spins.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
