import 'dart:io';
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
    File? logo,
    File? banner,
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
}

final organizationControllerProvider = AsyncNotifierProvider<OrganizationController, void>(() {
  return OrganizationController();
});
