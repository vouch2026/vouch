import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academic_term_model.dart';
import 'term_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// Holds the currently selected Academic Term in the global application shell
class SelectedAcademicTermNotifier extends StateNotifier<AcademicTermModel?> {
  SelectedAcademicTermNotifier() : super(null);

  bool get isSelected => state != null;

  void setTerm(AcademicTermModel term) {
    state = term;
  }
}

/// Global provider for the user's selected Academic Term
final selectedAcademicTermProvider =
    StateNotifierProvider<SelectedAcademicTermNotifier, AcademicTermModel?>((ref) {
  final notifier = SelectedAcademicTermNotifier();

  // Watch system active term and set as initial default once loaded
  ref.listen<AsyncValue<AcademicTermModel?>>(activeTermProvider, (previous, next) {
    if (next.value != null && !notifier.isSelected) {
      notifier.setTerm(next.value!);
    }
  });

  // If active term is already available synchronously
  final currentActive = ref.read(activeTermProvider).value;
  if (currentActive != null && !notifier.isSelected) {
    notifier.setTerm(currentActive);
  }

  return notifier;
});

/// Indicates whether the currently selected global academic term is in Read-Only Archive Mode
final isReadOnlyHistoricalTermProvider = Provider<bool>((ref) {
  final selectedTerm = ref.watch(selectedAcademicTermProvider);
  final activeTerm = ref.watch(activeTermProvider).value;

  if (selectedTerm == null || activeTerm == null) return false;

  // Read-only if the selected term is NOT the active system term
  return selectedTerm.id != activeTerm.id;
});

/// Provides the list of academic terms eligible for the logged-in user
final userEligibleTermsProvider = FutureProvider<List<AcademicTermModel>>((ref) async {
  final allTerms = await ref.watch(academicTermsProvider.future);
  final userProfile = ref.watch(userProfileProvider).value;

  if (userProfile == null) return allTerms;
  if (userProfile.role == 'super_admin') return allTerms;

  final userCreatedYear = userProfile.createdAt?.year ?? DateTime.now().year;

  // Filter terms so users cannot view terms before their registration window
  final eligible = allTerms.where((term) {
    final startYearStr = term.academicYear.split('–').first.split('-').first.trim();
    final startYear = int.tryParse(startYearStr) ?? 0;
    return startYear >= (userCreatedYear - 1);
  }).toList();

  return eligible.isEmpty ? allTerms : eligible;
});
