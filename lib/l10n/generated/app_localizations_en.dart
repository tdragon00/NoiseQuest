// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Questboard';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get continueLabel => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get offlineShowingCached => 'Offline — showing cached data';

  @override
  String get syncIdle => 'Synced';

  @override
  String syncPending(int count) {
    return 'Pending ($count)';
  }

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncError => 'Sync error';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get none => 'None';

  @override
  String get connectTitle => 'Connect';

  @override
  String get serverEndpoint => 'Server endpoint';

  @override
  String get endpointHint => 'http://127.0.0.1:4010';

  @override
  String get testingConnection => 'Testing connection…';

  @override
  String get endpointRequired => 'Enter a server URL.';

  @override
  String get endpointInvalid => 'That doesn\'t look like a valid URL.';

  @override
  String get endpointUnreachable =>
      'Couldn\'t reach this server. Check the URL and try again.';

  @override
  String get languageTitle => 'Choose your language';

  @override
  String get systemDefault => 'System default';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get usernameOptional => 'Username (optional)';

  @override
  String get avatarOptional => 'Avatar (optional)';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get authFailed => 'Sign-in failed. Check your details.';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get noAccount => 'New here? Create an account';

  @override
  String get guildBoard => 'Guild Board';

  @override
  String get available => 'Available';

  @override
  String get inProgress => 'In Progress';

  @override
  String get completed => 'Completed';

  @override
  String get createQuest => 'Create Quest';

  @override
  String get totalXp => 'Total XP';

  @override
  String get guildXp => 'Guild XP';

  @override
  String levelShort(int level) {
    return 'LVL $level';
  }

  @override
  String get maxLevel => 'MAX';

  @override
  String xpProgress(String current, String next) {
    return '$current / $next XP';
  }

  @override
  String get noGuilds => 'No guilds yet';

  @override
  String get searchQuests => 'Search quests…';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortGuild => 'Guild';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortRecentlyCompleted => 'Recently completed';

  @override
  String get sortXp => 'XP reward';

  @override
  String get sortName => 'Name';

  @override
  String questCount(int count) {
    return '$count quests';
  }

  @override
  String get noQuestsTitle => 'No quests here yet';

  @override
  String get noQuestsBody =>
      'The board is quiet. Create a quest to get started.';

  @override
  String get createFirstQuest => 'Create your first quest';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String byAuthor(String name) {
    return 'by $name';
  }

  @override
  String completedBy(String name) {
    return 'Completed by $name';
  }

  @override
  String createdOn(String date) {
    return 'Created $date';
  }

  @override
  String get xpReward => 'XP reward';

  @override
  String get start => 'Start';

  @override
  String get markComplete => 'Mark complete';

  @override
  String get cancelQuest => 'Cancel quest';

  @override
  String get editQuest => 'Edit quest';

  @override
  String get deleteQuest => 'Delete quest';

  @override
  String get deleteConfirmTitle => 'Delete this quest?';

  @override
  String get deleteConfirmBody =>
      'This removes it from every board. XP already earned is kept.';

  @override
  String get questDetails => 'Quest details';

  @override
  String get description => 'Description';

  @override
  String get author => 'Author';

  @override
  String get created => 'Created';

  @override
  String get completedLabel => 'Completed';

  @override
  String get completedByLabel => 'Completed by';

  @override
  String get repeatable => 'Repeatable';

  @override
  String get noDescription => 'No description.';

  @override
  String get questName => 'Name';

  @override
  String get questNameHint => 'Clean the kitchen';

  @override
  String get questDescription => 'Description';

  @override
  String get questDescriptionHint => 'What needs doing?';

  @override
  String get icon => 'Icon';

  @override
  String get clearIcon => 'Clear icon';

  @override
  String get guild => 'Guild';

  @override
  String get guildHint => 'Chores, Work, Errands…';

  @override
  String get xpRewardLabel => 'XP reward';

  @override
  String get quickPick => 'Quick pick';

  @override
  String get repeatableHelper =>
      'Repeatable quests reset to Available when completed and can be earned again.';

  @override
  String get questType => 'Quest type';

  @override
  String get questTypeTask => 'Task';

  @override
  String get questTypeChallenge => 'Challenge';

  @override
  String get questTypeRaid => 'Raid';

  @override
  String get questTypeEvent => 'Event';

  @override
  String get questTypeBounty => 'Bounty';

  @override
  String get createQuestButton => 'Create quest';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get nameRequired => 'Give your quest a name.';

  @override
  String get xpInvalid => 'XP reward must be between 1 and 10000.';

  @override
  String get questCreated => 'Quest created';

  @override
  String get questStarted => 'Quest started';

  @override
  String get questCompleted => 'Quest complete!';

  @override
  String levelUp(int level) {
    return 'Level up! You are now level $level.';
  }

  @override
  String get questCancelled => 'Quest returned to Available';

  @override
  String get questDeleted => 'Quest deleted';

  @override
  String get questUpdated => 'Quest updated';

  @override
  String get chooseIcon => 'Choose an icon';

  @override
  String get bannerEditor => 'Banner Editor';

  @override
  String get preview => 'Preview';

  @override
  String get artPresets => 'Art presets';

  @override
  String get avatar => 'Avatar';

  @override
  String get bannerSaved => 'Banner updated';

  @override
  String get leaderboards => 'Leaderboards';

  @override
  String get global => 'Global';

  @override
  String get guildScope => 'Guild';

  @override
  String get you => 'YOU';

  @override
  String get myGuilds => 'My guilds';

  @override
  String get noLeaderboard => 'No rankings yet';

  @override
  String get settings => 'Settings';

  @override
  String get connection => 'Connection';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get data => 'Data';

  @override
  String get about => 'About';

  @override
  String get testConnection => 'Test connection';

  @override
  String get changeEndpoint => 'Change endpoint';

  @override
  String get changeEndpointBody =>
      'Changing the endpoint clears cached data and signs you out.';

  @override
  String get language => 'Language';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get clearCache => 'Clear cached data';

  @override
  String get clearCacheConfirm =>
      'This removes cached quests and pending changes on this device.';

  @override
  String get forceResync => 'Force full re-sync';

  @override
  String get exportData => 'Export my data';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account, quests, and completions. This cannot be undone.';

  @override
  String get deleteAccountHint => 'Type DELETE MY ACCOUNT to confirm';

  @override
  String get deleteAccountConfirm => 'DELETE MY ACCOUNT';

  @override
  String get username => 'Username';

  @override
  String get emailReadOnly => 'Email (read-only)';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutBuild => 'Build';

  @override
  String get aboutSpec => 'API spec';

  @override
  String get endpointChanged => 'Endpoint changed. Please connect again.';

  @override
  String get cacheCleared => 'Cached data cleared';

  @override
  String get resyncDone => 'Re-sync complete';

  @override
  String exportReady(String path) {
    return 'Export saved to $path';
  }

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get connectionOk => 'Connected';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String anonymousHint(String name) {
    return 'No username set — you appear as $name';
  }

  @override
  String get profilePicture => 'Profile picture';

  @override
  String get guildFilter => 'Guild filter';

  @override
  String levelTitle(int level) {
    return 'Level $level';
  }

  @override
  String questTypeLabel(String type) {
    return '$type quest';
  }

  @override
  String get signOutConfirm => 'Sign out of this account?';

  @override
  String get requiredField => 'This field is required.';

  @override
  String tooLong(int max) {
    return 'Too long (max $max).';
  }

  @override
  String get bannerLockedNote =>
      'Presets are procedural and render at any size.';

  @override
  String get filterByGuild => 'Filter by guild';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get emptySearch => 'No quests match your search.';

  @override
  String get offlineBannerTitle => 'You\'re offline';

  @override
  String get syncNow => 'Sync now';

  @override
  String get exportFailed => 'Export failed.';

  @override
  String endpointTestOk(String version) {
    return 'Server reachable — version $version';
  }

  @override
  String get specVersion => '1.0.0';

  @override
  String get questTypeNone => 'Uncategorised';

  @override
  String get level => 'Level';

  @override
  String get title => 'Title';

  @override
  String get guilds => 'Guilds';

  @override
  String get noGuildXp => 'Complete a guild quest to earn guild XP.';

  @override
  String get leaderboardGlobalHint => 'Ranked by lifetime XP';

  @override
  String get leaderboardGuildHint => 'Ranked by XP in this guild';

  @override
  String get chooseGuild => 'Choose a guild';

  @override
  String get createQuestHint => 'Name and XP are required.';

  @override
  String get offlineQueueNote =>
      'Changes are queued and will sync automatically.';

  @override
  String get newQuest => 'New quest';

  @override
  String defaultEndpoint(String endpoint) {
    return 'Default: $endpoint';
  }

  @override
  String get licenses => 'Licenses';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get appTagline => 'Turn everyday chores into neon quests.';

  @override
  String get refresh => 'Refresh';

  @override
  String get viewAll => 'View all';

  @override
  String get questsDone => 'Quests done';

  @override
  String guildCount(int count) {
    return '$count guilds';
  }

  @override
  String get noGuildsHint =>
      'Tag quests with a guild to start building guild XP.';

  @override
  String get noAvailableQuests => 'Nothing available right now.';

  @override
  String get noActiveQuests => 'No quests in progress.';

  @override
  String get noCompletedQuests => 'No victories yet.';

  @override
  String get notFoundTitle => 'Lost in the grid';

  @override
  String get notFoundBody => 'That route does not exist.';

  @override
  String get goHome => 'Back to the board';

  @override
  String get justNow => 'Just now';
}
