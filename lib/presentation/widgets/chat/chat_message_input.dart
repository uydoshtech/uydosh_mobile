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
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";

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
      listenable: Listenable.merge([ThemeState(), _dictationMeter]),
      builder: (context, child) {
        final themeState = ThemeState();
        final inputBackgroundColor = themeState.chatComposerFieldBackground(context);
        final inputFieldTextColor = themeState.chatComposerFieldTextColor(context);
        final inputFieldHintColor = themeState.chatComposerFieldHintColor(context);
        final sendButtonColor = themeState.sendButtonColor;
        final borderColor = themeState.borderColor;
        final scheme = Theme.of(context).colorScheme;
        final sendButtonBase = Color.lerp(
          scheme.surface,
          scheme.onSurface,
          themeState.isBlueTheme ? 0.06 : 0.02,
        )!;
        final recording = _dictationMeter.active;

        // Bottom safe area is handled below this bar (e.g. quick questions row);
        // avoid stacking large bottom padding here or it reads as empty space.
        final barDecoration =
            widget.blendWithGlassBackdrop
                ? BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: scheme.onSurface.withValues(alpha: 0.10),
                    ),
                  ),
                )
                : BoxDecoration(
                  color: themeState.chatInputBarBackgroundColor,
                  border: Border(top: BorderSide(color: borderColor)),
                );
        final fieldRadius =
            themeState.isBlueTheme
                ? ThreeDSurfaceStyle.wheelPickerPlateRadius
                : const BorderRadius.all(Radius.circular(24));

        Widget textField = ThreeDTextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          hintText: L10n.get("type_message"),
          backgroundColor: inputBackgroundColor,
          textColor: inputFieldTextColor,
          hintColor: inputFieldHintColor,
          cursorColor: inputFieldTextColor,
          borderRadius: fieldRadius,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.newline,
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
        );
        textField = ComposerEditGlow(
          enabled: widget.isEditingExistingMessage,
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
                          fillColor: inputFieldHintColor.withValues(alpha: 0.85),
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
                    onPressed:
                        widget.isSendingMessage
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
                        child:
                            widget.isSendingMessage
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
