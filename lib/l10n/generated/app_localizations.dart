import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Questboard'**
  String get appName;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @offlineShowingCached.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing cached data'**
  String get offlineShowingCached;

  /// No description provided for @syncIdle.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncIdle;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String syncPending(int count);

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncSyncing;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Sync error'**
  String get syncError;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @connectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectTitle;

  /// No description provided for @serverEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Server endpoint'**
  String get serverEndpoint;

  /// No description provided for @endpointHint.
  ///
  /// In en, this message translates to:
  /// **'http://127.0.0.1:4010'**
  String get endpointHint;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing connection…'**
  String get testingConnection;

  /// No description provided for @endpointRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a server URL.'**
  String get endpointRequired;

  /// No description provided for @endpointInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid URL.'**
  String get endpointInvalid;

  /// No description provided for @endpointUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach this server. Check the URL and try again.'**
  String get endpointUnreachable;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageTitle;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @usernameOptional.
  ///
  /// In en, this message translates to:
  /// **'Username (optional)'**
  String get usernameOptional;

  /// No description provided for @avatarOptional.
  ///
  /// In en, this message translates to:
  /// **'Avatar (optional)'**
  String get avatarOptional;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Check your details.'**
  String get authFailed;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get noAccount;

  /// No description provided for @guildBoard.
  ///
  /// In en, this message translates to:
  /// **'Guild Board'**
  String get guildBoard;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @createQuest.
  ///
  /// In en, this message translates to:
  /// **'Create Quest'**
  String get createQuest;

  /// No description provided for @totalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get totalXp;

  /// No description provided for @guildXp.
  ///
  /// In en, this message translates to:
  /// **'Guild XP'**
  String get guildXp;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'LVL {level}'**
  String levelShort(int level);

  /// No description provided for @maxLevel.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get maxLevel;

  /// No description provided for @xpProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {next} XP'**
  String xpProgress(String current, String next);

  /// No description provided for @noGuilds.
  ///
  /// In en, this message translates to:
  /// **'No guilds yet'**
  String get noGuilds;

  /// No description provided for @searchQuests.
  ///
  /// In en, this message translates to:
  /// **'Search quests…'**
  String get searchQuests;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortBy;

  /// No description provided for @sortGuild.
  ///
  /// In en, this message translates to:
  /// **'Guild'**
  String get sortGuild;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortRecentlyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Recently completed'**
  String get sortRecentlyCompleted;

  /// No description provided for @sortXp.
  ///
  /// In en, this message translates to:
  /// **'XP reward'**
  String get sortXp;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @questCount.
  ///
  /// In en, this message translates to:
  /// **'{count} quests'**
  String questCount(int count);

  /// No description provided for @noQuestsTitle.
  ///
  /// In en, this message translates to:
  /// **'No quests here yet'**
  String get noQuestsTitle;

  /// No description provided for @noQuestsBody.
  ///
  /// In en, this message translates to:
  /// **'The board is quiet. Create a quest to get started.'**
  String get noQuestsBody;

  /// No description provided for @createFirstQuest.
  ///
  /// In en, this message translates to:
  /// **'Create your first quest'**
  String get createFirstQuest;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String byAuthor(String name);

  /// No description provided for @completedBy.
  ///
  /// In en, this message translates to:
  /// **'Completed by {name}'**
  String completedBy(String name);

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String createdOn(String date);

  /// No description provided for @xpReward.
  ///
  /// In en, this message translates to:
  /// **'XP reward'**
  String get xpReward;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @markComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get markComplete;

  /// No description provided for @cancelQuest.
  ///
  /// In en, this message translates to:
  /// **'Cancel quest'**
  String get cancelQuest;

  /// No description provided for @editQuest.
  ///
  /// In en, this message translates to:
  /// **'Edit quest'**
  String get editQuest;

  /// No description provided for @deleteQuest.
  ///
  /// In en, this message translates to:
  /// **'Delete quest'**
  String get deleteQuest;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this quest?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes it from every board. XP already earned is kept.'**
  String get deleteConfirmBody;

  /// No description provided for @questDetails.
  ///
  /// In en, this message translates to:
  /// **'Quest details'**
  String get questDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @completedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedLabel;

  /// No description provided for @completedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed by'**
  String get completedByLabel;

  /// No description provided for @repeatable.
  ///
  /// In en, this message translates to:
  /// **'Repeatable'**
  String get repeatable;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;

  /// No description provided for @questName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get questName;

  /// No description provided for @questNameHint.
  ///
  /// In en, this message translates to:
  /// **'Clean the kitchen'**
  String get questNameHint;

  /// No description provided for @questDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get questDescription;

  /// No description provided for @questDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get questDescriptionHint;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @clearIcon.
  ///
  /// In en, this message translates to:
  /// **'Clear icon'**
  String get clearIcon;

  /// No description provided for @guild.
  ///
  /// In en, this message translates to:
  /// **'Guild'**
  String get guild;

  /// No description provided for @guildHint.
  ///
  /// In en, this message translates to:
  /// **'Chores, Work, Errands…'**
  String get guildHint;

  /// No description provided for @xpRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'XP reward'**
  String get xpRewardLabel;

  /// No description provided for @quickPick.
  ///
  /// In en, this message translates to:
  /// **'Quick pick'**
  String get quickPick;

  /// No description provided for @repeatableHelper.
  ///
  /// In en, this message translates to:
  /// **'Repeatable quests reset to Available when completed and can be earned again.'**
  String get repeatableHelper;

  /// No description provided for @questType.
  ///
  /// In en, this message translates to:
  /// **'Quest type'**
  String get questType;

  /// No description provided for @questTypeTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get questTypeTask;

  /// No description provided for @questTypeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get questTypeChallenge;

  /// No description provided for @questTypeRaid.
  ///
  /// In en, this message translates to:
  /// **'Raid'**
  String get questTypeRaid;

  /// No description provided for @questTypeEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get questTypeEvent;

  /// No description provided for @questTypeBounty.
  ///
  /// In en, this message translates to:
  /// **'Bounty'**
  String get questTypeBounty;

  /// No description provided for @createQuestButton.
  ///
  /// In en, this message translates to:
  /// **'Create quest'**
  String get createQuestButton;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your quest a name.'**
  String get nameRequired;

  /// No description provided for @xpInvalid.
  ///
  /// In en, this message translates to:
  /// **'XP reward must be between 1 and 10000.'**
  String get xpInvalid;

  /// No description provided for @questCreated.
  ///
  /// In en, this message translates to:
  /// **'Quest created'**
  String get questCreated;

  /// No description provided for @questStarted.
  ///
  /// In en, this message translates to:
  /// **'Quest started'**
  String get questStarted;

  /// No description provided for @questCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quest complete!'**
  String get questCompleted;

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up! You are now level {level}.'**
  String levelUp(int level);

  /// No description provided for @questCancelled.
  ///
  /// In en, this message translates to:
  /// **'Quest returned to Available'**
  String get questCancelled;

  /// No description provided for @questDeleted.
  ///
  /// In en, this message translates to:
  /// **'Quest deleted'**
  String get questDeleted;

  /// No description provided for @questUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quest updated'**
  String get questUpdated;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get chooseIcon;

  /// No description provided for @bannerEditor.
  ///
  /// In en, this message translates to:
  /// **'Banner Editor'**
  String get bannerEditor;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @artPresets.
  ///
  /// In en, this message translates to:
  /// **'Art presets'**
  String get artPresets;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @bannerSaved.
  ///
  /// In en, this message translates to:
  /// **'Banner updated'**
  String get bannerSaved;

  /// No description provided for @leaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboards;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @guildScope.
  ///
  /// In en, this message translates to:
  /// **'Guild'**
  String get guildScope;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get you;

  /// No description provided for @myGuilds.
  ///
  /// In en, this message translates to:
  /// **'My guilds'**
  String get myGuilds;

  /// No description provided for @noLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet'**
  String get noLeaderboard;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @changeEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Change endpoint'**
  String get changeEndpoint;

  /// No description provided for @changeEndpointBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the endpoint clears cached data and signs you out.'**
  String get changeEndpointBody;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cached data'**
  String get clearCache;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'This removes cached quests and pending changes on this device.'**
  String get clearCacheConfirm;

  /// No description provided for @forceResync.
  ///
  /// In en, this message translates to:
  /// **'Force full re-sync'**
  String get forceResync;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, quests, and completions. This cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE MY ACCOUNT to confirm'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE MY ACCOUNT'**
  String get deleteAccountConfirm;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @emailReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Email (read-only)'**
  String get emailReadOnly;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get aboutBuild;

  /// No description provided for @aboutSpec.
  ///
  /// In en, this message translates to:
  /// **'API spec'**
  String get aboutSpec;

  /// No description provided for @endpointChanged.
  ///
  /// In en, this message translates to:
  /// **'Endpoint changed. Please connect again.'**
  String get endpointChanged;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cached data cleared'**
  String get cacheCleared;

  /// No description provided for @resyncDone.
  ///
  /// In en, this message translates to:
  /// **'Re-sync complete'**
  String get resyncDone;

  /// No description provided for @exportReady.
  ///
  /// In en, this message translates to:
  /// **'Export saved to {path}'**
  String exportReady(String path);

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @connectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionOk;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @anonymousHint.
  ///
  /// In en, this message translates to:
  /// **'No username set — you appear as {name}'**
  String anonymousHint(String name);

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// No description provided for @guildFilter.
  ///
  /// In en, this message translates to:
  /// **'Guild filter'**
  String get guildFilter;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelTitle(int level);

  /// No description provided for @questTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'{type} quest'**
  String questTypeLabel(String type);

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this account?'**
  String get signOutConfirm;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @tooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long (max {max}).'**
  String tooLong(int max);

  /// No description provided for @bannerLockedNote.
  ///
  /// In en, this message translates to:
  /// **'Presets are procedural and render at any size.'**
  String get bannerLockedNote;

  /// No description provided for @filterByGuild.
  ///
  /// In en, this message translates to:
  /// **'Filter by guild'**
  String get filterByGuild;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No quests match your search.'**
  String get emptySearch;

  /// No description provided for @offlineBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offlineBannerTitle;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed.'**
  String get exportFailed;

  /// No description provided for @endpointTestOk.
  ///
  /// In en, this message translates to:
  /// **'Server reachable — version {version}'**
  String endpointTestOk(String version);

  /// No description provided for @specVersion.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get specVersion;

  /// No description provided for @questTypeNone.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get questTypeNone;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @guilds.
  ///
  /// In en, this message translates to:
  /// **'Guilds'**
  String get guilds;

  /// No description provided for @noGuildXp.
  ///
  /// In en, this message translates to:
  /// **'Complete a guild quest to earn guild XP.'**
  String get noGuildXp;

  /// No description provided for @leaderboardGlobalHint.
  ///
  /// In en, this message translates to:
  /// **'Ranked by lifetime XP'**
  String get leaderboardGlobalHint;

  /// No description provided for @leaderboardGuildHint.
  ///
  /// In en, this message translates to:
  /// **'Ranked by XP in this guild'**
  String get leaderboardGuildHint;

  /// No description provided for @chooseGuild.
  ///
  /// In en, this message translates to:
  /// **'Choose a guild'**
  String get chooseGuild;

  /// No description provided for @createQuestHint.
  ///
  /// In en, this message translates to:
  /// **'Name and XP are required.'**
  String get createQuestHint;

  /// No description provided for @offlineQueueNote.
  ///
  /// In en, this message translates to:
  /// **'Changes are queued and will sync automatically.'**
  String get offlineQueueNote;

  /// No description provided for @newQuest.
  ///
  /// In en, this message translates to:
  /// **'New quest'**
  String get newQuest;

  /// No description provided for @defaultEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Default: {endpoint}'**
  String defaultEndpoint(String endpoint);

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Turn everyday chores into neon quests.'**
  String get appTagline;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @questsDone.
  ///
  /// In en, this message translates to:
  /// **'Quests done'**
  String get questsDone;

  /// No description provided for @guildCount.
  ///
  /// In en, this message translates to:
  /// **'{count} guilds'**
  String guildCount(int count);

  /// No description provided for @noGuildsHint.
  ///
  /// In en, this message translates to:
  /// **'Tag quests with a guild to start building guild XP.'**
  String get noGuildsHint;

  /// No description provided for @noAvailableQuests.
  ///
  /// In en, this message translates to:
  /// **'Nothing available right now.'**
  String get noAvailableQuests;

  /// No description provided for @noActiveQuests.
  ///
  /// In en, this message translates to:
  /// **'No quests in progress.'**
  String get noActiveQuests;

  /// No description provided for @noCompletedQuests.
  ///
  /// In en, this message translates to:
  /// **'No victories yet.'**
  String get noCompletedQuests;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Lost in the grid'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'That route does not exist.'**
  String get notFoundBody;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Back to the board'**
  String get goHome;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
