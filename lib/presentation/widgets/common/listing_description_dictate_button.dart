import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:permission_handler/permission_handler.dart";
import "package:record/record.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/description_dictation_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Mic control for listing description: records audio, uploads to Whisper via backend.
class ListingDescriptionDictateButton extends StatefulWidget {
  const ListingDescriptionDictateButton({
    required this.controller,
    super.key,
    this.inlineWithCounter = false,
    this.maxDescriptionLength = 1000,
  });

  final TextEditingController controller;
  final bool inlineWithCounter;
  final int maxDescriptionLength;

  @override
  State<ListingDescriptionDictateButton> createState() =>
      _ListingDescriptionDictateButtonState();
}

class _ListingDescriptionDictateButtonState
    extends State<ListingDescriptionDictateButton> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _uploading = false;
  Timer? _maxDurationTimer;

  static const Duration _maxRecordDuration = Duration(seconds: 90);

  Color _accentColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  void dispose() {
    _maxDurationTimer?.cancel();
    if (_recording) {
      unawaited(_recorder.cancel());
    }
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _stopDueToMaxDuration() async {
    if (!_recording) return;
    await _stopRecordingAndTranscribe();
  }

  Future<void> _toggleRecording() async {
    if (_uploading) return;

    if (_recording) {
      HapticFeedbackUtils.lightImpact();
      await _stopRecordingAndTranscribe();
      return;
    }

    HapticFeedbackUtils.impact();
    if (!await SessionManager.isAuthenticated()) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("listing_translation_sign_in_required"),
      );
      return;
    }

    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("listing_description_dictate_mic_denied"),
      );
      return;
    }

    final supported =
        await _recorder.isEncoderSupported(AudioEncoder.aacLc);
    if (!supported) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("listing_description_dictate_failed"),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/listing_dict_${DateTime.now().millisecondsSinceEpoch}.m4a";

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("listing_description_dictate_failed"),
      );
      return;
    }

    _maxDurationTimer?.cancel();
    _maxDurationTimer = Timer(_maxRecordDuration, () {
      unawaited(_stopDueToMaxDuration());
    });

    if (!mounted) return;
    setState(() {
      _recording = true;
    });
  }

  Future<void> _stopRecordingAndTranscribe() async {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;

    if (!_recording) return;

    setState(() {
      _recording = false;
      _uploading = true;
    });

    String? filePath;
    try {
      filePath = await _recorder.stop();
    } catch (_) {
      filePath = null;
    }

    if (filePath == null || filePath.isEmpty) {
      if (mounted) {
        setState(() => _uploading = false);
      }
      return;
    }

    final lang = LanguageState().currentLanguage;
    final result = await getIt<DescriptionDictationService>()
        .transcribeRecording(filePath: filePath, languageCode: lang);

    try {
      final f = File(filePath);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}

    if (!mounted) return;

    setState(() => _uploading = false);

    if (result.authRequired) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_translation_sign_in_required"),
      );
      return;
    }
    if (result.notConfigured) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_description_dictate_not_configured"),
      );
      return;
    }
    if (!result.isSuccess) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_description_dictate_failed"),
      );
      return;
    }

    _appendTranscript(result.text!.trim());
  }

  void _appendTranscript(String transcript) {
    final cur = widget.controller.text;
    final sep = cur.isEmpty || cur.endsWith(" ") ? "" : " ";
    var next = "$cur$sep$transcript".trim();
    final maxLen = widget.maxDescriptionLength;
    if (next.length > maxLen) {
      next = next.substring(0, maxLen);
    }
    widget.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(context);
    final icon = _uploading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accent,
            ),
          )
        : ThemeIcon(
            _recording ? Icons.stop_circle : Icons.mic_none_outlined,
            size: 18,
            color: _recording ? Colors.redAccent : accent,
          );

    final labelStyle =
        (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
            .copyWith(color: accent);

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: icon,
        ),
        const SizedBox(width: 6),
        Text(L10n.get("listing_description_dictate"), style: labelStyle),
      ],
    );

    return TextButton(
      onPressed: _uploading ? null : _toggleRecording,
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: widget.inlineWithCounter
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
      ),
      child: child,
    );
  }
}
