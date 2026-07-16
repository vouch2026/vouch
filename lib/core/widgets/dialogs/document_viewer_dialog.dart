import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../theme/app_colors.dart';
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
    // Screen size checks to make it highly responsive on mobile/desktop/tablet
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    // On mobile, take full available width minus a clean 32px total margin (16px on each side)
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textGrey),
                  style: IconButton.styleFrom(
                    hoverColor: AppColors.accent.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            
            // Content (Asynchronous File Reader)
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load document.',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
                            ),
                            const SizedBox(height: 6),
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
                      padding: const EdgeInsets.only(right: 12),
                      child: SimpleMarkdownWidget(text: data),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            
            // Footer Action
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Close',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            trimmed.substring(2).trim(),
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
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
          padding: const EdgeInsets.only(left: 12, bottom: 8),
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
          padding: const EdgeInsets.only(bottom: 10),
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
            height: 1.5,
            fontSize: isCode ? 12 : 13.5,
          ),
        ));
      }
    }
    return TextSpan(children: spans);
  }
}
