import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/composer_edit_glow.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictate_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictation_meter.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class ChatMessageInput extends StatefulWidget {
  const ChatMessageInput({
    required this.controller,
    required this.onSend,
    required this.isSendingMessage,
    this.focusNode,
    this.blendWithGlassBackdrop = false,
    this.isEditingExistingMessage = false,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSend;
  final bool isSendingMessage;

  /// When true, paints a breathing green halo on the composer (edit existing
  /// bubble mode).
  final bool isEditingExistingMessage;

  /// When true, no bar fill (used with a parent [BackdropFilter] glass panel).
  final bool blendWithGlassBackdrop;

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  late final DictationMeterController _dictationMeter =
      DictationMeterController(barCount: 12);

  @override
  void dispose() {
    _dictationMeter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeState(),
        _dictationMeter,
        widget.controller,
      ]),
      builder: (context, child) {
        final themeState = ThemeState();
        final inputBackgroundColor =
            themeState.chatComposerFieldBackground(context);
        final inputFieldTextColor =
            themeState.chatComposerFieldTextColor(context);
        final inputFieldHintColor =
            themeState.chatComposerFieldHintColor(context);
        final sendButtonColor = themeState.sendButtonColor;
        final scheme = Theme.of(context).colorScheme;
        final sendButtonBase = Color.lerp(
          scheme.surface,
          scheme.onSurface,
          themeState.isBlueTheme ? 0.06 : 0.02,
        )!;
        final recording = _dictationMeter.active;

        // Bottom safe area is handled below this bar (e.g. quick questions row);
        // avoid stacking large bottom padding here or it reads as empty space.
        final barDecoration = widget.blendWithGlassBackdrop
            ? null
            : BoxDecoration(
                color: themeState.chatInputBarBackgroundColor,
              );
        final fieldRadius = themeState.isBlueTheme
            ? ThreeDSurfaceStyle.wheelPickerPlateRadius
            : const BorderRadius.all(Radius.circular(24));
        final inputBorderColor = themeState.isBlueTheme
            ? Colors.white.withValues(alpha: 0.35)
            : Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade400
                : scheme.onSurface.withValues(alpha: 0.08);
        final inputBorder = OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: inputBorderColor),
        );

        Widget textField = TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          cursorColor: inputFieldTextColor,
          style: TextStyle(color: inputFieldTextColor),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: L10n.get("type_message"),
            hintStyle: TextStyle(color: inputFieldHintColor),
            suffixIcon: ListingDescriptionDictateButton(
              controller: widget.controller,
              iconOnly: true,
              enabled: !widget.isSendingMessage,
              iconColor: inputFieldHintColor,
              maxDescriptionLength: 2000,
              dictationMeter: _dictationMeter,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            filled: true,
            fillColor: inputBackgroundColor,
            border: inputBorder,
            enabledBorder: inputBorder,
            disabledBorder: inputBorder,
            focusedBorder: inputBorder.copyWith(
              borderSide: BorderSide(color: inputBorderColor, width: 1.2),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        );
        final hasText = widget.controller.text.trim().isNotEmpty;
        textField = ComposerEditGlow(
          enabled: widget.isEditingExistingMessage && hasText,
          borderRadius: fieldRadius,
          child: textField,
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: barDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: recording
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: IgnorePointer(
                          child: ListingDescriptionDictationMeterCompact(
                            controller: _dictationMeter,
                            fillColor:
                                inputFieldHintColor.withValues(alpha: 0.85),
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              Row(
                children: [
                  Expanded(
                    child: textField,
                  ),
                  const SizedBox(width: 8),
                  ThreeDPillButton(
                    onPressed: widget.isSendingMessage
                        ? null
                        : () {
                            HapticFeedbackUtils.impact();
                            widget.onSend();
                          },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    backgroundColor: sendButtonBase,
                    borderSide: BorderSide(
                      color: scheme.onSurface.withValues(alpha: 0.06),
                      width: 1,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: widget.isSendingMessage
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    sendButtonColor,
                                  ),
                                ),
                              )
                            : ThemeIcon(Icons.send, color: sendButtonColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
