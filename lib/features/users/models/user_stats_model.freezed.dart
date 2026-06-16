// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserStatsModel {

 int get totalUsers; int get totalStudents; int get activeStudents; int get pendingStudents; int get suspendedStudents; int get totalInstructors; int get activeInstructors; int get deansCount; int get programHeadsCount; int get totalOfficers; int get orgMembershipsCount; int get activeGovernanceAccounts; double get studentTrend; double get instructorTrend; double get governanceTrend;
/// Create a copy of UserStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStatsModelCopyWith<UserStatsModel> get copyWith => _$UserStatsModelCopyWithImpl<UserStatsModel>(this as UserStatsModel, _$identity);

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStatsModel&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.suspendedStudents, suspendedStudents) || other.suspendedStudents == suspendedStudents)&&(identical(other.totalInstructors, totalInstructors) || other.totalInstructors == totalInstructors)&&(identical(other.activeInstructors, activeInstructors) || other.activeInstructors == activeInstructors)&&(identical(other.deansCount, deansCount) || other.deansCount == deansCount)&&(identical(other.programHeadsCount, programHeadsCount) || other.programHeadsCount == programHeadsCount)&&(identical(other.totalOfficers, totalOfficers) || other.totalOfficers == totalOfficers)&&(identical(other.orgMembershipsCount, orgMembershipsCount) || other.orgMembershipsCount == orgMembershipsCount)&&(identical(other.activeGovernanceAccounts, activeGovernanceAccounts) || other.activeGovernanceAccounts == activeGovernanceAccounts)&&(identical(other.studentTrend, studentTrend) || other.studentTrend == studentTrend)&&(identical(other.instructorTrend, instructorTrend) || other.instructorTrend == instructorTrend)&&(identical(other.governanceTrend, governanceTrend) || other.governanceTrend == governanceTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,totalStudents,activeStudents,pendingStudents,suspendedStudents,totalInstructors,activeInstructors,deansCount,programHeadsCount,totalOfficers,orgMembershipsCount,activeGovernanceAccounts,studentTrend,instructorTrend,governanceTrend);

@override
String toString() {
  return 'UserStatsModel(totalUsers: $totalUsers, totalStudents: $totalStudents, activeStudents: $activeStudents, pendingStudents: $pendingStudents, suspendedStudents: $suspendedStudents, totalInstructors: $totalInstructors, activeInstructors: $activeInstructors, deansCount: $deansCount, programHeadsCount: $programHeadsCount, totalOfficers: $totalOfficers, orgMembershipsCount: $orgMembershipsCount, activeGovernanceAccounts: $activeGovernanceAccounts, studentTrend: $studentTrend, instructorTrend: $instructorTrend, governanceTrend: $governanceTrend)';
}


}

/// @nodoc
abstract mixin class $UserStatsModelCopyWith<$Res>  {
  factory $UserStatsModelCopyWith(UserStatsModel value, $Res Function(UserStatsModel) _then) = _$UserStatsModelCopyWithImpl;
@useResult
$Res call({
 int totalUsers, int totalStudents, int activeStudents, int pendingStudents, int suspendedStudents, int totalInstructors, int activeInstructors, int deansCount, int programHeadsCount, int totalOfficers, int orgMembershipsCount, int activeGovernanceAccounts, double studentTrend, double instructorTrend, double governanceTrend
});




}
/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._self, this._then);

  final UserStatsModel _self;
  final $Res Function(UserStatsModel) _then;

