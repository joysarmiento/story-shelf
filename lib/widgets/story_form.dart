import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/supabase_service.dart';
import '../models/story.dart';
import '../theme/app_theme.dart';
import 'app_back_button.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

class StoryForm extends StatefulWidget {
  const StoryForm({
    super.key,
    required this.headingText,
    required this.submitLabel,
    required this.onSubmit,
    this.initialStory,
  });

  final String headingText;
  final String submitLabel;
  final Story? initialStory;

  final Future<void> Function(Story story) onSubmit;

  @override
  State<StoryForm> createState() => _StoryFormState();
}

class _StoryFormState extends State<StoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.initialStory?.title,
  );
  late final _creatorController = TextEditingController(
    text: widget.initialStory?.creator,
  );
  late final _yearController = TextEditingController(
    text: widget.initialStory?.releaseYear?.toString(),
  );
  late final _currentProgressController = TextEditingController(
    text: widget.initialStory?.currentProgress == null
        ? null
        : widget.initialStory!.currentProgress.toInt().toString(),
  );
  late final _totalProgressController = TextEditingController(
    text: widget.initialStory?.totalProgress?.toInt().toString(),
  );

  Medium? _medium;
  StoryStatus? _status;
  double _rating = 0;
  String? _coverPath;
  bool _isSubmitting = false;
  bool _isUploadingCover = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _medium = widget.initialStory?.medium;
    _status = widget.initialStory?.status;
    _rating = widget.initialStory?.rating ?? 0;
    _coverPath = widget.initialStory?.coverPath;
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

  Future<void> _pickCover() async {
    final choice = await showModalBottomSheet<_CoverSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(_CoverSource.gallery),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.of(context).pop(_CoverSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Paste image URL'),
              onTap: () => Navigator.of(context).pop(_CoverSource.url),
            ),
          ],
        ),
      ),
    );

    switch (choice) {
      case _CoverSource.gallery:
        await _uploadCover(ImageSource.gallery);
      case _CoverSource.camera:
        await _uploadCover(ImageSource.camera);
      case _CoverSource.url:
        await _askForCoverUrl();
      case null:
        break;
    }
  }

  Future<void> _uploadCover(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingCover = true);
      final url = await SupabaseService.instance.uploadCoverImage(
        bytes: await picked.readAsBytes(),
        fileName: picked.name,
      );
      if (!mounted) return;
      setState(() => _coverPath = url);
    } catch (e) {
      debugPrint('Cover upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't upload that cover. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  Future<void> _askForCoverUrl() async {
    final controller = TextEditingController(text: _coverPath);
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Cover image URL',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Use this'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url != null && url.isNotEmpty) {
      setState(() => _coverPath = url);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medium == null || _status == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a medium and a status')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final base =
          widget.initialStory ??
          Story(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            userId: SupabaseService.instance.currentUser?.id ?? '',
            title: '',
            medium: _medium!,
            status: _status!,
            dateAdded: DateTime.now(),
          );

      final newProgress =
          double.tryParse(_currentProgressController.text.trim()) ?? 0;
      final progressChanged = newProgress != base.currentProgress;

      final story = base.copyWith(
        title: _titleController.text.trim(),
        creator: _creatorController.text.trim().isEmpty
            ? null
            : _creatorController.text.trim(),
        releaseYear: int.tryParse(_yearController.text.trim()),
        medium: _medium,
        status: _status,
        coverPath: _coverPath,
        rating: _rating == 0 ? null : _rating,
        currentProgress: newProgress,
        totalProgress: double.tryParse(_totalProgressController.text.trim()),
        lastReadAt: progressChanged ? DateTime.now() : null,
      );

      await widget.onSubmit(story);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              const SizedBox(height: AppTheme.spaceSm),

              _FieldLabel('Cover'),
              const SizedBox(height: AppTheme.spaceSm),
              GestureDetector(
                onTap: _isUploadingCover ? null : _pickCover,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    image: _coverPath == null
                        ? null
                        : DecorationImage(
                            image: NetworkImage(_coverPath!),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: _isUploadingCover
                      ? const CircularProgressIndicator()
                      : _coverPath != null
                      ? null
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppTheme.onSurface,
                              size: 32,
                            ),
                            const SizedBox(height: AppTheme.spaceXs),
                            Text(
                              'Upload cover page',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.error,
                              ),
                            ),
                          ],
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
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a title'
                    : null,
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Creator / Author'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Creator / Author',
                hint: 'e.g. Dahong',
                controller: _creatorController,
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Release Year'),
              const SizedBox(height: AppTheme.spaceSm),
              AppTextField(
                label: 'Release Year',
                hint: 'e.g. 2019',
                controller: _yearController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return int.tryParse(value.trim()) == null
                      ? 'Numbers only'
                      : null;
                },
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Medium'),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 200,
                child: _PillDropdown<Medium>(
                  value: _medium,
                  hint: 'Select Medium',
                  items: Medium.values,
                  labelOf: (m) => m.label,
                  onChanged: (m) => setState(() => _medium = m),
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
                  onChanged: (s) => setState(() => _status = s),
                ),
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel(
                'Progress (${_medium?.progressUnitLabel ?? "units"})',
              ),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 260,
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Current',
                        controller: _currentProgressController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceSm,
                      ),
                      child: Text('of', style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: AppTextField(
                        label: 'Total',
                        controller: _totalProgressController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spaceListGap),

              _FieldLabel('Rating'),
              const SizedBox(height: AppTheme.spaceSm),
              SizedBox(
                width: 160,
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

enum _CoverSource { gallery, camera, url }

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
          child: GestureDetector(
            onTapUp: (details) {
              final isRightHalf = details.localPosition.dx > 12;
              onChanged(index + (isRightHalf ? 1.0 : 0.5));
            },
            child: Icon(
              _iconFor(index),
              color: value > index
                  ? const Color(0xFFD9A441)
                  : AppTheme.onSurface,
            ),
          ),
        );
      }),
    );
  }
}
