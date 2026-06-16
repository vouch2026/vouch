// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkspaceState implements DiagnosticableTreeMixin {

 OrganizationModel? get selectedOrganization; OrganizationMembershipModel? get activeMembership; AppRole? get activeRole; bool get isLoading; bool get isInitialized;
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkspaceStateCopyWith<WorkspaceState> get copyWith => _$WorkspaceStateCopyWithImpl<WorkspaceState>(this as WorkspaceState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkspaceState'))
    ..add(DiagnosticsProperty('selectedOrganization', selectedOrganization))..add(DiagnosticsProperty('activeMembership', activeMembership))..add(DiagnosticsProperty('activeRole', activeRole))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isInitialized', isInitialized));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkspaceState&&(identical(other.selectedOrganization, selectedOrganization) || other.selectedOrganization == selectedOrganization)&&(identical(other.activeMembership, activeMembership) || other.activeMembership == activeMembership)&&(identical(other.activeRole, activeRole) || other.activeRole == activeRole)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized));
}


@override
int get hashCode => Object.hash(runtimeType,selectedOrganization,activeMembership,activeRole,isLoading,isInitialized);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkspaceState(selectedOrganization: $selectedOrganization, activeMembership: $activeMembership, activeRole: $activeRole, isLoading: $isLoading, isInitialized: $isInitialized)';
}


}

/// @nodoc
abstract mixin class $WorkspaceStateCopyWith<$Res>  {
  factory $WorkspaceStateCopyWith(WorkspaceState value, $Res Function(WorkspaceState) _then) = _$WorkspaceStateCopyWithImpl;
@useResult
$Res call({
 OrganizationModel? selectedOrganization, OrganizationMembershipModel? activeMembership, AppRole? activeRole, bool isLoading, bool isInitialized
});


$OrganizationModelCopyWith<$Res>? get selectedOrganization;$OrganizationMembershipModelCopyWith<$Res>? get activeMembership;

}
/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._self, this._then);

  final WorkspaceState _self;
  final $Res Function(WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedOrganization = freezed,Object? activeMembership = freezed,Object? activeRole = freezed,Object? isLoading = null,Object? isInitialized = null,}) {
  return _then(_self.copyWith(
selectedOrganization: freezed == selectedOrganization ? _self.selectedOrganization : selectedOrganization // ignore: cast_nullable_to_non_nullable
as OrganizationModel?,activeMembership: freezed == activeMembership ? _self.activeMembership : activeMembership // ignore: cast_nullable_to_non_nullable
as OrganizationMembershipModel?,activeRole: freezed == activeRole ? _self.activeRole : activeRole // ignore: cast_nullable_to_non_nullable
as AppRole?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationModelCopyWith<$Res>? get selectedOrganization {
    if (_self.selectedOrganization == null) {
    return null;
  }

  return $OrganizationModelCopyWith<$Res>(_self.selectedOrganization!, (value) {
    return _then(_self.copyWith(selectedOrganization: value));
  });
}/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationMembershipModelCopyWith<$Res>? get activeMembership {
    if (_self.activeMembership == null) {
    return null;
  }

  return $OrganizationMembershipModelCopyWith<$Res>(_self.activeMembership!, (value) {
    return _then(_self.copyWith(activeMembership: value));
  });
}
}


/// Adds pattern-matching-related methods to [WorkspaceState].
extension WorkspaceStatePatterns on WorkspaceState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkspaceState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkspaceState value)  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkspaceState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrganizationModel? selectedOrganization,  OrganizationMembershipModel? activeMembership,  AppRole? activeRole,  bool isLoading,  bool isInitialized)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.selectedOrganization,_that.activeMembership,_that.activeRole,_that.isLoading,_that.isInitialized);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrganizationModel? selectedOrganization,  OrganizationMembershipModel? activeMembership,  AppRole? activeRole,  bool isLoading,  bool isInitialized)  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState():
return $default(_that.selectedOrganization,_that.activeMembership,_that.activeRole,_that.isLoading,_that.isInitialized);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrganizationModel? selectedOrganization,  OrganizationMembershipModel? activeMembership,  AppRole? activeRole,  bool isLoading,  bool isInitialized)?  $default,) {final _that = this;
switch (_that) {
case _WorkspaceState() when $default != null:
return $default(_that.selectedOrganization,_that.activeMembership,_that.activeRole,_that.isLoading,_that.isInitialized);case _:
  return null;

}
}

}

