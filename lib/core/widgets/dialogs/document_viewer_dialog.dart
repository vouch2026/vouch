import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class DocumentViewerDialog extends StatelessWidget {
  final String title;
  final String filePath;

  const DocumentViewerDialog({
    super.key,
    required this.title,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    // Adaptable responsiveness: wider modal on desktop, full-width with clean margins on mobile
    final dialogWidth = isDesktop ? 600.0 : (size.width - 32).clamp(280.0, 500.0);
    final dialogHeight = size.height * 0.8;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: AppColors.white,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Cohesive with CreateCampusModal title layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                  style: IconButton.styleFrom(
                    hoverColor: AppColors.accent.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Content Pane
            Expanded(
              child: FutureBuilder<String>(
                future: rootBundle.loadString(filePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Failed to load document.',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.error, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Please try again later.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? '';
                  return Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: SimpleMarkdownWidget(text: data),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Footer Action Section
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, 
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleMarkdownWidget extends StatelessWidget {
  final String text;
  const SimpleMarkdownWidget({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
          child: Text(
            trimmed.substring(2).trim(),
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
          child: Text(
            trimmed.substring(4).trim(),
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ));
      } else if (trimmed.startsWith('* ')) {
        final content = trimmed.substring(2).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              Expanded(
                child: RichText(
                  text: _parseInlineFormatting(content),
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: RichText(
            text: _parseInlineFormatting(trimmed),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  TextSpan _parseInlineFormatting(String text) {
    final spans = <TextSpan>[];
    final boldParts = text.split('**');
    
    for (int i = 0; i < boldParts.length; i++) {
      final isBold = i % 2 == 1;
      final part = boldParts[i];
      
      final codeParts = part.split('`');
      for (int j = 0; j < codeParts.length; j++) {
        final isCode = j % 2 == 1;
        spans.add(TextSpan(
          text: codeParts[j],
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontFamily: isCode ? 'monospace' : null,
            backgroundColor: isCode ? Colors.grey.shade100 : null,
            color: isCode 
                ? AppColors.primaryDark 
                : (isBold ? AppColors.textDark : AppColors.textGrey),
            height: 1.6,
            fontSize: isCode ? 12 : 13.5,
          ),
        ));
      }
    }
    return TextSpan(children: spans);
  }
}
