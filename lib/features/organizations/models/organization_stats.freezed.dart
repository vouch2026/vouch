// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'organization_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrganizationStats {

 int get totalOrganizations; int get activeOrganizations; int get inactiveOrganizations; int get totalMembers; int get activeOfficers; int get pendingApplications; int get orgsWithElections; int get orgsWithSanctions; double get complianceRate; double get trendPercentage;
/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationStatsCopyWith<OrganizationStats> get copyWith => _$OrganizationStatsCopyWithImpl<OrganizationStats>(this as OrganizationStats, _$identity);

  /// Serializes this OrganizationStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrganizationStats&&(identical(other.totalOrganizations, totalOrganizations) || other.totalOrganizations == totalOrganizations)&&(identical(other.activeOrganizations, activeOrganizations) || other.activeOrganizations == activeOrganizations)&&(identical(other.inactiveOrganizations, inactiveOrganizations) || other.inactiveOrganizations == inactiveOrganizations)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeOfficers, activeOfficers) || other.activeOfficers == activeOfficers)&&(identical(other.pendingApplications, pendingApplications) || other.pendingApplications == pendingApplications)&&(identical(other.orgsWithElections, orgsWithElections) || other.orgsWithElections == orgsWithElections)&&(identical(other.orgsWithSanctions, orgsWithSanctions) || other.orgsWithSanctions == orgsWithSanctions)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOrganizations,activeOrganizations,inactiveOrganizations,totalMembers,activeOfficers,pendingApplications,orgsWithElections,orgsWithSanctions,complianceRate,trendPercentage);

@override
String toString() {
  return 'OrganizationStats(totalOrganizations: $totalOrganizations, activeOrganizations: $activeOrganizations, inactiveOrganizations: $inactiveOrganizations, totalMembers: $totalMembers, activeOfficers: $activeOfficers, pendingApplications: $pendingApplications, orgsWithElections: $orgsWithElections, orgsWithSanctions: $orgsWithSanctions, complianceRate: $complianceRate, trendPercentage: $trendPercentage)';
}


}

