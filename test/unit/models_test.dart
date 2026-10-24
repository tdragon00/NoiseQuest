import 'package:flutter_test/flutter_test.dart';
import 'package:noisequest/domain/enums.dart';
import 'package:noisequest/domain/quest.dart';
import 'package:noisequest/domain/quest_completion.dart';
import 'package:noisequest/domain/user.dart';

void main() {
  test('user parses wire fields and falls back display name', () {
    final user = User.fromJson({
      'id': 'u1',
      'email': 'a@b.co',
      'username': 'ada',
      'display_name': '',
      'banner_preset_id': 'neon_grid',
      'total_xp': 150,
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    });
    expect(user.displayName, 'ada');
    expect(user.totalXp, 150);
    expect(User.fromJson(user.toJson()).totalXp, 150);
  });

  test('quest parses my_status and repeatable flags', () {
    final json = {
      'id': 'q1',
      'name': 'Clean',
      'quest_type': 'challenge',
      'description': 'Do it',
      'icon': '⚔️',
      'guild': ' Chores ',
      'xp_reward': 30,
      'is_repeatable': true,
      'author_id': 'u1',
      'author_name': 'Ada',
      'status': 'available',
      'my_status': 'in_progress',
      'my_progress_id': 'p1',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    };
    final quest = Quest.fromJson(json);
    expect(quest.questType, QuestType.challenge);
    expect(quest.myStatus, QuestStatus.inProgress);
    expect(quest.guild, 'Chores');
    expect(quest.isRepeatable, isTrue);
    expect(Quest.fromJson(quest.toJson()).id, 'q1');
  });

  test('completion result parses level-up payload', () {
    final result = CompletionResult.fromJson({
      'completion': {
        'id': 'c1',
        'quest_id': 'q1',
        'user_id': 'u1',
        'guild': 'Chores',
        'xp_awarded': 30,
        'completed_at': '2026-01-01T00:00:00Z',
      },
      'xp_awarded': 30,
      'total_xp': 130,
      'level': 2,
      'title': 'Neon Novice',
      'level_up': true,
      'quest_status': 'available',
    });
    expect(result.levelUp, isTrue);
    expect(result.completion.guild, 'Chores');
    expect(result.questStatus, QuestStatus.available);
  });

  test('create and update payloads omit empty optionals', () {
    const create = QuestCreate(
      id: 'q1',
      name: 'Clean',
      questType: QuestType.task,
      xpReward: 10,
    );
    expect(create.toJson().containsKey('description'), isTrue);
    const update = QuestUpdate(name: 'New name');
    expect(update.toJson(), {'name': 'New name'});
    expect(const QuestUpdate(clearGuild: true).toJson(), {'guild': null});
  });
}
