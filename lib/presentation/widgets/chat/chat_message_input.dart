import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/composer_edit_invite_pulse.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";

class ChatMessageInput extends StatelessWidget {

  const ChatMessageInput({
    required this.controller,
    required this.onSend,
    required this.isSendingMessage,
    this.focusNode,
    this.blendWithGlassBackdrop = false,
    this.composerEditPulseTrigger,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSend;
  final bool isSendingMessage;

  /// Increment (e.g. `value++`) to play the green “edit here” border blink on
  /// the text field.
  final ValueListenable<int>? composerEditPulseTrigger;

  /// When true, no bar fill (used with a parent [BackdropFilter] glass panel).
  final bool blendWithGlassBackdrop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
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

        // Bottom safe area is handled below this bar (e.g. quick questions row);
        // avoid stacking large bottom padding here or it reads as empty space.
        final barDecoration =
            blendWithGlassBackdrop
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
                  controller: controller,
                  focusNode: focusNode,
                  hintText: L10n.get("type_message"),
                  backgroundColor: inputBackgroundColor,
                  textColor: inputFieldTextColor,
                  hintColor: inputFieldHintColor,
                  cursorColor: inputFieldTextColor,
                  borderRadius: fieldRadius,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                );
        final pulseTrigger = composerEditPulseTrigger;
        if (pulseTrigger != null) {
          textField = ComposerEditInvitePulse(
            pulseTrigger: pulseTrigger,
            borderRadius: fieldRadius,
            child: textField,
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: barDecoration,
          child: Row(
            children: [
              Expanded(
                child: textField,
              ),
              const SizedBox(width: 8),
              ThreeDPillButton(
                onPressed:
                    isSendingMessage
                        ? null
                        : () {
                          HapticFeedbackUtils.impact();
                          onSend();
                        },
                padding: const EdgeInsets.all(10),
                backgroundColor: sendButtonBase,
                borderSide: BorderSide(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                  width: 1,
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child:
                        isSendingMessage
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
        );
      },
    );
  }

}
