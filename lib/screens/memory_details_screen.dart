import 'dart:async';

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../models/memory.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import '../utils/app_navigation.dart';
import '../utils/date_format.dart';
import '../utils/error_message.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/mood_picker.dart';

enum _SaveState { idle, pending, saving, saved, error, invalid }

class MemoryDetailsScreen extends StatefulWidget {
  const MemoryDetailsScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  State<MemoryDetailsScreen> createState() => _MemoryDetailsScreenState();
}

class _MemoryDetailsScreenState extends State<MemoryDetailsScreen> {
  static const _autosaveDelay = Duration(milliseconds: 800);

  Memory? _memory;
  int? _releaseYear;
  bool _loading = true;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _quoteController = TextEditingController();

  late EntryType _type;
  Mood? _mood;
  late String _number;
  late DateTime _date;

  Timer? _debounce;
  Timer? _savedFade;
  bool _dirty = false;
  bool _disposed = false;
  _SaveState _saveState = _SaveState.idle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _savedFade?.cancel();
    _save();
    _titleController.dispose();
    _contentController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_disposed || !mounted) return;
    setState(fn);
  }

  static String _stripUnit(String? ref) {
    if (ref == null) return '';
    final stripped = ref.replaceFirst(RegExp(r'^[A-Za-z\s]+'), '').trim();
    return stripped.isEmpty ? ref : stripped;
  }

  Future<void> _load() async {
    try {
      final memory = await SupabaseService.instance.getMemory(widget.memoryId);
      final story = memory == null
          ? null
          : await SupabaseService.instance.getStory(memory.storyId);
      if (!mounted) return;
      if (memory != null) {
        _titleController.text = memory.title ?? '';
        _contentController.text = memory.content;
        _quoteController.text = memory.quote ?? '';
        _type = memory.entryType;
        _mood = memory.mood;
        _number = _stripUnit(memory.progressReference);
        _date = memory.dateCreated;
      }
      setState(() {
        _memory = memory;
        _releaseYear = story?.releaseYear;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load memory. ${friendlyError(e)}')),
      );
    }
  }

  void _markChanged() {
    if (_memory == null) return;
    _dirty = true;
    _savedFade?.cancel();
    _safeSetState(() => _saveState = _SaveState.pending);
    _debounce?.cancel();
    _debounce = Timer(_autosaveDelay, _save);
  }

  String? _nullIfEmpty(String text) {
    final t = text.trim();
    return t.isEmpty ? null : t;
  }

  Memory _buildMemory(Memory base, String content) {
    return Memory(
      id: base.id,
      storyId: base.storyId,
      entryType: _type,
      progressReference: _type == EntryType.overallReview || _number.isEmpty
          ? null
          : '${_type.label} $_number',
      rating: base.rating,
      title: _nullIfEmpty(_titleController.text),
      content: content,
      quote: _nullIfEmpty(_quoteController.text),
      mood: _mood,
      dateCreated: _date,
      storyTitle: base.storyTitle,
      storyCoverPath: base.storyCoverPath,
      storyCreator: base.storyCreator,
      storyMedium: base.storyMedium,
    );
  }

  Future<void> _save() async {
    _debounce?.cancel();
    final base = _memory;
    if (base == null || !_dirty) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _safeSetState(() => _saveState = _SaveState.invalid);
      return;
    }

    _dirty = false;
    final updated = _buildMemory(base, content);
    _safeSetState(() => _saveState = _SaveState.saving);
    try {
      await SupabaseService.instance.updateMemory(updated);
      _memory = updated;
      _safeSetState(() => _saveState = _SaveState.saved);
      _savedFade = Timer(const Duration(seconds: 2), () {
        _safeSetState(() {
          if (_saveState == _SaveState.saved) _saveState = _SaveState.idle;
        });
      });
    } catch (e) {
      _dirty = true;
      _safeSetState(() => _saveState = _SaveState.error);
      if (!_disposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save changes. ${friendlyError(e)}'),
          ),
        );
      }
    }
  }

  Future<void> _leave() async {
    FocusScope.of(context).unfocus();
    await _save();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    _markChanged();
  }

  Future<void> _pickType() async {
    FocusScope.of(context).unfocus();
    final result =
        await showModalBottomSheet<({EntryType type, String number})>(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) =>
              _TypeSheet(initialType: _type, initialNumber: _number),
        );
    if (result == null) return;
    setState(() {
      _type = result.type;
      _number = result.number;
    });
    _markChanged();
  }

  Future<void> _pickMood() async {
    FocusScope.of(context).unfocus();
    final result = await showModalBottomSheet<({Mood? mood})>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MoodSheet(selected: _mood),
    );
    if (result == null) return;
    setState(() => _mood = result.mood);
    _markChanged();
  }

  Future<void> _confirmDelete(Memory memory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text('This memory will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      _dirty = false;
      _debounce?.cancel();
      await SupabaseService.instance.deleteMemory(memory.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete memory. ${friendlyError(e)}')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memory = _memory;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (memory == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        body: SafeArea(
          child: Center(
            child: Text('Memory not found', style: theme.textTheme.bodyMedium),
          ),
        ),
      );
    }

    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final reference = _type == EntryType.overallReview || _number.isEmpty
        ? _type.label
        : '${_type.label} $_number';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: Stack(
          children: [
            ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: keyboardOpen ? 24 : 96),
              children: [
                _Banner(
                  memory: memory,
                  releaseYear: _releaseYear,
                  onBack: _leave,
                  saveState: _saveState,
                  onDelete: () => _confirmDelete(memory),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 35),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: media.size.height * 0.55,
                        ),
                        child: _NoteCard(
                          titleController: _titleController,
                          titleHint: _type.label,
                          contentController: _contentController,
                          quoteController: _quoteController,
                          reference: reference,
                          dateText: formatLongDate(_date),
                          mood: _mood,
                          onTapMood: _pickMood,
                          onChanged: _markChanged,
                          onTapReference: _pickType,
                          onTapDate: _pickDate,
                          contentEmpty: _saveState == _SaveState.invalid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!keyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(
                  currentIndex: AppTab.library,
                  onTap: (index) async {
                    await _save();
                    if (!context.mounted) return;
                    navigateToTab(context, index, currentIndex: -1);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.titleController,
    required this.titleHint,
    required this.contentController,
    required this.quoteController,
    required this.reference,
    required this.dateText,
    required this.mood,
    required this.onTapMood,
    required this.onChanged,
    required this.onTapReference,
    required this.onTapDate,
    required this.contentEmpty,
  });

  final TextEditingController titleController;
  final String titleHint;
  final TextEditingController contentController;
  final TextEditingController quoteController;
  final String reference;
  final String dateText;
  final Mood? mood;
  final VoidCallback onTapMood;
  final VoidCallback onChanged;
  final VoidCallback onTapReference;
  final VoidCallback onTapDate;
  final bool contentEmpty;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      color: AppTheme.onSurface,
      fontSize: 32,
    );

    return Container(
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
            controller: titleController,
            onChanged: (_) => onChanged(),
            style: titleStyle,
            cursorColor: AppTheme.primary,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            decoration: _bare(titleHint, titleStyle),
          ),
          const SizedBox(height: AppTheme.spaceSm),

          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TapChip(
                    label: reference,
                    icon: Icons.unfold_more,
                    semanticLabel: 'Change entry type',
                    onTap: onTapReference,
                  ),
                ),
              ),
              _MoodChip(mood: mood, onTap: onTapMood),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),

          _TapChip(
            prefix: 'Date: ',
            label: dateText,
            icon: Icons.calendar_today_outlined,
            semanticLabel: 'Change date',
            onTap: onTapDate,
            bold: false,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppTheme.secondary, width: 3),
              ),
            ),
            child: TextField(
              controller: quoteController,
              onChanged: (_) => onChanged(),
              style: body?.copyWith(fontStyle: FontStyle.italic),
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
            controller: contentController,
            onChanged: (_) => onChanged(),
            style: body,
            cursorColor: AppTheme.primary,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            minLines: 10,
            maxLines: null,
            decoration: _bare('Write something to remember', body),
          ),
          if (contentEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.spaceSm),
              child: Text(
                'Memory can’t be empty. Your last saved version is kept.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TapChip extends StatelessWidget {
  const _TapChip({
    required this.label,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.bold = true,
    this.prefix,
  });

  final String label;
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool bold;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (prefix != null)
                        TextSpan(
                          text: prefix,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      TextSpan(text: label),
                    ],
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 16,
                color: AppTheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSheet extends StatefulWidget {
  const _TypeSheet({required this.initialType, required this.initialNumber});

  final EntryType initialType;
  final String initialNumber;

  @override
  State<_TypeSheet> createState() => _TypeSheetState();
}

class _TypeSheetState extends State<_TypeSheet> {
  late EntryType _type = widget.initialType;
  late final _numberController = TextEditingController(
    text: widget.initialNumber,
  );
  String? _error;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _done() {
    final number = _numberController.text.trim();
    if (_type != EntryType.overallReview && number.isEmpty) {
      setState(() => _error = 'Enter the ${_type.label.toLowerCase()} number');
      return;
    }
    Navigator.of(context).pop((
      type: _type,
      number: _type == EntryType.overallReview ? '' : number,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showNumber = _type != EntryType.overallReview;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text('Entry type', style: theme.textTheme.headlineSmall),
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
                        _error = null;
                      }),
                    ),
                  ),
                  if (type != EntryType.values.last)
                    const SizedBox(width: AppTheme.spaceSm),
                ],
              ],
            ),
            if (showNumber) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                '${_type.label} number',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                autofocus: widget.initialType == EntryType.overallReview,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. 85',
                  errorText: _error,
                  filled: true,
                  fillColor: AppTheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _done(),
              ),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _done,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
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

