import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

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
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: Colors.black, // Always use black text for visibility
                  ),
                  decoration: InputDecoration(
                    hintText: L10n.get("type_message"),
                    hintStyle: TextStyle(
                      color: Colors.grey[600], // Grey hint text
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isSendingMessage ? null : onSend,
                icon:
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
            ],
          ),
        );
      },
    );
  }

}
