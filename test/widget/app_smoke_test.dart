import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noisequest/app.dart';
import 'package:noisequest/data/local/local_store.dart';
import 'package:noisequest/data/remote/api_client.dart';
import 'package:noisequest/domain/enums.dart';
import 'package:noisequest/domain/guild.dart';
import 'package:noisequest/domain/quest.dart';
import 'package:noisequest/domain/user.dart';
import 'package:noisequest/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<void> pumpApp(WidgetTester tester, SharedPreferences prefs) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        tokenStorageProvider.overrideWithValue(TokenStorage()),
      ],
      child: const QuestboardApp(),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('first launch lands on the connect screen', (tester) async {
    final prefs = await prefsWith({});
    await pumpApp(tester, prefs);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.textContaining('QUESTBOARD'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('cached session renders the guild board on desktop', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await prefsWith({
      'settings.launched': true,
      'settings.endpoint': 'http://127.0.0.1:9',
    });
    final store = LocalStore(prefs);
    final now = DateTime.utc(2026, 1, 1);
    await store.writeUser(
      User(
        id: 'u1',
        email: 'ada@example.com',
        username: 'ada',
        displayName: 'Ada',
        bannerPresetId: 'neon_grid',
        totalXp: 150,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await store.writeQuests([
      Quest(
        id: 'q1',
        name: 'Clean kitchen',
        questType: QuestType.task,
        xpReward: 25,
        isRepeatable: false,
        authorId: 'u1',
        authorName: 'Ada',
        status: QuestStatus.available,
        createdAt: now,
        updatedAt: now,
        completionCount: 0,
        myStatus: QuestStatus.available,
        myCompletionCount: 0,
        guild: 'Chores',
      ),
    ]);
    await store.writeGuilds(
      const GuildBreakdown(
        totalXp: 100,
        guilds: [GuildSummary(name: 'Chores', xp: 100, questCount: 1)],
      ),
    );

    await pumpApp(tester, prefs);

    expect(find.text('Guild Board'), findsWidgets);
    expect(find.text('Clean kitchen'), findsOneWidget);
    expect(find.textContaining('Chores'), findsWidgets);
    expect(find.text('Ada'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