class _Banner extends StatelessWidget {
  const _Banner({
    required this.memory,
    required this.onBack,
    required this.onDelete,
    required this.saveState,
    this.releaseYear,
  });

  final Memory memory;
  final int? releaseYear;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final _SaveState saveState;

  String? get _statusText => switch (saveState) {
    _SaveState.pending || _SaveState.saving => 'Saving…',
    _SaveState.saved => 'Saved',
    _SaveState.error => 'Not saved',
    _SaveState.invalid => 'Not saved',
    _SaveState.idle => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.of(context).padding.top;
    final cover = memory.storyCoverPath;
    final status = _statusText;
    final meta = [
      if (memory.storyCreator != null) memory.storyCreator!,
      if (releaseYear != null) releaseYear.toString(),
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
                top: AppTheme.spaceSm + topInset,
                right: AppTheme.spaceSm,
                child: Row(
                  children: [
                    if (status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (saveState == _SaveState.error ||
                                  saveState == _SaveState.invalid)
                              ? AppTheme.error
                              : Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.onPrimary,
                          ),
                        ),
                      ),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppTheme.onPrimary,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: AppTheme.error),
                              const SizedBox(width: 8),
                              Text(
                                'Delete memory',
                                style: TextStyle(color: AppTheme.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
              if (memory.storyMedium != null)
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
                    memory.storyMedium!.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                memory.storyTitle ?? 'Untitled story',
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

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.onTap});

  final Mood? mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mood = this.mood;
    final hasMood = mood != null;

    return Semantics(
      button: true,
      label: hasMood ? 'Mood: ${mood.label}. Change mood' : 'Add mood',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: hasMood ? AppTheme.surface : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.secondary, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasMood) ...[
                Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Text(
                hasMood ? mood.label : 'Add mood',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 18, color: AppTheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodSheet extends StatelessWidget {
  const _MoodSheet({required this.selected});

  final Mood? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text('How did it feel?', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              'Tap your current mood again to clear it.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            MoodPicker(
              selected: selected,
              onChanged: (mood) => Navigator.of(context).pop((mood: mood)),
            ),
          ],
        ),
      ),
    );
  }
}
