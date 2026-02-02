import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex; // Track which FAQ item is currently expanded

  // Theme-aware color helper methods
  Color _getTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return Colors.white;
      case AppTheme.lightTheme:
      default:
        return Colors.black87;
    }
  }

  Color _getSecondaryTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return Colors.white.withValues(alpha: 0.8);
      case AppTheme.lightTheme:
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getBackgroundColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return BlueThemeColors.primary; // Match app header color
      case AppTheme.lightTheme:
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getCardColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return Colors.white.withValues(alpha: 0.05);
      case AppTheme.lightTheme:
      default:
        return Colors.white;
    }
  }

  Color _getDividerColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return Colors.white.withValues(alpha: 0.3);
      case AppTheme.lightTheme:
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return Colors.white;
      case AppTheme.lightTheme:
      default:
        return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "menu_faq"),
          style: TextStyle(
            color: _getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // FAQ Items
            _buildFaqItem(
              index: 0,
              question: LanguageAwareStringHelper.getCurrent(context, "faq_question_4"),
              answer: LanguageAwareStringHelper.getCurrent(context, "faq_answer_4"),
            ),

            _buildFaqItem(
              index: 1,
              question: LanguageAwareStringHelper.getCurrent(context, "faq_question"),
              answer: LanguageAwareStringHelper.getCurrent(context, "faq_answer"),
            ),

            _buildFaqItem(
              index: 2,
              question: LanguageAwareStringHelper.getCurrent(context, "faq_question_5"),
              answer: LanguageAwareStringHelper.getCurrent(context, "faq_answer_5"),
            ),
            
            _buildFaqItem(
              index: 3,
              question: LanguageAwareStringHelper.getCurrent(context, "faq_question_2"),
              answer: LanguageAwareStringHelper.getCurrent(context, "faq_answer_2"),
            ),
            
            _buildFaqItem(
              index: 4,
              question: LanguageAwareStringHelper.getCurrent(context, "faq_question_3"),
              answer: LanguageAwareStringHelper.getCurrent(context, "faq_answer_3"),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseAnswerText(String text) {
    final List<TextSpan> spans = [];
    final List<String> lines = text.split('\n');
    
    // Get current language to determine which keywords to use
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(context);
    
    // Define bold keywords for each language
    final Map<String, List<String>> boldKeywordsByLanguage = {
      "en": [
        "Noise", "Guests", "Emotions", "Common activities", "Cleaning and household",
        "Communication", "Conflict resolution", "Food", "Order and quiet",
        "Check before signing", "Written agreement"
      ],
      "ru": [
        "Шум", "Гости", "Эмоции", "Общие дела", "Уборка и быт",
        "Общение", "Решение конфликтов", "Еда", "Порядок и тишина",
        "Проверка перед подписанием", "Письменное соглашение"
      ],
      "uz": [
        "Shovqin", "Mehmonlar", "His-tuyg'ular", "Umumiy ishlar", "Tozalash va uy ishlari",
        "Muloqot", "Nizolarni hal qilish", "Ovqat", "Tartib va jimlik",
        "Imzolashdan oldin tekshirish", "Yozma kelishuv"
      ],
    };
    
    final List<String> boldKeywords = boldKeywordsByLanguage[currentLanguage] ?? boldKeywordsByLanguage["en"]!;
    
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      
      // Check if this line is a section header (starts with specific keywords)
      bool isBold = false;
      for (String keyword in boldKeywords) {
        if (line.startsWith(keyword)) {
          isBold = true;
          break;
        }
      }
      
      if (isBold) {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: _getTextColor(),
            height: 1.8,
          ),
        ));
      } else {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(
            fontSize: 16,
            color: _getSecondaryTextColor(),
            height: 1.5,
          ),
        ));
      }
      
      // Add newline if not the last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return spans;
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final bool isExpanded = _expandedIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _getDividerColor(),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                if (isExpanded) {
                  _expandedIndex = null; // Collapse if already expanded
                } else {
                  _expandedIndex = index; // Expand this item and collapse others
                }
              });
            },
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: _getIconColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: _getSecondaryTextColor(),
                          height: 1.5,
                        ),
                        children: _parseAnswerText(answer),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
