import 'package:vouch_v2/core/widgets/loaders/flickr_loader.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const Color primaryColor = Color(0xFF003DA5);
  static const Color accentColor = Color(0xFFFFC107);

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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.scan,
                  color: primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Scanner Ready',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate a safe scanner frame size
                    final double minDimension = constraints.maxHeight < constraints.maxWidth 
                        ? constraints.maxHeight 
                        : constraints.maxWidth;
                    final double frameSize = minDimension * 0.7;

                    return Stack(
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
                        // Scanner Frame
                        Container(
                          width: frameSize,
                          height: frameSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              _buildCornerGuide(
                                alignment: Alignment.topLeft,
                                border: const Border(
                                  top: BorderSide(color: accentColor, width: 3.5),
                                  left: BorderSide(color: accentColor, width: 3.5),
                                ),
                              ),
                              _buildCornerGuide(
                                alignment: Alignment.topRight,
                                border: const Border(
                                  top: BorderSide(color: accentColor, width: 3.5),
                                  right: BorderSide(color: accentColor, width: 3.5),
                                ),
                              ),
                              _buildCornerGuide(
                                alignment: Alignment.bottomLeft,
                                border: const Border(
                                  bottom: BorderSide(color: accentColor, width: 3.5),
                                  left: BorderSide(color: accentColor, width: 3.5),
                                ),
                              ),
                              _buildCornerGuide(
                                alignment: Alignment.bottomRight,
                                border: const Border(
                                  bottom: BorderSide(color: accentColor, width: 3.5),
                                  right: BorderSide(color: accentColor, width: 3.5),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  LucideIcons.qrCode,
                                  color: Colors.white,
                                  size: frameSize * 0.3, // Proportional icon size
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
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
                              color: Colors.black.withOpacity(0.5),
                              child: const Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: FlickrLoader(),
                                ),
                              ),
                            ),
                          ),
                        if (isLocked)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.75),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.lock,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Scanner Locked',
                                      style: GoogleFonts.poppins(
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
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(LucideIcons.lightbulb, size: 14, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tip: Hold the device steady and keep good lighting.',
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
