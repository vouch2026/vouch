// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campus_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CampusStats {

 int get totalCampuses; int get activeCampuses; int get totalFaculties; int get activeDeans; int get totalPrograms; int get activeProgramHeads; int get totalStudents; int get totalOrganizations; double get complianceRate; double get trendPercentage;
/// Create a copy of CampusStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampusStatsCopyWith<CampusStats> get copyWith => _$CampusStatsCopyWithImpl<CampusStats>(this as CampusStats, _$identity);

  /// Serializes this CampusStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CampusStats&&(identical(other.totalCampuses, totalCampuses) || other.totalCampuses == totalCampuses)&&(identical(other.activeCampuses, activeCampuses) || other.activeCampuses == activeCampuses)&&(identical(other.totalFaculties, totalFaculties) || other.totalFaculties == totalFaculties)&&(identical(other.activeDeans, activeDeans) || other.activeDeans == activeDeans)&&(identical(other.totalPrograms, totalPrograms) || other.totalPrograms == totalPrograms)&&(identical(other.activeProgramHeads, activeProgramHeads) || other.activeProgramHeads == activeProgramHeads)&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.totalOrganizations, totalOrganizations) || other.totalOrganizations == totalOrganizations)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCampuses,activeCampuses,totalFaculties,activeDeans,totalPrograms,activeProgramHeads,totalStudents,totalOrganizations,complianceRate,trendPercentage);

@override
String toString() {
  return 'CampusStats(totalCampuses: $totalCampuses, activeCampuses: $activeCampuses, totalFaculties: $totalFaculties, activeDeans: $activeDeans, totalPrograms: $totalPrograms, activeProgramHeads: $activeProgramHeads, totalStudents: $totalStudents, totalOrganizations: $totalOrganizations, complianceRate: $complianceRate, trendPercentage: $trendPercentage)';
}


}