/// @nodoc
abstract mixin class $OrganizationStatsCopyWith<$Res>  {
  factory $OrganizationStatsCopyWith(OrganizationStats value, $Res Function(OrganizationStats) _then) = _$OrganizationStatsCopyWithImpl;
@useResult
$Res call({
 int totalOrganizations, int activeOrganizations, int inactiveOrganizations, int totalMembers, int activeOfficers, int pendingApplications, int orgsWithElections, int orgsWithSanctions, double complianceRate, double trendPercentage
});




}
/// @nodoc
class _$OrganizationStatsCopyWithImpl<$Res>
    implements $OrganizationStatsCopyWith<$Res> {
  _$OrganizationStatsCopyWithImpl(this._self, this._then);

  final OrganizationStats _self;
  final $Res Function(OrganizationStats) _then;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalOrganizations = null,Object? activeOrganizations = null,Object? inactiveOrganizations = null,Object? totalMembers = null,Object? activeOfficers = null,Object? pendingApplications = null,Object? orgsWithElections = null,Object? orgsWithSanctions = null,Object? complianceRate = null,Object? trendPercentage = null,}) {
  return _then(_self.copyWith(
totalOrganizations: null == totalOrganizations ? _self.totalOrganizations : totalOrganizations // ignore: cast_nullable_to_non_nullable
as int,activeOrganizations: null == activeOrganizations ? _self.activeOrganizations : activeOrganizations // ignore: cast_nullable_to_non_nullable
as int,inactiveOrganizations: null == inactiveOrganizations ? _self.inactiveOrganizations : inactiveOrganizations // ignore: cast_nullable_to_non_nullable
as int,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeOfficers: null == activeOfficers ? _self.activeOfficers : activeOfficers // ignore: cast_nullable_to_non_nullable
as int,pendingApplications: null == pendingApplications ? _self.pendingApplications : pendingApplications // ignore: cast_nullable_to_non_nullable
as int,orgsWithElections: null == orgsWithElections ? _self.orgsWithElections : orgsWithElections // ignore: cast_nullable_to_non_nullable
as int,orgsWithSanctions: null == orgsWithSanctions ? _self.orgsWithSanctions : orgsWithSanctions // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,trendPercentage: null == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrganizationStats].
extension OrganizationStatsPatterns on OrganizationStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrganizationStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrganizationStats value)  $default,){
final _that = this;
switch (_that) {
case _OrganizationStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrganizationStats value)?  $default,){
final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalOrganizations,  int activeOrganizations,  int inactiveOrganizations,  int totalMembers,  int activeOfficers,  int pendingApplications,  int orgsWithElections,  int orgsWithSanctions,  double complianceRate,  double trendPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
return $default(_that.totalOrganizations,_that.activeOrganizations,_that.inactiveOrganizations,_that.totalMembers,_that.activeOfficers,_that.pendingApplications,_that.orgsWithElections,_that.orgsWithSanctions,_that.complianceRate,_that.trendPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalOrganizations,  int activeOrganizations,  int inactiveOrganizations,  int totalMembers,  int activeOfficers,  int pendingApplications,  int orgsWithElections,  int orgsWithSanctions,  double complianceRate,  double trendPercentage)  $default,) {final _that = this;
switch (_that) {
case _OrganizationStats():
return $default(_that.totalOrganizations,_that.activeOrganizations,_that.inactiveOrganizations,_that.totalMembers,_that.activeOfficers,_that.pendingApplications,_that.orgsWithElections,_that.orgsWithSanctions,_that.complianceRate,_that.trendPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalOrganizations,  int activeOrganizations,  int inactiveOrganizations,  int totalMembers,  int activeOfficers,  int pendingApplications,  int orgsWithElections,  int orgsWithSanctions,  double complianceRate,  double trendPercentage)?  $default,) {final _that = this;
switch (_that) {
case _OrganizationStats() when $default != null:
return $default(_that.totalOrganizations,_that.activeOrganizations,_that.inactiveOrganizations,_that.totalMembers,_that.activeOfficers,_that.pendingApplications,_that.orgsWithElections,_that.orgsWithSanctions,_that.complianceRate,_that.trendPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrganizationStats implements OrganizationStats {
  const _OrganizationStats({this.totalOrganizations = 0, this.activeOrganizations = 0, this.inactiveOrganizations = 0, this.totalMembers = 0, this.activeOfficers = 0, this.pendingApplications = 0, this.orgsWithElections = 0, this.orgsWithSanctions = 0, this.complianceRate = 0.0, this.trendPercentage = 0.0});
  factory _OrganizationStats.fromJson(Map<String, dynamic> json) => _$OrganizationStatsFromJson(json);

@override@JsonKey() final  int totalOrganizations;
@override@JsonKey() final  int activeOrganizations;
@override@JsonKey() final  int inactiveOrganizations;
@override@JsonKey() final  int totalMembers;
@override@JsonKey() final  int activeOfficers;
@override@JsonKey() final  int pendingApplications;
@override@JsonKey() final  int orgsWithElections;
@override@JsonKey() final  int orgsWithSanctions;
@override@JsonKey() final  double complianceRate;
@override@JsonKey() final  double trendPercentage;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationStatsCopyWith<_OrganizationStats> get copyWith => __$OrganizationStatsCopyWithImpl<_OrganizationStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrganizationStats&&(identical(other.totalOrganizations, totalOrganizations) || other.totalOrganizations == totalOrganizations)&&(identical(other.activeOrganizations, activeOrganizations) || other.activeOrganizations == activeOrganizations)&&(identical(other.inactiveOrganizations, inactiveOrganizations) || other.inactiveOrganizations == inactiveOrganizations)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeOfficers, activeOfficers) || other.activeOfficers == activeOfficers)&&(identical(other.pendingApplications, pendingApplications) || other.pendingApplications == pendingApplications)&&(identical(other.orgsWithElections, orgsWithElections) || other.orgsWithElections == orgsWithElections)&&(identical(other.orgsWithSanctions, orgsWithSanctions) || other.orgsWithSanctions == orgsWithSanctions)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalOrganizations,activeOrganizations,inactiveOrganizations,totalMembers,activeOfficers,pendingApplications,orgsWithElections,orgsWithSanctions,complianceRate,trendPercentage);

@override
String toString() {
  return 'OrganizationStats(totalOrganizations: $totalOrganizations, activeOrganizations: $activeOrganizations, inactiveOrganizations: $inactiveOrganizations, totalMembers: $totalMembers, activeOfficers: $activeOfficers, pendingApplications: $pendingApplications, orgsWithElections: $orgsWithElections, orgsWithSanctions: $orgsWithSanctions, complianceRate: $complianceRate, trendPercentage: $trendPercentage)';
}


}

/// @nodoc
abstract mixin class _$OrganizationStatsCopyWith<$Res> implements $OrganizationStatsCopyWith<$Res> {
  factory _$OrganizationStatsCopyWith(_OrganizationStats value, $Res Function(_OrganizationStats) _then) = __$OrganizationStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalOrganizations, int activeOrganizations, int inactiveOrganizations, int totalMembers, int activeOfficers, int pendingApplications, int orgsWithElections, int orgsWithSanctions, double complianceRate, double trendPercentage
});




}
/// @nodoc
class __$OrganizationStatsCopyWithImpl<$Res>
    implements _$OrganizationStatsCopyWith<$Res> {
  __$OrganizationStatsCopyWithImpl(this._self, this._then);

  final _OrganizationStats _self;
  final $Res Function(_OrganizationStats) _then;

/// Create a copy of OrganizationStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalOrganizations = null,Object? activeOrganizations = null,Object? inactiveOrganizations = null,Object? totalMembers = null,Object? activeOfficers = null,Object? pendingApplications = null,Object? orgsWithElections = null,Object? orgsWithSanctions = null,Object? complianceRate = null,Object? trendPercentage = null,}) {
  return _then(_OrganizationStats(
totalOrganizations: null == totalOrganizations ? _self.totalOrganizations : totalOrganizations // ignore: cast_nullable_to_non_nullable
as int,activeOrganizations: null == activeOrganizations ? _self.activeOrganizations : activeOrganizations // ignore: cast_nullable_to_non_nullable
as int,inactiveOrganizations: null == inactiveOrganizations ? _self.inactiveOrganizations : inactiveOrganizations // ignore: cast_nullable_to_non_nullable
as int,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeOfficers: null == activeOfficers ? _self.activeOfficers : activeOfficers // ignore: cast_nullable_to_non_nullable
as int,pendingApplications: null == pendingApplications ? _self.pendingApplications : pendingApplications // ignore: cast_nullable_to_non_nullable
as int,orgsWithElections: null == orgsWithElections ? _self.orgsWithElections : orgsWithElections // ignore: cast_nullable_to_non_nullable
as int,orgsWithSanctions: null == orgsWithSanctions ? _self.orgsWithSanctions : orgsWithSanctions // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,trendPercentage: null == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
