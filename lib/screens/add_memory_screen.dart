import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../models/story.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/error_message.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key, required this.story});

  final Story story;

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _quoteController = TextEditingController();
  final _contentController = TextEditingController();

  EntryType _type = EntryType.overallReview;
  DateTime _date = DateTime.now();

  bool _saving = false;
  String? _numberError;
  String? _contentError;

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _quoteController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _titleController.text.trim().isNotEmpty ||
      _numberController.text.trim().isNotEmpty ||
      _quoteController.text.trim().isNotEmpty ||
      _contentController.text.trim().isNotEmpty ||
      _type != EntryType.overallReview;

  String? _nullIfEmpty(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final number = _numberController.text.trim();
    final content = _contentController.text.trim();
    final needsNumber = _type != EntryType.overallReview;

    setState(() {
      _numberError = needsNumber && number.isEmpty
          ? 'Enter the ${_type.label.toLowerCase()} number'
          : null;
      _contentError = content.isEmpty ? 'Write something to remember' : null;
    });
    if (_numberError != null || _contentError != null) return;

    final story = widget.story;
    final memory = Memory(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      storyId: story.id,
      entryType: _type,
      progressReference: needsNumber ? '${_type.label} $number' : null,
      title: _nullIfEmpty(_titleController.text),
      content: content,
      quote: _nullIfEmpty(_quoteController.text),
      dateCreated: _date,
      storyTitle: story.title,
      storyCoverPath: story.coverPath,
      storyCreator: story.creator,
      storyMedium: story.medium,
    );

    setState(() => _saving = true);
    try {
      await SupabaseService.instance.addMemory(memory);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save memory. ${friendlyError(e)}')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(memory);
  }

  Future<void> _tryLeave() async {
    FocusScope.of(context).unfocus();
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Discard this memory?',
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
        content: Text(
          'What you wrote hasn\'t been saved yet.',
          style: Theme.of(ctx).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              textStyle: Theme.of(
                ctx,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              foregroundColor: AppTheme.primary,
            ),
            child: const Text('Keep writing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              textStyle: Theme.of(
                ctx,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              foregroundColor: AppTheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final showNumber = _type != EntryType.overallReview;

    final body = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      color: AppTheme.onSurface,
      fontSize: 32,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _tryLeave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: AppTheme.spaceSectionGap),
          children: [
            _Banner(
              story: widget.story,
              onBack: _tryLeave,
              onSave: _save,
              saving: _saving,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: media.size.height * 0.55,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleController,
                            style: titleStyle,
                            cursorColor: AppTheme.primary,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                            decoration: _bare('Add a title', titleStyle),
                          ),
                          const SizedBox(height: AppTheme.spaceMd),

                          Row(
                            children: [
                              for (final type in EntryType.values) ...[
                                Expanded(
                                  child: _TypeChip(
                                    label: type.label,
                                    selected: type == _type,
                                    onTap: () => setState(() {
                                      _type = type;
                                      _numberError = null;
                                    }),
                                  ),
                                ),
                                if (type != EntryType.values.last)
                                  const SizedBox(width: AppTheme.spaceSm),
                              ],
                            ],
                          ),

                          if (showNumber) ...[
                            const SizedBox(height: AppTheme.spaceSm),
                            Row(
                              children: [
                                Text(
                                  _type.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spaceSm),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: _numberController,
                                    keyboardType: TextInputType.number,
                                    style: theme.textTheme.bodyMedium,
                                    cursorColor: AppTheme.primary,
                                    onChanged: (_) {
                                      if (_numberError != null) {
                                        setState(() => _numberError = null);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'e.g. 85',
                                      hintStyle: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                      isDense: true,
                                      filled: true,
                                      fillColor: AppTheme.surface,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_numberError != null) _ErrorText(_numberError!),
                          ],
                          const SizedBox(height: AppTheme.spaceSm),

                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date: ${formatLongDate(_date)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16,
                                    color: AppTheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceMd),

                          Container(
                            padding: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: AppTheme.secondary,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _quoteController,
                              style: body?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                              cursorColor: AppTheme.primary,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: null,
                              decoration: _bare('Add a favorite quote', body),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceMd),

                          TextField(
                            controller: _contentController,
                            style: body,
                            cursorColor: AppTheme.primary,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 10,
                            maxLines: null,
                            onChanged: (_) {
                              if (_contentError != null) {
                                setState(() => _contentError = null);
                              }
                            },
                            decoration: _bare(
                              'Write something to remember',
                              body,
                            ),
                          ),
                          if (_contentError != null) _ErrorText(_contentError!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _bare(String hint, TextStyle? style) => InputDecoration(
    hintText: hint,
    hintStyle: style?.copyWith(
      color: AppTheme.onSurface.withValues(alpha: 0.5),
    ),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spaceXs),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.error),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.secondary,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppTheme.onPrimary : AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.story,
    required this.onBack,
    required this.onSave,
    required this.saving,
  });

  final Story story;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final cover = story.coverPath;
    final meta = [
      if (story.creator != null) story.creator!,
      if (story.releaseYear != null) story.releaseYear.toString(),
    ].join(' • ');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              cover != null
                  ? Image.network(
                      cover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: AppTheme.secondary),
                    )
                  : Container(color: AppTheme.secondary),
              Positioned(
                bottom: -2,
                left: 0,
                right: 0,
                height: 112,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(0, 251, 249, 236),
                          AppTheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppTheme.spaceMd + topInset,
                left: AppTheme.spaceMd,
                child: GestureDetector(
                  onTap: onBack,
                  child: const Row(
                    children: [
                      Icon(Icons.chevron_left, color: AppTheme.onPrimary),
                      Text('Back', style: TextStyle(color: AppTheme.onPrimary)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppTheme.spaceMd + topInset - 3,
                right: AppTheme.spaceMd,
                child: GestureDetector(
                  onTap: saving ? null : onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: saving
                          ? AppTheme.primary.withValues(alpha: 0.6)
                          : AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: AppTheme.onPrimary),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: -10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  story.medium.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.error,
                  fontSize: 20,
                ),
              ),
              if (meta.isNotEmpty)
                Text(
                  meta,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