/// Create a copy of UserStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUsers = null,Object? totalStudents = null,Object? activeStudents = null,Object? pendingStudents = null,Object? suspendedStudents = null,Object? totalInstructors = null,Object? activeInstructors = null,Object? deansCount = null,Object? programHeadsCount = null,Object? totalOfficers = null,Object? orgMembershipsCount = null,Object? activeGovernanceAccounts = null,Object? studentTrend = null,Object? instructorTrend = null,Object? governanceTrend = null,}) {
  return _then(_self.copyWith(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,suspendedStudents: null == suspendedStudents ? _self.suspendedStudents : suspendedStudents // ignore: cast_nullable_to_non_nullable
as int,totalInstructors: null == totalInstructors ? _self.totalInstructors : totalInstructors // ignore: cast_nullable_to_non_nullable
as int,activeInstructors: null == activeInstructors ? _self.activeInstructors : activeInstructors // ignore: cast_nullable_to_non_nullable
as int,deansCount: null == deansCount ? _self.deansCount : deansCount // ignore: cast_nullable_to_non_nullable
as int,programHeadsCount: null == programHeadsCount ? _self.programHeadsCount : programHeadsCount // ignore: cast_nullable_to_non_nullable
as int,totalOfficers: null == totalOfficers ? _self.totalOfficers : totalOfficers // ignore: cast_nullable_to_non_nullable
as int,orgMembershipsCount: null == orgMembershipsCount ? _self.orgMembershipsCount : orgMembershipsCount // ignore: cast_nullable_to_non_nullable
as int,activeGovernanceAccounts: null == activeGovernanceAccounts ? _self.activeGovernanceAccounts : activeGovernanceAccounts // ignore: cast_nullable_to_non_nullable
as int,studentTrend: null == studentTrend ? _self.studentTrend : studentTrend // ignore: cast_nullable_to_non_nullable
as double,instructorTrend: null == instructorTrend ? _self.instructorTrend : instructorTrend // ignore: cast_nullable_to_non_nullable
as double,governanceTrend: null == governanceTrend ? _self.governanceTrend : governanceTrend // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStatsModel].
extension UserStatsModelPatterns on UserStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _UserStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalUsers,  int totalStudents,  int activeStudents,  int pendingStudents,  int suspendedStudents,  int totalInstructors,  int activeInstructors,  int deansCount,  int programHeadsCount,  int totalOfficers,  int orgMembershipsCount,  int activeGovernanceAccounts,  double studentTrend,  double instructorTrend,  double governanceTrend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStatsModel() when $default != null:
return $default(_that.totalUsers,_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.suspendedStudents,_that.totalInstructors,_that.activeInstructors,_that.deansCount,_that.programHeadsCount,_that.totalOfficers,_that.orgMembershipsCount,_that.activeGovernanceAccounts,_that.studentTrend,_that.instructorTrend,_that.governanceTrend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalUsers,  int totalStudents,  int activeStudents,  int pendingStudents,  int suspendedStudents,  int totalInstructors,  int activeInstructors,  int deansCount,  int programHeadsCount,  int totalOfficers,  int orgMembershipsCount,  int activeGovernanceAccounts,  double studentTrend,  double instructorTrend,  double governanceTrend)  $default,) {final _that = this;
switch (_that) {
case _UserStatsModel():
return $default(_that.totalUsers,_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.suspendedStudents,_that.totalInstructors,_that.activeInstructors,_that.deansCount,_that.programHeadsCount,_that.totalOfficers,_that.orgMembershipsCount,_that.activeGovernanceAccounts,_that.studentTrend,_that.instructorTrend,_that.governanceTrend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalUsers,  int totalStudents,  int activeStudents,  int pendingStudents,  int suspendedStudents,  int totalInstructors,  int activeInstructors,  int deansCount,  int programHeadsCount,  int totalOfficers,  int orgMembershipsCount,  int activeGovernanceAccounts,  double studentTrend,  double instructorTrend,  double governanceTrend)?  $default,) {final _that = this;
switch (_that) {
case _UserStatsModel() when $default != null:
return $default(_that.totalUsers,_that.totalStudents,_that.activeStudents,_that.pendingStudents,_that.suspendedStudents,_that.totalInstructors,_that.activeInstructors,_that.deansCount,_that.programHeadsCount,_that.totalOfficers,_that.orgMembershipsCount,_that.activeGovernanceAccounts,_that.studentTrend,_that.instructorTrend,_that.governanceTrend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserStatsModel extends UserStatsModel {
  const _UserStatsModel({this.totalUsers = 0, this.totalStudents = 0, this.activeStudents = 0, this.pendingStudents = 0, this.suspendedStudents = 0, this.totalInstructors = 0, this.activeInstructors = 0, this.deansCount = 0, this.programHeadsCount = 0, this.totalOfficers = 0, this.orgMembershipsCount = 0, this.activeGovernanceAccounts = 0, this.studentTrend = 0.0, this.instructorTrend = 0.0, this.governanceTrend = 0.0}): super._();
  factory _UserStatsModel.fromJson(Map<String, dynamic> json) => _$UserStatsModelFromJson(json);

@override@JsonKey() final  int totalUsers;
@override@JsonKey() final  int totalStudents;
@override@JsonKey() final  int activeStudents;
@override@JsonKey() final  int pendingStudents;
@override@JsonKey() final  int suspendedStudents;
@override@JsonKey() final  int totalInstructors;
@override@JsonKey() final  int activeInstructors;
@override@JsonKey() final  int deansCount;
@override@JsonKey() final  int programHeadsCount;
@override@JsonKey() final  int totalOfficers;
@override@JsonKey() final  int orgMembershipsCount;
@override@JsonKey() final  int activeGovernanceAccounts;
@override@JsonKey() final  double studentTrend;
@override@JsonKey() final  double instructorTrend;
@override@JsonKey() final  double governanceTrend;

/// Create a copy of UserStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStatsModelCopyWith<_UserStatsModel> get copyWith => __$UserStatsModelCopyWithImpl<_UserStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStatsModel&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalStudents, totalStudents) || other.totalStudents == totalStudents)&&(identical(other.activeStudents, activeStudents) || other.activeStudents == activeStudents)&&(identical(other.pendingStudents, pendingStudents) || other.pendingStudents == pendingStudents)&&(identical(other.suspendedStudents, suspendedStudents) || other.suspendedStudents == suspendedStudents)&&(identical(other.totalInstructors, totalInstructors) || other.totalInstructors == totalInstructors)&&(identical(other.activeInstructors, activeInstructors) || other.activeInstructors == activeInstructors)&&(identical(other.deansCount, deansCount) || other.deansCount == deansCount)&&(identical(other.programHeadsCount, programHeadsCount) || other.programHeadsCount == programHeadsCount)&&(identical(other.totalOfficers, totalOfficers) || other.totalOfficers == totalOfficers)&&(identical(other.orgMembershipsCount, orgMembershipsCount) || other.orgMembershipsCount == orgMembershipsCount)&&(identical(other.activeGovernanceAccounts, activeGovernanceAccounts) || other.activeGovernanceAccounts == activeGovernanceAccounts)&&(identical(other.studentTrend, studentTrend) || other.studentTrend == studentTrend)&&(identical(other.instructorTrend, instructorTrend) || other.instructorTrend == instructorTrend)&&(identical(other.governanceTrend, governanceTrend) || other.governanceTrend == governanceTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUsers,totalStudents,activeStudents,pendingStudents,suspendedStudents,totalInstructors,activeInstructors,deansCount,programHeadsCount,totalOfficers,orgMembershipsCount,activeGovernanceAccounts,studentTrend,instructorTrend,governanceTrend);

@override
String toString() {
  return 'UserStatsModel(totalUsers: $totalUsers, totalStudents: $totalStudents, activeStudents: $activeStudents, pendingStudents: $pendingStudents, suspendedStudents: $suspendedStudents, totalInstructors: $totalInstructors, activeInstructors: $activeInstructors, deansCount: $deansCount, programHeadsCount: $programHeadsCount, totalOfficers: $totalOfficers, orgMembershipsCount: $orgMembershipsCount, activeGovernanceAccounts: $activeGovernanceAccounts, studentTrend: $studentTrend, instructorTrend: $instructorTrend, governanceTrend: $governanceTrend)';
}


}

/// @nodoc
abstract mixin class _$UserStatsModelCopyWith<$Res> implements $UserStatsModelCopyWith<$Res> {
  factory _$UserStatsModelCopyWith(_UserStatsModel value, $Res Function(_UserStatsModel) _then) = __$UserStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int totalUsers, int totalStudents, int activeStudents, int pendingStudents, int suspendedStudents, int totalInstructors, int activeInstructors, int deansCount, int programHeadsCount, int totalOfficers, int orgMembershipsCount, int activeGovernanceAccounts, double studentTrend, double instructorTrend, double governanceTrend
});




}
/// @nodoc
class __$UserStatsModelCopyWithImpl<$Res>
    implements _$UserStatsModelCopyWith<$Res> {
  __$UserStatsModelCopyWithImpl(this._self, this._then);

  final _UserStatsModel _self;
  final $Res Function(_UserStatsModel) _then;

/// Create a copy of UserStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUsers = null,Object? totalStudents = null,Object? activeStudents = null,Object? pendingStudents = null,Object? suspendedStudents = null,Object? totalInstructors = null,Object? activeInstructors = null,Object? deansCount = null,Object? programHeadsCount = null,Object? totalOfficers = null,Object? orgMembershipsCount = null,Object? activeGovernanceAccounts = null,Object? studentTrend = null,Object? instructorTrend = null,Object? governanceTrend = null,}) {
  return _then(_UserStatsModel(
totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalStudents: null == totalStudents ? _self.totalStudents : totalStudents // ignore: cast_nullable_to_non_nullable
as int,activeStudents: null == activeStudents ? _self.activeStudents : activeStudents // ignore: cast_nullable_to_non_nullable
as int,pendingStudents: null == pendingStudents ? _self.pendingStudents : pendingStudents // ignore: cast_nullable_to_non_nullable
as int,suspendedStudents: null == suspendedStudents ? _self.suspendedStudents : suspendedStudents // ignore: cast_nullable_to_non_nullable
as int,totalInstructors: null == totalInstructors ? _self.totalInstructors : totalInstructors // ignore: cast_nullable_to_non_nullable
as int,activeInstructors: null == activeInstructors ? _self.activeInstructors : activeInstructors // ignore: cast_nullable_to_non_nullable
as int,deansCount: null == deansCount ? _self.deansCount : deansCount // ignore: cast_nullable_to_non_nullable
as int,programHeadsCount: null == programHeadsCount ? _self.programHeadsCount : programHeadsCount // ignore: cast_nullable_to_non_nullable
as int,totalOfficers: null == totalOfficers ? _self.totalOfficers : totalOfficers // ignore: cast_nullable_to_non_nullable
as int,orgMembershipsCount: null == orgMembershipsCount ? _self.orgMembershipsCount : orgMembershipsCount // ignore: cast_nullable_to_non_nullable
as int,activeGovernanceAccounts: null == activeGovernanceAccounts ? _self.activeGovernanceAccounts : activeGovernanceAccounts // ignore: cast_nullable_to_non_nullable
as int,studentTrend: null == studentTrend ? _self.studentTrend : studentTrend // ignore: cast_nullable_to_non_nullable
as double,instructorTrend: null == instructorTrend ? _self.instructorTrend : instructorTrend // ignore: cast_nullable_to_non_nullable
as double,governanceTrend: null == governanceTrend ? _self.governanceTrend : governanceTrend // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
