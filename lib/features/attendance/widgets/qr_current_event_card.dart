import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../events/models/event_model.dart';
import '../../../core/utils/time_formatter.dart';

class QrCurrentEventCard extends StatelessWidget {
  const QrCurrentEventCard({
    super.key,
    required this.event,
    required this.isTimeInActive,
    required this.onRecordTimeIn,
    required this.onRecordTimeOut,
    this.isActive = true,
  });

  final EventModel event;
  final bool isTimeInActive;
  final VoidCallback onRecordTimeIn;
  final VoidCallback onRecordTimeOut;
  final bool isActive;

  static const Color primaryColor = Color(0xFF003DA5);
  static const Color accentColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Expanded(
                child: Text(
                  event.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      (isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF455A64))
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Closed',
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF455A64),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                LucideIcons.mapPin,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                LucideIcons.clock,
                size: 15,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Time In: ${TimeFormatter.formatTimeRange(event.timeInStart, event.timeInEnd)} • Time Out: ${TimeFormatter.formatTimeRange(event.timeOutStart, event.timeOutEnd)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: isTimeInActive
                    ? ElevatedButton.icon(
                        onPressed: onRecordTimeIn,
                        icon: const Icon(LucideIcons.logIn, size: 18),
                        label: const Text('Time In'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: onRecordTimeIn,
                        icon: const Icon(LucideIcons.logIn, size: 18),
                        label: const Text('Time In'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: !isTimeInActive
                    ? ElevatedButton.icon(
                        onPressed: onRecordTimeOut,
                        icon: const Icon(LucideIcons.logOut, size: 18),
                        label: const Text('Time Out'),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: onRecordTimeOut,
                        icon: const Icon(LucideIcons.logOut, size: 18),
                        label: const Text('Time Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: primaryColor.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
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
