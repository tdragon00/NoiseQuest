import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../l10n/l10n.dart';
import '../../state/providers.dart';
import '../../state/settings_provider.dart';
import '../../widgets/neon_card.dart';

const _languageNames = <String, String>{
  'en': 'English',
  'es': 'Español',
};

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final locales = AppLocalizations.supportedLocales;

    return Scaffold(
      body: NeonBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.languageTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  NeonCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Column(
                      children: [
                        _LanguageTile(
                          label: context.l10n.systemDefault,
                          selected: settings.languageCode == null,
                          onTap: () => ref
                              .read(settingsProvider.notifier)
                              .setLanguageCode(null),
                        ),
                        for (final locale in locales)
                          _LanguageTile(
                            label: _languageNames[locale.languageCode] ??
                                locale.languageCode.toUpperCase(),
                            selected: settings.languageCode == locale.languageCode,
                            onTap: () => ref
                                .read(settingsProvider.notifier)
                                .setLanguageCode(locale.languageCode),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () async {
                      await ref.read(onboardingProvider.notifier).complete();
                      if (context.mounted) context.go('/auth');
                    },
                    child: Text(context.l10n.continueLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? AppColors.primary : AppColors.textPrimary,
                    ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
