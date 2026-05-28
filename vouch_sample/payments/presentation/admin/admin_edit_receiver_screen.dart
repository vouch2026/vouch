import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/payment_receiver_service.dart';
import '../../domain/payment_form_validators.dart';

class EditReceiverDetailsScreen extends StatefulWidget {
  final String? receiverId;

  const EditReceiverDetailsScreen({super.key, this.receiverId});

  @override
  State<EditReceiverDetailsScreen> createState() =>
      _EditReceiverDetailsScreenState();
}

class _EditReceiverDetailsScreenState extends State<EditReceiverDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _accountNameController;
  late final TextEditingController _positionController;
  late final TextEditingController _gcashNumberController;

  String _editingReceiverId = PaymentReceiverService.defaultReceiverId;
  String _selectedProvider = 'GCash';
  bool _isLoading = false;
  bool _isFetchingReceiver = false;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _fieldBorder = Color(0xFFDAE2EF);
  static const Color _fieldFill = Color(0xFFF8FAFD);
  static const Color _mutedText = Color(0xFF6B7280);
  static const Color _titleText = Color(0xFF1F2937);

  final List<String> _providers = [
    'GCash',
    'Maya',
    'ShopeePay',
    'Coins.ph',
    'GrabPay',
  ];

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController();
    _positionController = TextEditingController();
    _gcashNumberController = TextEditingController();
    _loadReceiverDetails();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _positionController.dispose();
    _gcashNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() ||
        _isLoading ||
        _isFetchingReceiver) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PaymentReceiverService.instance.upsertReceiver(
        receiverId: _editingReceiverId,
        name: _accountNameController.text.trim(),
        gcashNumber: _gcashNumberController.text.trim(),
        position: _positionController.text.trim(),
        provider: _selectedProvider,
        isActive: true,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      if (!mounted) return;
      _showErrorSnackBar(_supabaseErrorMessage(error));
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Unable to save receiver details. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReceiverDetails() async {
    setState(() => _isFetchingReceiver = true);

    try {
      final receiver = widget.receiverId != null
          ? await PaymentReceiverService.instance.fetchReceiverById(widget.receiverId!)
          : await PaymentReceiverService.instance.fetchActiveReceiver();

      if (!mounted) return;

      if (receiver != null) {
        setState(() {
          _editingReceiverId = receiver.id;
          _selectedProvider = receiver.provider;
          _accountNameController.text = receiver.name;
          _positionController.text = receiver.position;
          _gcashNumberController.text = receiver.gcashNumber.replaceAll(RegExp(r'\D'), '');
        });
      } else if (widget.receiverId == null) {
        _editingReceiverId = PaymentReceiverService.defaultReceiverId;
      }
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('Unable to load receiver details. Please try again.');
    } finally {
      if (mounted) setState(() => _isFetchingReceiver = false);
    }
  }

  String _supabaseErrorMessage(PostgrestException error) {
    final message = error.message.trim();
    if (message.isNotEmpty) return message;
    return 'Unexpected database error. Please try again.';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFB3261E)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Background Decorations
              Positioned(
                top: 100,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: 240,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _royalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(75),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: _isFetchingReceiver 
                        ? const Center(child: CircularProgressIndicator(color: _royalBlue))
                        : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                title: 'Receiver Setup',
                                subtitle: 'Update payout details shown on payment screens',
                              ),
                              const SizedBox(height: 16),
                              _buildFormCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCardHeader(),
                                    const SizedBox(height: 20),
                                    _buildLabeledField(
                                      label: 'Select Provider',
                                      child: SizedBox(
                                        height: 90,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _providers.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                                          itemBuilder: (context, index) {
                                            final provider = _providers[index];
                                            final isSelected = _selectedProvider == provider;
                                            return GestureDetector(
                                              onTap: () => setState(() => _selectedProvider = provider),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: 85,
                                                decoration: BoxDecoration(
                                                  color: isSelected ? _royalBlue : _fieldFill,
                                                  borderRadius: BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: isSelected ? _royalBlue : _fieldBorder,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      _getProviderIcon(provider),
                                                      color: isSelected ? Colors.white : _royalBlue.withOpacity(0.7),
                                                      size: 26,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      provider,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                        color: isSelected ? Colors.white : _mutedText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildLabeledField(
                                      label: 'Account Name',
                                      child: TextFormField(
                                        controller: _accountNameController,
                                        textInputAction: TextInputAction.next,
                                        decoration: _buildInputDecoration(
                                          hintText: 'e.g., Juan Dela Cruz',
                                          icon: Ionicons.person_outline,
                                        ),
                                        validator: PaymentFormValidators.receiverAccountName,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: 'Account Number',
                                      child: TextFormField(
                                        controller: _gcashNumberController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: _buildInputDecoration(
                                          hintText: '09XXXXXXXXX',
                                          icon: Ionicons.card_outline,
                                        ),
                                        validator: PaymentFormValidators.receiverGcashNumber,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _buildLabeledField(
                                      label: "Receiver's Position",
                                      child: TextFormField(
                                        controller: _positionController,
                                        textInputAction: TextInputAction.done,
                                        decoration: _buildInputDecoration(
                                          hintText: 'e.g., Treasurer',
                                          icon: Ionicons.briefcase_outline,
                                        ),
                                        validator: PaymentFormValidators.receiverPosition,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'These changes will be reflected immediately on all student payment screens.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _mutedText.withOpacity(0.9),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildBottomAction(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: SizedBox(
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Ionicons.arrow_back, color: _royalBlue),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Edit ',
                      style: TextStyle(color: _royalBlue),
                    ),
                    TextSpan(
                      text: 'Receiver',
                      style: TextStyle(color: _gold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _royalBlue,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.black.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Ionicons.card_outline, color: _gold, size: 18),
        ),
        const SizedBox(width: 8),
        const Text(
          'RECIPIENT DETAILS',
          style: TextStyle(
            color: _mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _titleText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _mutedText, fontSize: 13),
      prefixIcon: Icon(icon, color: _royalBlue.withOpacity(0.6), size: 19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _royalBlue, width: 1.8),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFB3261E)),
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    );
  }

  Future<void> _deleteReceiver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Remove Card',
          style: TextStyle(color: _royalBlue, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove this receiver card? This action cannot be undone.',
          style: TextStyle(color: _titleText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await PaymentReceiverService.instance.deleteReceiver(_editingReceiverId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Failed to delete receiver: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBottomAction() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _royalBlue.withOpacity(0.08))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading || _isFetchingReceiver ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _royalBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: _royalBlue.withOpacity(0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _isLoading || _isFetchingReceiver ? null : _deleteReceiver,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB3261E),
                  side: const BorderSide(color: Color(0xFFB3261E), width: 1.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Ionicons.trash_outline, size: 20),
                label: const Text(
                  'Remove Reference',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String provider) {
    switch (provider) {
      case 'GCash': return Ionicons.wallet_outline;
      case 'Maya': return Ionicons.card_outline;
      case 'ShopeePay': return Ionicons.bag_handle_outline;
      case 'Coins.ph': return Ionicons.logo_bitcoin;
      case 'GrabPay': return Ionicons.car_outline;
      default: return Ionicons.card_outline;
    }
  }
}
