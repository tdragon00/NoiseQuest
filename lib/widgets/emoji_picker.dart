import 'package:flutter/material.dart';

import '../core/constants/emoji.dart';
import '../core/theme/tokens.dart';
import '../l10n/l10n.dart';

Future<String?> showEmojiPicker(
  BuildContext context, {
  String? selected,
  bool avatarsOnly = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _EmojiPickerDialog(
      selected: selected,
      avatarsOnly: avatarsOnly,
    ),
  );
}

class _EmojiPickerDialog extends StatefulWidget {
  const _EmojiPickerDialog({this.selected, this.avatarsOnly = false});

  final String? selected;
  final bool avatarsOnly;

  @override
  State<_EmojiPickerDialog> createState() => _EmojiPickerDialogState();
}

class _EmojiPickerDialogState extends State<_EmojiPickerDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final icons = widget.avatarsOnly ? kAvatarIcons : kQuestIcons;
    final columns = width >= 1024 ? 12 : (width >= 600 ? 10 : 8);
    return AlertDialog(
      title: Text(context.l10n.chooseIcon),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLength: 8,
              decoration: InputDecoration(
                hintText: context.l10n.icon,
                counterText: '',
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) Navigator.of(context).pop(value.trim());
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: icons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final icon = icons[index];
                  final isSelected = icon == widget.selected;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    onTap: () => Navigator.of(context).pop(icon),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.16)
                            : AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(''),
          child: Text(context.l10n.clearIcon),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}
