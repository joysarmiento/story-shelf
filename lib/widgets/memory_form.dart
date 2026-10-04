import 'package:flutter/material.dart';

import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import 'app_back_button.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

class MemoryForm extends StatefulWidget {
  const MemoryForm({
    super.key,
    required this.headingText,
    required this.submitLabel,
    required this.onSubmit,
    this.story,
    this.storyTitle,
    this.initialMemory,
  });

  final String headingText;
  final String submitLabel;
  final Story? story;
  final String? storyTitle;
  final Memory? initialMemory;
  final Future<void> Function(Memory memory) onSubmit;

  @override
  State<MemoryForm> createState() => _MemoryFormState();
}

class _MemoryFormState extends State<MemoryForm> {
  final _formKey = GlobalKey<FormState>();

  late final _progressController = TextEditingController(
    text: _stripUnit(widget.initialMemory?.progressReference),
  );
  late final _titleController = TextEditingController(
    text: widget.initialMemory?.title,
  );
  late final _contentController = TextEditingController(
    text: widget.initialMemory?.content,
  );
  late final _quoteController = TextEditingController(
    text: widget.initialMemory?.quote,
  );
  late final _dateController = TextEditingController(
    text: formatLongDate(_date),
  );

  late EntryType _type =
      widget.initialMemory?.entryType ?? EntryType.overallReview;
  late DateTime _date = widget.initialMemory?.dateCreated ?? DateTime.now();
  bool _isSubmitting = false;

  static String? _stripUnit(String? ref) {
    if (ref == null) return null;
    final stripped = ref.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim();
    return stripped.isEmpty ? ref : stripped;
  }

  String get _storyTitle =>
      widget.story?.title ??
      widget.storyTitle ??
      widget.initialMemory?.storyTitle ??
      'this story';

  @override
  void dispose() {
    _progressController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _quoteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = formatLongDate(picked);
    });
  }

  String? _nullIfEmpty(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final story = widget.story;
      final old = widget.initialMemory;
      final number = _progressController.text.trim();

      final memory = Memory(
        id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        storyId: story?.id ?? old!.storyId,
        entryType: _type,
        progressReference: _type == EntryType.overallReview || number.isEmpty
            ? null
            : '${_type.label} $number',
        rating: old?.rating,
        title: _nullIfEmpty(_titleController.text),
        content: _contentController.text.trim(),
        quote: _nullIfEmpty(_quoteController.text),
        dateCreated: _date,
        storyTitle: story?.title ?? old?.storyTitle,
        storyCoverPath: story?.coverPath ?? old?.storyCoverPath,
        storyCreator: story?.creator ?? old?.storyCreator,
        storyMedium: story?.medium ?? old?.storyMedium,
      );

      await widget.onSubmit(memory);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showProgress = _type != EntryType.overallReview;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceMd,
          AppTheme.spaceMd,
          AppTheme.spaceMd,
          AppTheme.spaceSectionGap,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              const SizedBox(height: AppTheme.spaceXxs),
              Text(widget.headingText, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppTheme.spaceXs),
              Text.rich(
                TextSpan(
                  text: 'for ',
                  children: [
                    TextSpan(
                      text: _storyTitle,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spaceLg),

              _FieldLabel('Type'),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                children: [
                  for (final type in EntryType.values) ...[
                    Expanded(
                      child: _TypeChip(
                        label: type.label,
                        selected: type == _type,
                        onTap: () => setState(() => _type = type),
                      ),
                    ),
                    if (type != EntryType.values.last)
                      const SizedBox(width: AppTheme.spaceSm),
                  ],
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),

              if (showProgress) ...[
                _FieldLabel(_type.label),
                const SizedBox(height: AppTheme.spaceSm),
                AppTextField(
                  label: _type.label,
                  hint: 'e.g. 85',
                  controller: _progressController,
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter the ${_type.label.toLowerCase()} number'
                      : null,
                ),
                const SizedBox(height: AppTheme.spaceMd),
              ],

              _FieldLabel('Memory Title'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Memory Title',
                hint: 'e.g. Quiet, but Full of Feeling',
                controller: _titleController,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              _FieldLabel('Memory Content'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Memory Content',
                hint:
                    "e.g. Some feelings are hard to explain, even when you know exactly what you're feeling...",
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                minLines: 6,
                maxLines: 12,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Write something to remember'
                    : null,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              _FieldLabel('Favorite Quote (optional)'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Favorite Quote',
                hint: 'e.g. Some stories are quiet, but they stay with you.',
                controller: _quoteController,
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: AppTheme.spaceMd),

              _FieldLabel('Date'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Date',
                hint: 'e.g. August 16, 2020',
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSectionGap),

              PrimaryButton(
                label: widget.submitLabel,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary),
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppTheme.onPrimary : AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
