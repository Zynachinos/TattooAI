import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../features/billing/billing_service.dart';
import '../features/tattoo_generation/generation_service.dart';
import '../features/tattoo_generation/data/generation_request_model.dart';

// ─── Colors (matching paywall) ────────────────────────────────────────────────

const Color _bgDark = Color(0xFF0D0D0D);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _accentRed = Color(0xFFE84A5E);
const Color _accentCoral = Color(0xFFFF6B6B);
const Color _textPrimary = Color(0xFFF5F0EB);
const Color _textSecondary = Color(0xFFA09890);
const Color _textMuted = Color(0xFF6B6360);
const Color _dividerColor = Color(0xFF2A2520);

// ─── Screen ───────────────────────────────────────────────────────────────────

class CreateTattooScreen extends StatefulWidget {
  const CreateTattooScreen({super.key});

  @override
  State<CreateTattooScreen> createState() => _CreateTattooScreenState();
}

class _CreateTattooScreenState extends State<CreateTattooScreen> {
  final _picker = ImagePicker();
  final _promptController = TextEditingController();
  File? _baseImage;
  File? _referenceImage;

  bool get _isGenerating => GenerationService.instance.state.isActive;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // valid when base image picked AND at least reference OR prompt provided
  bool get _isValid =>
      _baseImage != null &&
      (_referenceImage != null || _promptController.text.trim().isNotEmpty);

  Future<void> _pickImage({required bool isBase}) async {
    final source = await _showSourceSheet();
    if (source == null) return;
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (picked == null) return;
    setState(() {
      if (isBase) {
        _baseImage = File(picked.path);
      } else {
        _referenceImage = File(picked.path);
      }
    });
  }

