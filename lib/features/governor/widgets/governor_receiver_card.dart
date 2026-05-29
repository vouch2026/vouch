import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../finance/models/payment_receiver_model.dart';

class GovernorReceiverCard extends StatefulWidget {
  final PaymentReceiverModel receiver;
  final VoidCallback? onEdit;

  const GovernorReceiverCard({
    super.key,
    required this.receiver,
    this.onEdit,
  });

  @override
  State<GovernorReceiverCard> createState() => _GovernorReceiverCardState();
}

class _GovernorReceiverCardState extends State<GovernorReceiverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = widget.receiver.bankType;
    final color = _getProviderColor(provider);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_isHovered ? 0.4 : 0.25),
                blurRadius: _isHovered ? 16 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  _getProviderIcon(provider),
                  size: 140,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (widget.onEdit != null)
                          IconButton(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Edit Reference',
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.receiver.accountName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCOUNT NUMBER',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatNumber(widget.receiver.accountNumber),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'gcash': return const Color(0xFF1F37A6);
      case 'maya': return const Color(0xFF00C344);
      case 'shopeepay': return const Color(0xFFEE4D2D);
      default: return const Color(0xFF1F37A6);
    }
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'gcash': return Icons.account_balance_wallet_rounded;
      case 'maya': return Icons.credit_card_rounded;
      default: return Icons.account_balance_wallet_rounded;
    }
  }

  String _formatNumber(String number) {
    if (number.length < 11) return number;
    return '${number.substring(0, 4)} ${number.substring(4, 7)} ${number.substring(7)}';
  }
}
