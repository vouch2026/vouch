import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/organization_repository.dart';
import '../providers/organization_provider.dart';
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
    required String name,
    required String code,
    required String description,
    String? adviserName,
    XFile? logoFile,
    XFile? bannerFile,
    String? logoUrl,
    String? bannerUrl,
    bool? requiresAdviserSignature,
    bool? requiresFacultyDeanSignature,
    bool? isClearanceActive,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      String? finalLogoUrl = logoUrl;
      String? finalBannerUrl = bannerUrl;

      if (logoFile != null) {
        finalLogoUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
          code: code,
          file: logoFile,
          isLogo: true,
        );
      }

      if (bannerFile != null) {
        finalBannerUrl = await ref.read(storageServiceProvider).uploadOrganizationAsset(
          code: code,
          file: bannerFile,
          isLogo: false,
        );
      }

      final Map<String, dynamic> updateData = {
        'name': name,
        'code': code,
        'description': description,
        'adviser_name': adviserName,
        'logo_url': finalLogoUrl,
        'banner_url': finalBannerUrl,
      };

      if (requiresAdviserSignature != null) {
        updateData['requires_adviser_signature'] = requiresAdviserSignature;
      }

      if (requiresFacultyDeanSignature != null) {
        updateData['requires_faculty_dean_signature'] = requiresFacultyDeanSignature;
      }

      if (isClearanceActive != null) {
        updateData['is_clearance_active'] = isClearanceActive;
      }

      await _repository.updateOrganization(id, updateData);
    });

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
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