  Future<ImageSource?> _showSourceSheet() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B6360),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Photo Library',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _clearImage({required bool isBase}) {
    setState(() {
      if (isBase) {
        _baseImage = null;
      } else {
        _referenceImage = null;
      }
    });
  }

  Future<void> _onGenerateTapped() async {
    final billing = BillingService.instance;
    if (!billing.isPro) {
      await billing.presentPaywallIfNeeded();
      return;
    }
    await GenerationService.instance.generate(
      baseImage: _baseImage!,
      referenceImage: _referenceImage,
      prompt: _promptController.text.trim().isEmpty
          ? null
          : _promptController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'TattooAI',
          style: TextStyle(
              color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined,
                color: _textSecondary),
            tooltip: 'Abonnement verwalten',
            onPressed: () => BillingService.instance.presentCustomerCenter(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge(
            [BillingService.instance, GenerationService.instance]),
        builder: (context, _) {
          final billing = BillingService.instance;
          final gen = GenerationService.instance.state;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (!billing.isPro) ...[
                  _ProBanner(),
                  const SizedBox(height: 20),
                ],
                const Text(
                  '001 — CREATE',
                  style: TextStyle(
                      color: _accentCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Your next\n',
                        style: TextStyle(
                            color: _textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                      TextSpan(
                        text: 'tattoo.',
                        style: TextStyle(
                            color: _accentCoral,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Base Image ───────────────────────────────────────────────
                _SectionLabel(label: 'BASE IMAGE', required: true),
                const SizedBox(height: 10),
                _ImagePicker(
                  image: _baseImage,
                  hint: 'Upload a photo of the body part',
                  onPick: () => _pickImage(isBase: true),
                  onClear: () => _clearImage(isBase: true),
                ),
                const SizedBox(height: 24),

                // ── Reference Tattoo ─────────────────────────────────────────
                _SectionLabel(label: 'REFERENCE TATTOO', required: false),
                const SizedBox(height: 10),
                _ImagePicker(
                  image: _referenceImage,
                  hint: 'Upload a tattoo style or design',
                  onPick: () => _pickImage(isBase: false),
                  onClear: () => _clearImage(isBase: false),
                ),
                const SizedBox(height: 24),

                // ── Prompt ───────────────────────────────────────────────────
                _SectionLabel(label: 'DESCRIPTION', required: false),
                const SizedBox(height: 10),
                TextField(
                  controller: _promptController,
                  onChanged: (_) => setState(() {}),
                  maxLines: 4,
                  style: const TextStyle(color: _textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText:
                        'Describe the tattoo style, motifs, size, placement…',
                    hintStyle:
                        const TextStyle(color: _textMuted, fontSize: 14),
                    filled: true,
                    fillColor: _bgCard,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _accentCoral, width: 1.5),
                    ),
                  ),
                ),

                // ── Validation hint ──────────────────────────────────────────
                if (_baseImage != null && !_isValid)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Add a reference image or description to continue.',
                      style: TextStyle(color: _accentCoral, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 32),

                // ── Upload progress ──────────────────────────────────────────
                if (gen.isUploading) ...[
                  Row(
                    children: [
                      const Text('Uploading…',
                          style: TextStyle(
                              color: _textSecondary, fontSize: 12)),
                      const Spacer(),
                      Text(
                        '${(gen.uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                            color: _accentCoral,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: gen.uploadProgress,
                      backgroundColor: _bgCard,
                      color: _accentRed,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Status label ─────────────────────────────────────────────
                if (gen.status == GenerationStatus.queued ||
                    gen.status == GenerationStatus.generating)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _accentCoral)),
                        SizedBox(width: 10),
                        Text('Generating your tattoo…',
                            style: TextStyle(
                                color: _textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),

                // ── Error ────────────────────────────────────────────────────
                if (gen.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Error: ${gen.error}',
                      style: const TextStyle(
                          color: _accentRed, fontSize: 12),
                    ),
                  ),

                // ── Generate Button ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed:
                        (_isValid && !_isGenerating) ? _onGenerateTapped : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentRed,
                      disabledBackgroundColor:
                          _accentRed.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text(
                            'Generate Tattoo',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.required});
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5),
        ),
        if (required) ...[
          const SizedBox(width: 6),
          const Text('*',
              style: TextStyle(color: _accentCoral, fontSize: 13)),
        ],
      ],
    );
  }
}

// ─── Image Picker Widget ──────────────────────────────────────────────────────

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.image,
    required this.hint,
    required this.onPick,
    required this.onClear,
  });
  final File? image;
  final String hint;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage ? _accentRed : _dividerColor,
                width: hasImage ? 1.5 : 1,
              ),
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(image!, fit: BoxFit.cover),
                      ),
                      // dark gradient at bottom for label
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(11)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 14, color: _accentCoral),
                              SizedBox(width: 6),
                              Text(
                                'IMAGE SELECTED',
                                style: TextStyle(
                                  color: _accentCoral,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // X button top-right
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onClear,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined,
                          size: 32, color: _textMuted),
                      const SizedBox(height: 8),
                      Text(hint,
                          style: const TextStyle(
                              color: _textMuted, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text(
                        'TAP TO UPLOAD',
                        style: TextStyle(
                            color: _textMuted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ),
        // status row below the box
        if (hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 14, color: _accentCoral),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    image!.path.split('/').last,
                    style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                GestureDetector(
                  onTap: onClear,
                  child: const Text(
                    'REMOVE',
                    style: TextStyle(
                        color: _textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── Source Tile ─────────────────────────────────────────────────────────────

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFF6B6B)),
      title: Text(
        label,
        style: const TextStyle(color: Color(0xFFF5F0EB), fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}

// ─── Pro Banner ───────────────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BillingService.instance.presentPaywallIfNeeded(),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentRed.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: _accentCoral),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Pro freischalten für 6 Credits / Woche',
                style: TextStyle(color: _textSecondary, fontSize: 13),
              ),
            ),
            const Text(
              'UPGRADE',
              style: TextStyle(
                  color: _accentCoral,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
