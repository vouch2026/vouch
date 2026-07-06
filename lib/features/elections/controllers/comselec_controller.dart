import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/comselec_repository.dart';
import '../providers/comselec_provider.dart';
import '../../../core/providers/storage_provider.dart';

class ComselecController extends AsyncNotifier<void> {
  late final ComselecRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(comselecRepositoryProvider);
  }

  Future<bool> createComselec({
    required String name,
    required String code,
    required String description,
    String? campusId,
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

      return await _repository.createComselec(
        name: name,
        code: code,
        description: description,
        campusId: campusId,
        logoUrl: logoUrl,
        bannerUrl: bannerUrl,
      );
    });

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    ref.invalidate(comselecsProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> updateComselec({
    required String id,
    String? name,
    String? code,
    String? description,
    XFile? logoFile,
    XFile? bannerFile,
    String? logoUrl,
    String? bannerUrl,
    bool? requiresChairmanSignature,
    bool? requiresCommissionerSignature,
    bool? allowMemberCardPrinting,
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
          final com = await _repository.getComselecById(id);
          if (com != null) {
            activeCode = com.code;
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
      if (finalLogoUrl != null) updateData['logo_url'] = finalLogoUrl;
      if (finalBannerUrl != null) updateData['banner_url'] = finalBannerUrl;

      if (requiresChairmanSignature != null) {
        updateData['requires_chairman_signature'] = requiresChairmanSignature;
      }
      if (requiresCommissionerSignature != null) {
        updateData['requires_commissioner_signature'] = requiresCommissionerSignature;
      }
      if (allowMemberCardPrinting != null) {
        updateData['allow_member_card_printing'] = allowMemberCardPrinting;
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

      await _repository.updateComselec(id, updateData);
    });

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    ref.invalidate(comselecProvider(id));
    ref.invalidate(comselecsProvider);
    state = const AsyncData(null);
    return true;
  }

  Future<bool> deleteComselec(String id) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repository.deleteComselec(id));
    
    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      return false;
    }

    ref.invalidate(comselecsProvider);
    state = const AsyncData(null);
    return true;
  }
}

final comselecControllerProvider = AsyncNotifierProvider<ComselecController, void>(() {
  return ComselecController();
});
