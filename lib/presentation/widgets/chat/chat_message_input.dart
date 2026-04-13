import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";

class ChatMessageInput extends StatelessWidget {

  const ChatMessageInput({
    required this.controller,
    required this.onSend,
    required this.isSendingMessage,
    super.key,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSendingMessage;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final inputBackgroundColor = themeState.inputBackgroundColor;
        final inputFieldBrightness = ThemeData.estimateBrightnessForColor(inputBackgroundColor);
        final inputFieldTextColor =
            inputFieldBrightness == Brightness.dark ? Colors.white : Colors.black;
        final inputFieldHintColor = inputFieldTextColor.withValues(alpha: 0.6);
        final sendButtonColor = themeState.sendButtonColor;
        final borderColor = themeState.borderColor;
        final scheme = Theme.of(context).colorScheme;
        final sendButtonBase = Color.lerp(
          scheme.surface,
          scheme.onSurface,
          themeState.isBlueTheme ? 0.06 : 0.02,
        )!;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: themeState.chatInputBarBackgroundColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ThreeDTextField(
                  controller: controller,
                  hintText: L10n.get("type_message"),
                  backgroundColor: inputBackgroundColor,
                  textColor: inputFieldTextColor,
                  hintColor: inputFieldHintColor,
                  cursorColor: inputFieldTextColor,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                ),
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
