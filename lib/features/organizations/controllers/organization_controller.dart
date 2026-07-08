import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/organization_repository.dart';
import '../providers/organization_provider.dart';
import '../providers/workspace_provider.dart';
import '../../../core/providers/storage_provider.dart';

class OrganizationController extends AsyncNotifier<void> {
  late final OrganizationRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(organizationRepositoryProvider);
  }

  Future<bool> createOrganization({
    required String name,
    required String code,
    required String description,
    required String type,
    String? campusId,
    String? facultyId,
    List<String> programIds = const [],
    XFile? logo,
    XFile? banner,
  }) async {
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      String? logoUrl;
      String? bannerUrl;

      if (logo != null) {
        logoUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
          code: code,
          file: logo,
          isLogo: true,
        );
      }

      if (banner != null) {
        bannerUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
          code: code,
          file: banner,
          isLogo: false,
        );
      }

      return await _repository.createOrganization(
        name: name,
        code: code,
        description: description,
        type: type,
        campusId: campusId,
        facultyId: facultyId,
        programIds: programIds,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
      );
    });

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    ref.invalidate(organizationsProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> updateOrganization({
    required String id,
    String? name,
    String? code,
    String? description,
    String? adviserName,
    XFile? logoFile,
    XFile? bannerFile,
    String? logoUrl,
    String? bannerUrl,
    bool? requiresAdviserSignature,
    bool? requiresProgramHeadSignature,
    bool? requiresFacultyDeanSignature,
    bool? allowMemberCardPrinting,
    bool? restrictClearanceRequest,
    bool? isClearanceActive,
    DateTime? clearancePeriodStart,
    DateTime? clearancePeriodEnd,
    bool clearClearancePeriod = false,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      String? finalLogoUrl = logoUrl;
      String? finalBannerUrl = bannerUrl;

      if (logoFile != null || bannerFile != null) {
        String activeCode = code ?? '';
        if (activeCode.isEmpty) {
          final org = await _repository.getOrganizationById(id);
          if (org != null) {
            activeCode = org.code;
          }
        }

        if (logoFile != null) {
          finalLogoUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
            code: activeCode,
            file: logoFile,
            isLogo: true,
          );
        }

        if (bannerFile != null) {
          finalBannerUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
            code: activeCode,
            file: bannerFile,
            isLogo: false,
          );
        }
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (code != null) updateData['code'] = code;
      if (description != null) updateData['description'] = description;
      if (adviserName != null) updateData['adviser_name'] = adviserName;
      if (finalLogoUrl != null) updateData['logo_url'] = finalLogoUrl;
      if (finalBannerUrl != null) updateData['banner_url'] = finalBannerUrl;

      if (requiresAdviserSignature != null) {
        updateData['requires_adviser_signature'] = requiresAdviserSignature;
      }

      if (requiresProgramHeadSignature != null) {
        updateData['requires_program_head_signature'] = requiresProgramHeadSignature;
      }

      if (requiresFacultyDeanSignature != null) {
        updateData['requires_faculty_dean_signature'] = requiresFacultyDeanSignature;
      }

      if (allowMemberCardPrinting != null) {
        updateData['allow_member_card_printing'] = allowMemberCardPrinting;
      }

      if (restrictClearanceRequest != null) {
        updateData['restrict_clearance_request'] = restrictClearanceRequest;
      }

      if (isClearanceActive != null) {
        updateData['is_clearance_active'] = isClearanceActive;
      }

      if (clearClearancePeriod) {
        updateData['clearance_period_start'] = null;
        updateData['clearance_period_end'] = null;
      } else {
        if (clearancePeriodStart != null) {
          updateData['clearance_period_start'] = clearancePeriodStart.toUtc().toIso8601String();
        }
        if (clearancePeriodEnd != null) {
          updateData['clearance_period_end'] = clearancePeriodEnd.toUtc().toIso8601String();
        }
      }

      await _repository.updateOrganization(id, updateData);
    });

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    final updatedOrg = await _repository.getOrganizationById(id);
    if (updatedOrg != null) {
      final currentWorkspace = ref.read(workspaceProvider);
      if (currentWorkspace.selectedOrganization?.id == id) {
        ref.read(workspaceProvider.notifier).updateSelectedOrganization(updatedOrg);
      }
    }

    ref.invalidate(organizationProvider(id));
    ref.invalidate(organizationsProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> deleteOrganization(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repository.deleteOrganization(id));
    
    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    ref.invalidate(organizationsProvider);
    state = const AsyncData(null);
    return true;
  }
}

final organizationControllerProvider = AsyncNotifierProvider<OrganizationController, void>(() {
  return OrganizationController();
});
