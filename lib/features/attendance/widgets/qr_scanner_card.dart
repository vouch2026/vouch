import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';

class QrScannerCard extends StatelessWidget {
  const QrScannerCard({
    super.key,
    required this.scannerController,
    required this.onCodeDetected,
    required this.onRetryTap,
    required this.isProcessing,
    required this.scanModeLabel,
    this.isLocked = false,
  });

  final MobileScannerController scannerController;
  final ValueChanged<String> onCodeDetected;
  final VoidCallback onRetryTap;
  final bool isProcessing;
  final String scanModeLabel;
  final bool isLocked;

  static const Color _royalBlue = AppColors.primary;
  static const Color _gold = Color(0xFFFFC107);

  Widget _buildCornerGuide({
    required Alignment alignment,
    required Border border,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  LucideIcons.scan,
                  color: _royalBlue,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Scanner Ready',
                  style: TextStyle(
                    color: _royalBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: _royalBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _royalBlue.withOpacity(0.12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: MobileScanner(
                      controller: scannerController,
                      fit: BoxFit.cover,
                      onDetect: (capture) {
                        if (isProcessing) return;
                        for (final barcode in capture.barcodes) {
                          final rawValue = barcode.rawValue?.trim() ?? '';
                          if (rawValue.isNotEmpty) {
                            onCodeDetected(rawValue);
                            break;
                          }
                        }
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.black.withOpacity(0.12)),
                  ),
                  Container(
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _gold.withOpacity(0.95),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        _buildCornerGuide(
                          alignment: Alignment.topLeft,
                          border: const Border(
                            top: BorderSide(color: _royalBlue, width: 3),
                            left: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.topRight,
                          border: const Border(
                            top: BorderSide(color: _royalBlue, width: 3),
                            right: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.bottomLeft,
                          border: const Border(
                            bottom: BorderSide(color: _royalBlue, width: 3),
                            left: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        _buildCornerGuide(
                          alignment: Alignment.bottomRight,
                          border: const Border(
                            bottom: BorderSide(color: _royalBlue, width: 3),
                            right: BorderSide(color: _royalBlue, width: 3),
                          ),
                        ),
                        Center(
                          child: Icon(
                            LucideIcons.scan,
                            color: Colors.white,
                            size: 62,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        scanModeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isLocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.lock,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scanner Locked',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: Hold the device steady and keep good lighting for faster detection.',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