/// @nodoc
abstract mixin class $CampusStatsCopyWith<$Res>  {
  factory $CampusStatsCopyWith(CampusStats value, $Res Function(CampusStats) _then) = _$CampusStatsCopyWithImpl;
@useResult
$Res call({
 int totalCampuses, int activeCampuses, int totalFaculties, int activeDeans, int totalPrograms, int activeProgramHeads, int totalStudents, int totalOrganizations, double complianceRate, double trendPercentage
});




}
/// @nodoc
class _$CampusStatsCopyWithImpl<$Res>
    implements $CampusStatsCopyWith<$Res> {
  _$CampusStatsCopyWithImpl(this._self, this._then);

  final CampusStats _self;
  final $Res Function(CampusStats) _then;

/// Create a copy of CampusStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalCampuses = null,Object? activeCampuses = null,Object? totalFaculties = null,Object? activeDeans = null,Object? totalPrograms = null,Object? activeProgramHeads = null,Object? totalStudents = null,Object? totalOrganizations = null,Object? complianceRate = null,Object? trendPercentage = null,}) {
  return _then(_self.copyWith(
totalCampuses: null == totalCampuses ? _self.totalCampuses : totalCampuses // ignore: cast_nullable_to_non_nullable
as int,activeCampuses: null == activeCampuses ? _self.activeCampuses : activeCampuses // ignore: cast_nullable_to_non_nullable
as int,totalFaculties: null == totalFaculties ? _self.totalFaculties : totalFaculties // ignore: cast_nullable_to_non_nullable
as int,activeDeans: null == activeDeans ? _self.activeDeans : activeDeans // ignore: cast_nullable_to_non_nullable
as int,totalPrograms: null == totalPrograms ? _self.totalPrograms : totalPrograms // ignore: cast_nullable_to_non_nullable
as int,activeProgramHeads: null == activeProgramHeads ? _self.activeProgramHeads : activeProgramHeads // ignore: cast_nullable_to_non_nullable
as int,totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,totalOrganizations: null == totalOrganizations ? _self.totalOrganizations : totalOrganizations // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,trendPercentage: null == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CampusStats].
extension CampusStatsPatterns on CampusStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CampusStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CampusStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CampusStats value)  $default,){
final _that = this;
switch (_that) {
case _CampusStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CampusStats value)?  $default,){
final _that = this;
switch (_that) {
case _CampusStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalCampuses,  int activeCampuses,  int totalFaculties,  int activeDeans,  int totalPrograms,  int activeProgramHeads,  int totalStudents,  int totalOrganizations,  double complianceRate,  double trendPercentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CampusStats() when $default != null:
return $default(_that.totalCampuses,_that.activeCampuses,_that.totalFaculties,_that.activeDeans,_that.totalPrograms,_that.activeProgramHeads,_that.totalStudents,_that.totalOrganizations,_that.complianceRate,_that.trendPercentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalCampuses,  int activeCampuses,  int totalFaculties,  int activeDeans,  int totalPrograms,  int activeProgramHeads,  int totalStudents,  int totalOrganizations,  double complianceRate,  double trendPercentage)  $default,) {final _that = this;
switch (_that) {
case _CampusStats():
return $default(_that.totalCampuses,_that.activeCampuses,_that.totalFaculties,_that.activeDeans,_that.totalPrograms,_that.activeProgramHeads,_that.totalStudents,_that.totalOrganizations,_that.complianceRate,_that.trendPercentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalCampuses,  int activeCampuses,  int totalFaculties,  int activeDeans,  int totalPrograms,  int activeProgramHeads,  int totalStudents,  int totalOrganizations,  double complianceRate,  double trendPercentage)?  $default,) {final _that = this;
switch (_that) {
case _CampusStats() when $default != null:
return $default(_that.totalCampuses,_that.activeCampuses,_that.totalFaculties,_that.activeDeans,_that.totalPrograms,_that.activeProgramHeads,_that.totalStudents,_that.totalOrganizations,_that.complianceRate,_that.trendPercentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CampusStats implements CampusStats {
  const _CampusStats({this.totalCampuses = 0, this.activeCampuses = 0, this.totalFaculties = 0, this.activeDeans = 0, this.totalPrograms = 0, this.activeProgramHeads = 0, this.totalStudents = 0, this.totalOrganizations = 0, this.complianceRate = 0.0, this.trendPercentage = 0.0});
  factory _CampusStats.fromJson(Map<String, dynamic> json) => _$CampusStatsFromJson(json);

@override@JsonKey() final  int totalCampuses;
@override@JsonKey() final  int activeCampuses;
@override@JsonKey() final  int totalFaculties;
@override@JsonKey() final  int activeDeans;
@override@JsonKey() final  int totalPrograms;
@override@JsonKey() final  int activeProgramHeads;
@override@JsonKey() final  int totalStudents;
@override@JsonKey() final  int totalOrganizations;
@override@JsonKey() final  double complianceRate;
@override@JsonKey() final  double trendPercentage;

/// Create a copy of CampusStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampusStatsCopyWith<_CampusStats> get copyWith => __$CampusStatsCopyWithImpl<_CampusStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampusStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CampusStats&&(identical(other.totalCampuses, totalCampuses) || other.totalCampuses == totalCampuses)&&(identical(other.activeCampuses, activeCampuses) || other.activeCampuses == activeCampuses)&&(identical(other.totalFaculties, totalFaculties) || other.totalFaculties == totalFaculties)&&(identical(other.activeDeans, activeDeans) || other.activeDeans == activeDeans)&&(identical(other.totalPrograms, totalPrograms) || other.totalPrograms == totalPrograms)&&(identical(other.activeProgramHeads, activeProgramHeads) || other.activeProgramHeads == activeProgramHeads)&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.totalOrganizations, totalOrganizations) || other.totalOrganizations == totalOrganizations)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.trendPercentage, trendPercentage) || other.trendPercentage == trendPercentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalCampuses,activeCampuses,totalFaculties,activeDeans,totalPrograms,activeProgramHeads,totalStudents,totalOrganizations,complianceRate,trendPercentage);

@override
String toString() {
  return 'CampusStats(totalCampuses: $totalCampuses, activeCampuses: $activeCampuses, totalFaculties: $totalFaculties, activeDeans: $activeDeans, totalPrograms: $totalPrograms, activeProgramHeads: $activeProgramHeads, totalStudents: $totalStudents, totalOrganizations: $totalOrganizations, complianceRate: $complianceRate, trendPercentage: $trendPercentage)';
}


}

/// @nodoc
abstract mixin class _$CampusStatsCopyWith<$Res> implements $CampusStatsCopyWith<$Res> {
  factory _$CampusStatsCopyWith(_CampusStats value, $Res Function(_CampusStats) _then) = __$CampusStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalCampuses, int activeCampuses, int totalFaculties, int activeDeans, int totalPrograms, int activeProgramHeads, int totalStudents, int totalOrganizations, double complianceRate, double trendPercentage
});




}
/// @nodoc
class __$CampusStatsCopyWithImpl<$Res>
    implements _$CampusStatsCopyWith<$Res> {
  __$CampusStatsCopyWithImpl(this._self, this._then);

  final _CampusStats _self;
  final $Res Function(_CampusStats) _then;

/// Create a copy of CampusStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalCampuses = null,Object? activeCampuses = null,Object? totalFaculties = null,Object? activeDeans = null,Object? totalPrograms = null,Object? activeProgramHeads = null,Object? totalStudents = null,Object? totalOrganizations = null,Object? complianceRate = null,Object? trendPercentage = null,}) {
  return _then(_CampusStats(
totalCampuses: null == totalCampuses ? _self.totalCampuses : totalCampuses // ignore: cast_nullable_to_non_nullable
as int,activeCampuses: null == activeCampuses ? _self.activeCampuses : activeCampuses // ignore: cast_nullable_to_non_nullable
as int,totalFaculties: null == totalFaculties ? _self.totalFaculties : totalFaculties // ignore: cast_nullable_to_non_nullable
as int,activeDeans: null == activeDeans ? _self.activeDeans : activeDeans // ignore: cast_nullable_to_non_nullable
as int,totalPrograms: null == totalPrograms ? _self.totalPrograms : totalPrograms // ignore: cast_nullable_to_non_nullable
as int,activeProgramHeads: null == activeProgramHeads ? _self.activeProgramHeads : activeProgramHeads // ignore: cast_nullable_to_non_nullable
as int,totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,totalOrganizations: null == totalOrganizations ? _self.totalOrganizations : totalOrganizations // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,trendPercentage: null == trendPercentage ? _self.trendPercentage : trendPercentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
