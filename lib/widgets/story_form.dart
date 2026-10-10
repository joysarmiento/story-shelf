import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/story.dart';
import '../models/story_search_result.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'app_back_button.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

enum _CoverSource { gallery, camera, url, remove }

class StoryForm extends StatefulWidget {
  const StoryForm({
    super.key,
    required this.headingText,
    required this.submitLabel,
    required this.onSubmit,
    this.initialStory,
    this.prefill,
  });

  final String headingText;
  final String submitLabel;
  final Story? initialStory;
  final StorySearchResult? prefill;

  final Future<void> Function(Story story) onSubmit;

  @override
  State<StoryForm> createState() => _StoryFormState();
}

class _StoryFormState extends State<StoryForm> {
  static const double _coverWidth = 132;

  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.initialStory?.title ?? widget.prefill?.title,
  );
  late final _creatorController = TextEditingController(
    text: widget.initialStory?.creator ?? widget.prefill?.creator,
  );
  late final _yearController = TextEditingController(
    text: (widget.initialStory?.releaseYear ?? widget.prefill?.year)
        ?.toString(),
  );
  late final _currentProgressController = TextEditingController(
    text: widget.initialStory?.currentProgress.toInt().toString(),
  );
  late final _totalProgressController = TextEditingController(
    text: (widget.initialStory?.totalProgress ?? widget.prefill?.totalProgress)
        ?.toInt()
        .toString(),
  );

  Medium? _medium;
  late StoryStatus _status;
  double _rating = 0;
  String? _coverPath;
  Uint8List? _pendingBytes;
  bool _mediumError = false;
  bool _isSubmitting = false;
  bool _isUploadingCover = false;
  final _picker = ImagePicker();

  bool get _hasCover => _coverPath != null || _pendingBytes != null;

  @override
  void initState() {
    super.initState();
    _medium =
        widget.initialStory?.medium ?? widget.prefill?.medium ?? Medium.book;
    _status = widget.initialStory?.status ?? StoryStatus.notStarted;
    _rating = widget.initialStory?.rating ?? 0;
    _coverPath = widget.initialStory?.coverPath ?? widget.prefill?.coverUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _yearController.dispose();
    _currentProgressController.dispose();
    _totalProgressController.dispose();
    super.dispose();
  }

  Future<void> _uploadCover(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pendingBytes = bytes;
        _isUploadingCover = true;
      });

      final url = await SupabaseService.instance.uploadCoverImage(
        bytes: bytes,
        fileName: picked.name,
      );
      if (!mounted) return;
      setState(() => _coverPath = url);
    } catch (e) {
      debugPrint('Cover upload failed: $e');
      if (!mounted) return;
      setState(() => _pendingBytes = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't upload that cover. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  Future<void> _askForCoverUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final text = controller.text.trim();
          final valid = _isHttpUrl(text);
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(
              'Cover from a web link',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(hintText: 'https://...'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  if (text.isNotEmpty && !valid)
                    Text(
                      'Paste a full link starting with http:// or https://',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppTheme.error),
                    ),
                  if (valid)
                    Center(
                      child: SizedBox(
                        width: 100,
                        child: AspectRatio(
                          aspectRatio: AppTheme.storyCardAspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              text,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              errorBuilder: (_, _, _) => Container(
                                color: AppTheme.surfaceVariant,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "Can't load this image",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: valid ? () => Navigator.of(context).pop(text) : null,
                child: const Text('Use this'),
              ),
            ],
          );
        },
      ),
    );
    controller.dispose();
    if (url != null && url.isNotEmpty) {
      setState(() {
        _coverPath = url;
        _pendingBytes = null;
      });
    }
  }

  void _removeCover() {
    setState(() {
      _coverPath = null;
      _pendingBytes = null;
    });
  }

  Future<void> _showCoverOptions() async {
    final choice = await showModalBottomSheet<_CoverSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) {
        final theme = Theme.of(context);

        Widget option(
          IconData icon,
          String label,
          _CoverSource source, {
          Color? color,
        }) {
          final tint = color ?? AppTheme.onSurface;
          return ListTile(
            leading: Icon(icon, color: tint),
            title: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: tint),
            ),
            onTap: () => Navigator.of(context).pop(source),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceMd,
                  AppTheme.spaceMd,
                  AppTheme.spaceMd,
                  AppTheme.spaceXs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add a cover', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppTheme.spaceXs),
                    Text(
                      'Choose how you want to add the cover image.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    option(
                      Icons.photo_library_outlined,
                      'Gallery',
                      _CoverSource.gallery,
                    ),
                    if (!kIsWeb)
                      option(
                        Icons.photo_camera_outlined,
                        'Camera',
                        _CoverSource.camera,
                      ),
                    option(Icons.link, 'Web link', _CoverSource.url),
                    if (_hasCover)
                      option(
                        Icons.delete_outline,
                        'Remove',
                        _CoverSource.remove,
                        color: AppTheme.error,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    switch (choice) {
      case _CoverSource.gallery:
        await _uploadCover(ImageSource.gallery);
      case _CoverSource.camera:
        await _uploadCover(ImageSource.camera);
      case _CoverSource.url:
        await _askForCoverUrl();
      case _CoverSource.remove:
        _removeCover();
      case null:
        break;
    }
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _coverPlaceholder(ThemeData theme, {bool broken = false}) {
    return Container(
      color: AppTheme.surfaceVariant,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            broken ? Icons.broken_image_outlined : Icons.add_photo_alternate,
            color: AppTheme.onSurface,
            size: 32,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            broken ? "Can't load\nthis cover" : 'No cover yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPreview(ThemeData theme) {
    final Widget image;
    if (_pendingBytes != null) {
      image = Image.memory(_pendingBytes!, fit: BoxFit.cover);
    } else if (_coverPath != null) {
      image = Image.network(
        _coverPath!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _coverPlaceholder(theme, broken: true),
      );
    } else {
      image = _coverPlaceholder(theme);
    }

    return SizedBox(
      width: _coverWidth,
      child: AspectRatio(
        aspectRatio: AppTheme.storyCardAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              image,
              if (_isUploadingCover)
                Container(
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverSection(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverPreview(theme),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverAction(
                icon: Icons.upload_outlined,
                label: 'Upload',
                onTap: _isUploadingCover ? null : _showCoverOptions,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                'Portrait images look best.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _setStatus(StoryStatus status) {
    setState(() {
      _status = status;
      if (_medium?.tracksProgress ?? false) {
        if (status == StoryStatus.notStarted) {
          _currentProgressController.text = '0';
        } else if (status == StoryStatus.completed) {
          final total = _totalProgressController.text.trim();
          if (total.isNotEmpty) _currentProgressController.text = total;
        }
      }
    });
  }

  Future<void> _handleSubmit() async {
    final formOk = _formKey.currentState!.validate();
    if (_medium == null) {
      setState(() => _mediumError = true);
      return;
    }
    if (!formOk) return;

    setState(() => _isSubmitting = true);
    try {
      final medium = _medium!;
      final base =
          widget.initialStory ??
          Story(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            userId: SupabaseService.instance.currentUser?.id ?? '',
            title: '',
            medium: medium,
            status: _status,
            dateAdded: DateTime.now(),
          );

      var current = base.currentProgress;
      var total = base.totalProgress;
      if (medium.tracksProgress) {
        current = double.tryParse(_currentProgressController.text.trim()) ?? 0;
        total = double.tryParse(_totalProgressController.text.trim());
        if (_status == StoryStatus.completed && total != null) {
          current = total;
        }
      }

      final creator = _creatorController.text.trim();

      final story = Story(
        id: base.id,
        userId: base.userId,
        title: _titleController.text.trim(),
        creator: creator.isEmpty ? null : creator,
        releaseYear: int.tryParse(_yearController.text.trim()),
        medium: medium,
        coverPath: _coverPath,
        status: _status,
        currentProgress: current,
        totalProgress: total,
        rating: _rating == 0 ? null : _rating,
        isFavorite: base.isFavorite,
        overview: base.overview,
        dateAdded: base.dateAdded,
        lastReadAt: current != base.currentProgress
            ? DateTime.now()
            : base.lastReadAt,
      );

      await widget.onSubmit(story);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medium = _medium;
    final unit = medium?.progressTitle;

    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              const SizedBox(height: AppTheme.spaceSm),

              _FieldLabel('Cover'),
              const SizedBox(height: AppTheme.spaceSm),
              _buildCoverSection(theme),
              const SizedBox(height: AppTheme.spaceMd),

              _FieldLabel('Medium'),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                'Tap to choose a book, comic, movie or series.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                children: [
                  for (final m in Medium.values) ...[
                    Expanded(
                      child: _TypeChip(
                        label: m.label,
                        selected: _medium == m,
                        onTap: () => setState(() {
                          _medium = m;
                          _mediumError = false;
                        }),
                      ),
                    ),
                    if (m != Medium.values.last)
                      const SizedBox(width: AppTheme.spaceSm),
                  ],
                ],
              ),

              if (_mediumError)
                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.spaceXs),
                  child: Text(
                    'Pick a book, comic, movie or series',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppTheme.spaceMd),

              _FieldLabel('Title'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Title',
                hint: 'e.g. Dam of the Forest',
                controller: _titleController,
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a title'
                    : null,
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel(medium?.creatorLabel ?? 'Creator'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: medium?.creatorLabel ?? 'Creator',
                hint: medium?.creatorHint ?? 'Optional',
                controller: _creatorController,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Release Year'),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 160,
                child: AppTextField(
                  label: 'Release Year',
                  hint: 'e.g. 2019',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final year = int.tryParse(value.trim());
                    if (year == null) return 'Numbers only';
                    if (year < 1800 || year > DateTime.now().year + 5) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Status'),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 200,
                child: _PillDropdown<StoryStatus>(
                  value: _status,
                  hint: 'Select Status',
                  items: StoryStatus.values,
                  labelOf: (s) => s.label,
                  onChanged: (s) {
                    if (s != null) _setStatus(s);
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              if (medium != null && medium.tracksProgress) ...[
                _FieldLabel('Progress ($unit)'),
                const SizedBox(height: AppTheme.spaceSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Current $unit',
                        hint: 'Current',
                        controller: _currentProgressController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          final cur = int.tryParse((value ?? '').trim());
                          final tot = int.tryParse(
                            _totalProgressController.text.trim(),
                          );
                          if (cur != null && tot != null && cur > tot) {
                            return 'More than total';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spaceSm,
                        14,
                        AppTheme.spaceSm,
                        0,
                      ),
                      child: Text('of', style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: AppTextField(
                        label: 'Total $unit',
                        hint: 'Total',
                        controller: _totalProgressController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceListGap),
              ],

              _FieldLabel('Rating'),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 200,
                height: 48,
                child: _StarRating(
                  value: _rating,
                  onChanged: (v) => setState(() => _rating = v),
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

class _CoverAction extends StatelessWidget {
  const _CoverAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: Material(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: AppTheme.onPrimary),
                  const SizedBox(width: AppTheme.spaceSm),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onPrimary,
                      ),
                    ),
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.secondary,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? AppTheme.onPrimary : AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  const _PillDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: theme.textTheme.bodyMedium),
          icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.onSurface),
          dropdownColor: AppTheme.surfaceVariant,
          items: items
              .map(
                (item) =>
                    DropdownMenuItem(value: item, child: Text(labelOf(item))),
              )
              .toList(),
          style: theme.textTheme.bodyMedium,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  IconData _iconFor(int index) {
    final threshold = index + 1;
    if (value >= threshold) return Icons.star;
    if (value >= threshold - 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final isRightHalf =
                    details.localPosition.dx > constraints.maxWidth / 2;
                final tapped = index + (isRightHalf ? 1.0 : 0.5);
                onChanged(tapped == value ? 0 : tapped);
              },
              child: Center(
                child: Icon(
                  _iconFor(index),
                  color: value > index
                      ? const Color(0xFFD9A441)
                      : AppTheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
