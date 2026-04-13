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
        final sendButtonColor = themeState.sendButtonColor;
        final borderColor = themeState.borderColor;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: inputBackgroundColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ThreeDTextField(
                  controller: controller,
                  hintText: L10n.get("type_message"),
                  backgroundColor: inputBackgroundColor,
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
