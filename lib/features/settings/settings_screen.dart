import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/result.dart';
import '../../l10n/l10n.dart';
import '../../state/guilds_provider.dart';
import '../../state/providers.dart';
import '../../state/quests_provider.dart';
import '../../state/session_provider.dart';
import '../../state/settings_provider.dart';
import '../../widgets/neon_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final settings = ref.watch(settingsProvider);
    final user = session.user;
    final table = ref.watch(levelTableProvider);
    final endpoint = ref.watch(endpointProvider);

    Future<void> testConnection() async {
      final result = await ref.read(endpointServiceProvider).test(endpoint);
      if (!context.mounted) return;
      final message = switch (result) {
        Success<dynamic>(value: final info) => l10n.endpointTestOk('${info.version}'),
        Failure<dynamic>(message: final text) => '${l10n.connectionFailed}: $text',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> changeEndpoint() async {
      final controller = TextEditingController(text: endpoint);
      final value = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.changeEndpoint),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.changeEndpointBody),
              const SizedBox(height: AppSpacing.md),
              TextField(controller: controller, autofocus: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      );
      controller.dispose();
      if (value == null || value.isEmpty) return;
      await ref.read(sessionProvider.notifier).signOut(clearCache: true);
      await ref.read(endpointProvider.notifier).setEndpoint(value, markLaunched: false);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.endpointChanged)));
        context.go('/connect');
      }
    }

    Future<void> chooseLanguage() async {
      final picked = await showDialog<String?>(
        context: context,
        builder: (context) => SimpleDialog(
          title: Text(l10n.language),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(l10n.systemDefault),
            ),
            for (final locale in AppLocalizations.supportedLocales)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(locale.languageCode),
                child: Text(switch (locale.languageCode) {
                  'es' => 'Español',
                  _ => 'English',
                }),
              ),
          ],
        ),
      );
      if (picked == null) return;
      await ref
          .read(settingsProvider.notifier)
          .setLanguageCode(picked.isEmpty ? null : picked);
    }

    Future<void> clearCache() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.clearCache),
          content: Text(l10n.clearCacheConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(localStoreProvider).clearCache();
      ref.read(sessionProvider.notifier).reloadFromCache();
      ref.invalidate(questsProvider);
      ref.invalidate(guildsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
      }
    }

    Future<void> resync() async {
      await ref.read(questsProvider.notifier).refresh();
      await ref.read(guildsProvider.notifier).refresh();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.resyncDone)));
      }
    }

    Future<void> exportData() async {
      final result = await ref.read(authRepositoryProvider).exportData();
      if (!context.mounted) return;
      if (result case Success<Map<String, dynamic>>(value: final data)) {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final file = File(
            '${dir.path}/questboard-export-${DateTime.now().millisecondsSinceEpoch}.json',
          );
          await file.writeAsString(
            const JsonEncoder.withIndent('  ').convert(data),
          );
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exportReady(file.path))),
          );
        } on Object {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
      }
    }

    Future<void> changePassword() async {
      final current = TextEditingController();
      final next = TextEditingController();
      final formKey = GlobalKey<FormState>();
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.changePassword),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: current,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? l10n.requiredField : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: next,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                  validator: (value) => (value ?? '').length < 8
                      ? l10n.passwordTooShort
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      );
      if (saved == true) {
        final result = await ref.read(authRepositoryProvider).changePassword(
              currentPassword: current.text,
              newPassword: next.text,
            );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result is Success<void> ? l10n.passwordChanged : l10n.errorGeneric,
            ),
          ),
        );
      }
      current.dispose();
      next.dispose();
    }

    Future<void> deleteAccount() async {
      final controller = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deleteAccountBody),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: l10n.deleteAccountHint),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.of(context).pop(
                controller.text.trim() == l10n.deleteAccountConfirm,
              ),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      controller.dispose();
      if (confirmed != true) return;
      final result = await ref.read(sessionProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      if (result is Success<void>) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
        context.go('/connect');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (user != null)
                NeonCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.surfaceRaised,
                        child: Text(
                          user.avatar ?? '✦',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              user.username == null
                                  ? l10n.anonymousHint(user.displayName)
                                  : '@${user.username}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${table.title(user.totalXp)} · ${l10n.levelTitle(table.level(user.totalXp))}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.push('/banner'),
                        child: Text(l10n.bannerEditor),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(title: l10n.connection),
              _Tile(
                icon: Icons.link,
                title: l10n.serverEndpoint,
                subtitle: endpoint,
                trailing: TextButton(
                  onPressed: changeEndpoint,
                  child: Text(l10n.changeEndpoint),
                ),
              ),
              _Tile(
                icon: Icons.wifi_tethering,
                title: l10n.testConnection,
                onTap: testConnection,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: l10n.preferences),
              _Tile(
                icon: Icons.translate,
                title: l10n.language,
                subtitle: settings.languageCode ?? l10n.systemDefault,
                onTap: chooseLanguage,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(l10n.soundEffects),
                value: settings.soundEnabled,
                onChanged: (value) =>
                    ref.read(settingsProvider.notifier).setSoundEnabled(value),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: l10n.account),
              ThemeTile(
                icon: Icons.person_outline,
                title: l10n.username,
                subtitle: user?.username ?? '—',
              ),
              ThemeTile(
                icon: Icons.mail_outline,
                title: l10n.emailReadOnly,
                subtitle: user?.email ?? '—',
              ),
              ThemeTile(
                icon: Icons.lock_outline,
                title: l10n.changePassword,
                onTap: changePassword,
              ),
              ThemeTile(
                icon: Icons.logout,
                title: l10n.signOut,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.signOut),
                      content: Text(l10n.signOutConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.signOut),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  await ref.read(sessionProvider.notifier).signOut();
                  if (context.mounted) context.go('/auth');
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: l10n.data),
              ThemeTile(
                icon: Icons.cleaning_services_outlined,
                title: l10n.clearCache,
                onTap: clearCache,
              ),
              ThemeTile(
                icon: Icons.sync,
                title: l10n.forceResync,
                onTap: resync,
              ),
              ThemeTile(
                icon: Icons.download_outlined,
                title: l10n.exportData,
                onTap: exportData,
              ),
              ThemeTile(
                icon: Icons.delete_forever,
                title: l10n.deleteAccount,
                danger: true,
                onTap: deleteAccount,
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(title: l10n.about),
              ThemeTile(
                icon: Icons.info_outline,
                title: 'Questboard',
                subtitle: l10n.versionLabel('1.0.0+1'),
              ),
              ThemeTile(
                icon: Icons.description_outlined,
                title: l10n.aboutSpec,
                subtitle: l10n.specVersion,
              ),
              ThemeTile(
                icon: Icons.code,
                title: l10n.licenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Questboard',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.4,
            ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class ThemeTile extends StatelessWidget {
  const ThemeTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return _Tile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}