/// @nodoc


class _WorkspaceState with DiagnosticableTreeMixin implements WorkspaceState {
  const _WorkspaceState({this.selectedOrganization, this.activeMembership, this.activeRole, this.isLoading = false, this.isInitialized = false});
  

@override final  OrganizationModel? selectedOrganization;
@override final  OrganizationMembershipModel? activeMembership;
@override final  AppRole? activeRole;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isInitialized;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkspaceStateCopyWith<_WorkspaceState> get copyWith => __$WorkspaceStateCopyWithImpl<_WorkspaceState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WorkspaceState'))
    ..add(DiagnosticsProperty('selectedOrganization', selectedOrganization))..add(DiagnosticsProperty('activeMembership', activeMembership))..add(DiagnosticsProperty('activeRole', activeRole))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isInitialized', isInitialized));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkspaceState&&(identical(other.selectedOrganization, selectedOrganization) || other.selectedOrganization == selectedOrganization)&&(identical(other.activeMembership, activeMembership) || other.activeMembership == activeMembership)&&(identical(other.activeRole, activeRole) || other.activeRole == activeRole)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isInitialized, isInitialized) || other.isInitialized == isInitialized));
}


@override
int get hashCode => Object.hash(runtimeType,selectedOrganization,activeMembership,activeRole,isLoading,isInitialized);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WorkspaceState(selectedOrganization: $selectedOrganization, activeMembership: $activeMembership, activeRole: $activeRole, isLoading: $isLoading, isInitialized: $isInitialized)';
}


}

/// @nodoc
abstract mixin class _$WorkspaceStateCopyWith<$Res> implements $WorkspaceStateCopyWith<$Res> {
  factory _$WorkspaceStateCopyWith(_WorkspaceState value, $Res Function(_WorkspaceState) _then) = __$WorkspaceStateCopyWithImpl;
@override @useResult
$Res call({
 OrganizationModel? selectedOrganization, OrganizationMembershipModel? activeMembership, AppRole? activeRole, bool isLoading, bool isInitialized
});


@override $OrganizationModelCopyWith<$Res>? get selectedOrganization;@override $OrganizationMembershipModelCopyWith<$Res>? get activeMembership;

}
/// @nodoc
class __$WorkspaceStateCopyWithImpl<$Res>
    implements _$WorkspaceStateCopyWith<$Res> {
  __$WorkspaceStateCopyWithImpl(this._self, this._then);

  final _WorkspaceState _self;
  final $Res Function(_WorkspaceState) _then;

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedOrganization = freezed,Object? activeMembership = freezed,Object? activeRole = freezed,Object? isLoading = null,Object? isInitialized = null,}) {
  return _then(_WorkspaceState(
selectedOrganization: freezed == selectedOrganization ? _self.selectedOrganization : selectedOrganization // ignore: cast_nullable_to_non_nullable
as OrganizationModel?,activeMembership: freezed == activeMembership ? _self.activeMembership : activeMembership // ignore: cast_nullable_to_non_nullable
as OrganizationMembershipModel?,activeRole: freezed == activeRole ? _self.activeRole : activeRole // ignore: cast_nullable_to_non_nullable
as AppRole?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isInitialized: null == isInitialized ? _self.isInitialized : isInitialized // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationModelCopyWith<$Res>? get selectedOrganization {
    if (_self.selectedOrganization == null) {
    return null;
  }

  return $OrganizationModelCopyWith<$Res>(_self.selectedOrganization!, (value) {
    return _then(_self.copyWith(selectedOrganization: value));
  });
}/// Create a copy of WorkspaceState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrganizationMembershipModelCopyWith<$Res>? get activeMembership {
    if (_self.activeMembership == null) {
    return null;
  }

  return $OrganizationMembershipModelCopyWith<$Res>(_self.activeMembership!, (value) {
    return _then(_self.copyWith(activeMembership: value));
  });
}
}

// dart format on
