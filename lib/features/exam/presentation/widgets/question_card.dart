/// Question Card Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class QuestionCard extends StatelessWidget {
  final String stem;
  final List<String> choices;
  final int? selectedIndex;
  final int? correctIndex;
  final bool showAnswer;
  final ValueChanged<int>? onSelect;

  const QuestionCard({
    super.key,
    required this.stem,
    required this.choices,
    this.selectedIndex,
    this.correctIndex,
    this.showAnswer = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question stem
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.examColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            stem,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Choices
        ...List.generate(choices.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChoiceItem(context, index),
          );
        }),
      ],
    );
  }

  Widget _buildChoiceItem(BuildContext context, int index) {
    final isSelected = selectedIndex == index;
    final isCorrect = correctIndex == index;

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (showAnswer) {
      if (isCorrect) {
        bgColor = AppTheme.successColor.withValues(alpha: 0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
        trailingIcon = Icons.check_circle_rounded;
      } else if (isSelected && !isCorrect) {
        bgColor = AppTheme.errorColor.withValues(alpha: 0.1);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
        trailingIcon = Icons.cancel_rounded;
      } else {
        bgColor = Theme.of(context).cardColor;
        borderColor = Theme.of(context).dividerColor;
        textColor = AppTheme.textSecondaryColor;
      }
    } else {
      if (isSelected) {
        bgColor = AppTheme.primaryColor.withValues(alpha: 0.1);
        borderColor = AppTheme.primaryColor;
        textColor = AppTheme.primaryColor;
      } else {
        bgColor = Theme.of(context).cardColor;
        borderColor = Theme.of(context).dividerColor;
        textColor = Theme.of(context).textTheme.bodyLarge?.color ??
            AppTheme.textPrimaryColor;
      }
    }

    return InkWell(
      onTap: showAnswer ? null : () => onSelect?.call(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? borderColor
                    : Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? Colors.white : AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                choices[index],
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (trailingIcon != null) Icon(trailingIcon, color: borderColor),
          ],
        ),
      ),
    );
  }
}
