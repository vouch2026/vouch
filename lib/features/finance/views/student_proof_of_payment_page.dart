import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/fee_model.dart';
import '../models/payment_receiver_model.dart';
import '../models/student_payment_model.dart';
import '../providers/finance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class StudentProofOfPaymentPage extends ConsumerStatefulWidget {
  final FeeModel fee;

  const StudentProofOfPaymentPage({
    super.key,
    required this.fee,
  });

  @override
  ConsumerState<StudentProofOfPaymentPage> createState() => _StudentProofOfPaymentPageState();
}

class _StudentProofOfPaymentPageState extends ConsumerState<StudentProofOfPaymentPage> {
  File? _uploadedFile;
  final TextEditingController _referenceController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  PaymentReceiverModel? _selectedReceiver;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      final int fileSize = await file.length();

      // 10MB limit
      if (fileSize > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size exceeds 10MB limit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _uploadedFile = file;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF003DA5),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitProof() async {
    if (_uploadedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a receipt first'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reference number'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedReceiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment receiver'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null || user.id == null) throw Exception('User not found');

      // Upload image
      final storageService = ref.read(storageServiceProvider);
      final proofPhotoUrl = await storageService.uploadPaymentReceipt(
        file: _uploadedFile!,
        studentId: user.id!,
        feeId: widget.fee.id!,
      );
      
      final repository = ref.read(financeRepositoryProvider);
      final payment = StudentPaymentModel(
        studentId: user.id!,
        feeId: widget.fee.id!,
        referenceNumber: _referenceController.text.trim(),
        proofPhotoUrl: proofPhotoUrl,
        paymentReceiverId: _selectedReceiver!.id,
        amountPaid: widget.fee.amount,
        status: 'Pending',
        paidAt: DateTime.now(),
      );

      await repository.submitStudentPayment(payment);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proof of payment submitted successfully'), backgroundColor: Colors.green),
      );
      
      // Invalidate the provider to refresh the list
      ref.invalidate(workspaceStudentPaymentsProvider);
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting proof: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiversAsync = ref.watch(paymentReceiversProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Proof of Payment',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: receiversAsync.when(
        data: (receivers) {
          if (_selectedReceiver == null && receivers.isNotEmpty) {
            _selectedReceiver = receivers.first;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentItemChip(),
                const SizedBox(height: AppSpacing.lg),
                if (receivers.length > 1) ...[
                  _buildProviderSelection(receivers),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_selectedReceiver != null) _buildTransferCard(_selectedReceiver!),
                const SizedBox(height: AppSpacing.lg),
                _buildUploadCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildReferenceField(),
                const SizedBox(height: AppSpacing.xl),
                _buildSubmitButton(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPaymentItemChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Item: ${widget.fee.name}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Amount to Pay: ₱${widget.fee.amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelection(List<PaymentReceiverModel> receivers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Provider',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: receivers.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final receiver = receivers[index];
              final isSelected = _selectedReceiver?.id == receiver.id;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedReceiver = receiver),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 85,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFF7FAFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.12),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getProviderIcon(receiver.bankType),
                        color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.7),
                        size: 26,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        receiver.bankType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransferCard(PaymentReceiverModel receiver) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Funds To ${receiver.bankType}',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCopyRow(
            label: '${receiver.bankType} Number',
            value: receiver.accountNumber,
            onCopy: () => _copyToClipboard(receiver.accountNumber, '${receiver.bankType} Number'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCopyRow(
            label: 'Account Name',
            value: receiver.accountName,
            onCopy: () => _copyToClipboard(receiver.accountName, 'Account Name'),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Note: Please ensure details are correct and keep your transaction screenshot.',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.black45, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.content_copy, color: AppColors.primary, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Proof of Transaction',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF7FAFF),
                image: _uploadedFile != null
                    ? DecorationImage(
                        image: FileImage(_uploadedFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _uploadedFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap to upload receipt',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Supports JPG/PNG • Max 10MB',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.black45),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Receipt Uploaded\nTap to change',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Number',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _referenceController,
          decoration: InputDecoration(
            hintText: 'Enter ${_selectedReceiver?.bankType ?? 'Provider'} Ref No.',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isSubmitting ? null : _submitProof,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                'Submit Proof',
                style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  IconData _getProviderIcon(String bankType) {
    switch (bankType.toLowerCase()) {
      case 'gcash': return Icons.account_balance_wallet_outlined;
      case 'maya': return Icons.credit_card_outlined;
      case 'shopeepay': return Icons.shopping_bag_outlined;
      case 'coins.ph': return Icons.currency_bitcoin;
      case 'grabpay': return Icons.directions_car_outlined;
      default: return Icons.credit_card_outlined;
    }
  }
}
