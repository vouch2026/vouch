// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WorkspaceState {
  OrganizationModel? get selectedOrganization =>
      throw _privateConstructorUsedError;
  OrganizationMembershipModel? get activeMembership =>
      throw _privateConstructorUsedError;
  AppRole? get activeRole => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceStateCopyWith<WorkspaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceStateCopyWith<$Res> {
  factory $WorkspaceStateCopyWith(
    WorkspaceState value,
    $Res Function(WorkspaceState) then,
  ) = _$WorkspaceStateCopyWithImpl<$Res, WorkspaceState>;
  @useResult
  $Res call({
    OrganizationModel? selectedOrganization,
    OrganizationMembershipModel? activeMembership,
    AppRole? activeRole,
    bool isLoading,
    bool isInitialized,
  });

  $OrganizationModelCopyWith<$Res>? get selectedOrganization;
  $OrganizationMembershipModelCopyWith<$Res>? get activeMembership;
}

/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res, $Val extends WorkspaceState>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOrganization = freezed,
    Object? activeMembership = freezed,
    Object? activeRole = freezed,
    Object? isLoading = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _value.copyWith(
            selectedOrganization: freezed == selectedOrganization
                ? _value.selectedOrganization
                : selectedOrganization // ignore: cast_nullable_to_non_nullable
                      as OrganizationModel?,
            activeMembership: freezed == activeMembership
                ? _value.activeMembership
                : activeMembership // ignore: cast_nullable_to_non_nullable
                      as OrganizationMembershipModel?,
            activeRole: freezed == activeRole
                ? _value.activeRole
                : activeRole // ignore: cast_nullable_to_non_nullable
                      as AppRole?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isInitialized: null == isInitialized
                ? _value.isInitialized
                : isInitialized // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationModelCopyWith<$Res>? get selectedOrganization {
    if (_value.selectedOrganization == null) {
      return null;
    }

    return $OrganizationModelCopyWith<$Res>(_value.selectedOrganization!, (
      value,
    ) {
      return _then(_value.copyWith(selectedOrganization: value) as $Val);
    });
  }

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrganizationMembershipModelCopyWith<$Res>? get activeMembership {
    if (_value.activeMembership == null) {
      return null;
    }

    return $OrganizationMembershipModelCopyWith<$Res>(
      _value.activeMembership!,
      (value) {
        return _then(_value.copyWith(activeMembership: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$WorkspaceStateImplCopyWith<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  factory _$$WorkspaceStateImplCopyWith(
    _$WorkspaceStateImpl value,
    $Res Function(_$WorkspaceStateImpl) then,
  ) = __$$WorkspaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    OrganizationModel? selectedOrganization,
    OrganizationMembershipModel? activeMembership,
    AppRole? activeRole,
    bool isLoading,
    bool isInitialized,
  });

  @override
  $OrganizationModelCopyWith<$Res>? get selectedOrganization;
  @override
  $OrganizationMembershipModelCopyWith<$Res>? get activeMembership;
}

/// @nodoc
class __$$WorkspaceStateImplCopyWithImpl<$Res>
    extends _$WorkspaceStateCopyWithImpl<$Res, _$WorkspaceStateImpl>
    implements _$$WorkspaceStateImplCopyWith<$Res> {
  __$$WorkspaceStateImplCopyWithImpl(
    _$WorkspaceStateImpl _value,
    $Res Function(_$WorkspaceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOrganization = freezed,
    Object? activeMembership = freezed,
    Object? activeRole = freezed,
    Object? isLoading = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _$WorkspaceStateImpl(
        selectedOrganization: freezed == selectedOrganization
            ? _value.selectedOrganization
            : selectedOrganization // ignore: cast_nullable_to_non_nullable
                  as OrganizationModel?,
        activeMembership: freezed == activeMembership
            ? _value.activeMembership
            : activeMembership // ignore: cast_nullable_to_non_nullable
                  as OrganizationMembershipModel?,
        activeRole: freezed == activeRole
            ? _value.activeRole
            : activeRole // ignore: cast_nullable_to_non_nullable
                  as AppRole?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isInitialized: null == isInitialized
            ? _value.isInitialized
            : isInitialized // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$WorkspaceStateImpl
    with DiagnosticableTreeMixin
    implements _WorkspaceState {
  const _$WorkspaceStateImpl({
    this.selectedOrganization,
    this.activeMembership,
    this.activeRole,
    this.isLoading = false,
    this.isInitialized = false,
  });

  @override
  final OrganizationModel? selectedOrganization;
  @override
  final OrganizationMembershipModel? activeMembership;
  @override
  final AppRole? activeRole;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WorkspaceState(selectedOrganization: $selectedOrganization, activeMembership: $activeMembership, activeRole: $activeRole, isLoading: $isLoading, isInitialized: $isInitialized)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'WorkspaceState'))
      ..add(DiagnosticsProperty('selectedOrganization', selectedOrganization))
      ..add(DiagnosticsProperty('activeMembership', activeMembership))
      ..add(DiagnosticsProperty('activeRole', activeRole))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isInitialized', isInitialized));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceStateImpl &&
            (identical(other.selectedOrganization, selectedOrganization) ||
                other.selectedOrganization == selectedOrganization) &&
            (identical(other.activeMembership, activeMembership) ||
                other.activeMembership == activeMembership) &&
            (identical(other.activeRole, activeRole) ||
                other.activeRole == activeRole) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedOrganization,
    activeMembership,
    activeRole,
    isLoading,
    isInitialized,
  );

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      __$$WorkspaceStateImplCopyWithImpl<_$WorkspaceStateImpl>(
        this,
        _$identity,
      );
}

abstract class _WorkspaceState implements WorkspaceState {
  const factory _WorkspaceState({
    final OrganizationModel? selectedOrganization,
    final OrganizationMembershipModel? activeMembership,
    final AppRole? activeRole,
    final bool isLoading,
    final bool isInitialized,
  }) = _$WorkspaceStateImpl;

  @override
  OrganizationModel? get selectedOrganization;
  @override
  OrganizationMembershipModel? get activeMembership;
  @override
  AppRole? get activeRole;
  @override
  bool get isLoading;
  @override
  bool get isInitialized;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
