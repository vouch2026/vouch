import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import '../../data/payment_receiver_service.dart';
import '../../domain/payment_form_validators.dart';

class AdminAddBankCardScreen extends StatefulWidget {
  const AdminAddBankCardScreen({super.key});

  @override
  State<AdminAddBankCardScreen> createState() => _AdminAddBankCardScreenState();
}

class _AdminAddBankCardScreenState extends State<AdminAddBankCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _positionController = TextEditingController();
  
  String _selectedProvider = 'Maya';
  bool _isSaving = false;

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
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await PaymentReceiverService.instance.upsertReceiver(
        name: _nameController.text.trim(),
        gcashNumber: _numberController.text.trim(),
        position: _positionController.text.trim(),
        provider: _selectedProvider,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add card: $e'),
          backgroundColor: const Color(0xFFB3261E),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                title: 'New Reference',
                                subtitle: 'Add a new bank card or e-wallet for payments',
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
                                      label: 'Receiver Name',
                                      child: TextFormField(
                                        controller: _nameController,
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
                                        controller: _numberController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.next,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        decoration: _buildInputDecoration(
                                          hintText: 'Enter account or mobile number',
                                          icon: Ionicons.card_outline,
                                        ),
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter number' : null,
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
                                'This new reference card will be visible to all students in their payment options.',
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
                      text: 'Add Bank ',
                      style: TextStyle(color: _royalBlue),
                    ),
                    TextSpan(
                      text: 'Card',
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
          'CARD INFORMATION',
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: _royalBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor: _royalBlue.withOpacity(0.55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Bank Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
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
