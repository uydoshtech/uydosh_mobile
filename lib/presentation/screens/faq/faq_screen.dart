import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex; // Track which FAQ item is currently expanded

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "faq");
    getIt<AppAnalyticsService>().logFaqOpened();
  }

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
          L10n.get("menu_faq"),
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
              question: L10n.get("faq_question_4"),
              answer: L10n.get("faq_answer_4"),
            ),

            _buildFaqItem(
              index: 1,
              question: L10n.get("faq_question"),
              answer: L10n.get("faq_answer"),
            ),

            _buildFaqItem(
              index: 2,
              question: L10n.get("faq_question_5"),
              answer: L10n.get("faq_answer_5"),
            ),
            
            _buildFaqItem(
              index: 3,
              question: L10n.get("faq_question_2"),
              answer: L10n.get("faq_answer_2"),
            ),
            
            _buildFaqItem(
              index: 4,
              question: L10n.get("faq_question_3"),
              answer: L10n.get("faq_answer_3"),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _parseAnswerText(String text) {
    final spans = <TextSpan>[];
    final lines = text.split("\n");
    
    // Get current language to determine which keywords to use
    final currentLanguage = L10n.currentLanguage;
    
    // Define bold keywords for each language
    final boldKeywordsByLanguage = <String, List<String>>{
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
    
    final boldKeywords = boldKeywordsByLanguage[currentLanguage] ?? boldKeywordsByLanguage["en"]!;
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Check if this line is a section header (starts with specific keywords)
      var isBold = false;
      for (final keyword in boldKeywords) {
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
        spans.add(const TextSpan(text: "\n"));
      }
    }
    
    return spans;
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = _expandedIndex == index;
    
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
              HapticFeedbackUtils.impact();
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
                    child: ThemeIcon(
                      Icons.keyboard_arrow_down,
                      color: _getIconColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child:
                  isExpanded
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          16.0,
                          16.0,
                        ),
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
                      : const SizedBox(height: 0),
            ),
          ),
        ],
      ),
    );
  }
}
