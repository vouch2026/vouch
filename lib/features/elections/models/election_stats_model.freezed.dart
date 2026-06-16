// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'election_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ElectionStatsModel {

 int get activeElections; int get upcomingElections; int get completedElections; int get registeredVoters; int get totalVotesCast; double get voterTurnoutRate; int get totalCandidates; int get approvedCandidates; int get pendingCandidates; int get activeComselecOfficials; int get electionViolations; double get complianceRate; double get turnoutTrend;
/// Create a copy of ElectionStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElectionStatsModelCopyWith<ElectionStatsModel> get copyWith => _$ElectionStatsModelCopyWithImpl<ElectionStatsModel>(this as ElectionStatsModel, _$identity);

  /// Serializes this ElectionStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ElectionStatsModel&&(identical(other.activeElections, activeElections) || other.activeElections == activeElections)&&(identical(other.upcomingElections, upcomingElections) || other.upcomingElections == upcomingElections)&&(identical(other.completedElections, completedElections) || other.completedElections == completedElections)&&(identical(other.registeredVoters, registeredVoters) || other.registeredVoters == registeredVoters)&&(identical(other.totalVotesCast, totalVotesCast) || other.totalVotesCast == totalVotesCast)&&(identical(other.voterTurnoutRate, voterTurnoutRate) || other.voterTurnoutRate == voterTurnoutRate)&&(identical(other.totalCandidates, totalCandidates) || other.totalCandidates == totalCandidates)&&(identical(other.approvedCandidates, approvedCandidates) || other.approvedCandidates == approvedCandidates)&&(identical(other.pendingCandidates, pendingCandidates) || other.pendingCandidates == pendingCandidates)&&(identical(other.activeComselecOfficials, activeComselecOfficials) || other.activeComselecOfficials == activeComselecOfficials)&&(identical(other.electionViolations, electionViolations) || other.electionViolations == electionViolations)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.turnoutTrend, turnoutTrend) || other.turnoutTrend == turnoutTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeElections,upcomingElections,completedElections,registeredVoters,totalVotesCast,voterTurnoutRate,totalCandidates,approvedCandidates,pendingCandidates,activeComselecOfficials,electionViolations,complianceRate,turnoutTrend);

@override
String toString() {
  return 'ElectionStatsModel(activeElections: $activeElections, upcomingElections: $upcomingElections, completedElections: $completedElections, registeredVoters: $registeredVoters, totalVotesCast: $totalVotesCast, voterTurnoutRate: $voterTurnoutRate, totalCandidates: $totalCandidates, approvedCandidates: $approvedCandidates, pendingCandidates: $pendingCandidates, activeComselecOfficials: $activeComselecOfficials, electionViolations: $electionViolations, complianceRate: $complianceRate, turnoutTrend: $turnoutTrend)';
}


}

/// @nodoc
abstract mixin class $ElectionStatsModelCopyWith<$Res>  {
  factory $ElectionStatsModelCopyWith(ElectionStatsModel value, $Res Function(ElectionStatsModel) _then) = _$ElectionStatsModelCopyWithImpl;
@useResult
$Res call({
 int activeElections, int upcomingElections, int completedElections, int registeredVoters, int totalVotesCast, double voterTurnoutRate, int totalCandidates, int approvedCandidates, int pendingCandidates, int activeComselecOfficials, int electionViolations, double complianceRate, double turnoutTrend
});




}
/// @nodoc
class _$ElectionStatsModelCopyWithImpl<$Res>
    implements $ElectionStatsModelCopyWith<$Res> {
  _$ElectionStatsModelCopyWithImpl(this._self, this._then);

  final ElectionStatsModel _self;
  final $Res Function(ElectionStatsModel) _then;

/// Create a copy of ElectionStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeElections = null,Object? upcomingElections = null,Object? completedElections = null,Object? registeredVoters = null,Object? totalVotesCast = null,Object? voterTurnoutRate = null,Object? totalCandidates = null,Object? approvedCandidates = null,Object? pendingCandidates = null,Object? activeComselecOfficials = null,Object? electionViolations = null,Object? complianceRate = null,Object? turnoutTrend = null,}) {
  return _then(_self.copyWith(
activeElections: null == activeElections ? _self.activeElections : activeElections // ignore: cast_nullable_to_non_nullable
as int,upcomingElections: null == upcomingElections ? _self.upcomingElections : upcomingElections // ignore: cast_nullable_to_non_nullable
as int,completedElections: null == completedElections ? _self.completedElections : completedElections // ignore: cast_nullable_to_non_nullable
as int,registeredVoters: null == registeredVoters ? _self.registeredVoters : registeredVoters // ignore: cast_nullable_to_non_nullable
as int,totalVotesCast: null == totalVotesCast ? _self.totalVotesCast : totalVotesCast // ignore: cast_nullable_to_non_nullable
as int,voterTurnoutRate: null == voterTurnoutRate ? _self.voterTurnoutRate : voterTurnoutRate // ignore: cast_nullable_to_non_nullable
as double,totalCandidates: null == totalCandidates ? _self.totalCandidates : totalCandidates // ignore: cast_nullable_to_non_nullable
as int,approvedCandidates: null == approvedCandidates ? _self.approvedCandidates : approvedCandidates // ignore: cast_nullable_to_non_nullable
as int,pendingCandidates: null == pendingCandidates ? _self.pendingCandidates : pendingCandidates // ignore: cast_nullable_to_non_nullable
as int,activeComselecOfficials: null == activeComselecOfficials ? _self.activeComselecOfficials : activeComselecOfficials // ignore: cast_nullable_to_non_nullable
as int,electionViolations: null == electionViolations ? _self.electionViolations : electionViolations // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,turnoutTrend: null == turnoutTrend ? _self.turnoutTrend : turnoutTrend // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ElectionStatsModel].
extension ElectionStatsModelPatterns on ElectionStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ElectionStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ElectionStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ElectionStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _ElectionStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ElectionStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _ElectionStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activeElections,  int upcomingElections,  int completedElections,  int registeredVoters,  int totalVotesCast,  double voterTurnoutRate,  int totalCandidates,  int approvedCandidates,  int pendingCandidates,  int activeComselecOfficials,  int electionViolations,  double complianceRate,  double turnoutTrend)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ElectionStatsModel() when $default != null:
return $default(_that.activeElections,_that.upcomingElections,_that.completedElections,_that.registeredVoters,_that.totalVotesCast,_that.voterTurnoutRate,_that.totalCandidates,_that.approvedCandidates,_that.pendingCandidates,_that.activeComselecOfficials,_that.electionViolations,_that.complianceRate,_that.turnoutTrend);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activeElections,  int upcomingElections,  int completedElections,  int registeredVoters,  int totalVotesCast,  double voterTurnoutRate,  int totalCandidates,  int approvedCandidates,  int pendingCandidates,  int activeComselecOfficials,  int electionViolations,  double complianceRate,  double turnoutTrend)  $default,) {final _that = this;
switch (_that) {
case _ElectionStatsModel():
return $default(_that.activeElections,_that.upcomingElections,_that.completedElections,_that.registeredVoters,_that.totalVotesCast,_that.voterTurnoutRate,_that.totalCandidates,_that.approvedCandidates,_that.pendingCandidates,_that.activeComselecOfficials,_that.electionViolations,_that.complianceRate,_that.turnoutTrend);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activeElections,  int upcomingElections,  int completedElections,  int registeredVoters,  int totalVotesCast,  double voterTurnoutRate,  int totalCandidates,  int approvedCandidates,  int pendingCandidates,  int activeComselecOfficials,  int electionViolations,  double complianceRate,  double turnoutTrend)?  $default,) {final _that = this;
switch (_that) {
case _ElectionStatsModel() when $default != null:
return $default(_that.activeElections,_that.upcomingElections,_that.completedElections,_that.registeredVoters,_that.totalVotesCast,_that.voterTurnoutRate,_that.totalCandidates,_that.approvedCandidates,_that.pendingCandidates,_that.activeComselecOfficials,_that.electionViolations,_that.complianceRate,_that.turnoutTrend);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ElectionStatsModel implements ElectionStatsModel {
  const _ElectionStatsModel({this.activeElections = 0, this.upcomingElections = 0, this.completedElections = 0, this.registeredVoters = 0, this.totalVotesCast = 0, this.voterTurnoutRate = 0.0, this.totalCandidates = 0, this.approvedCandidates = 0, this.pendingCandidates = 0, this.activeComselecOfficials = 0, this.electionViolations = 0, this.complianceRate = 0.0, this.turnoutTrend = 0.0});
  factory _ElectionStatsModel.fromJson(Map<String, dynamic> json) => _$ElectionStatsModelFromJson(json);

@override@JsonKey() final  int activeElections;
@override@JsonKey() final  int upcomingElections;
@override@JsonKey() final  int completedElections;
@override@JsonKey() final  int registeredVoters;
@override@JsonKey() final  int totalVotesCast;
@override@JsonKey() final  double voterTurnoutRate;
@override@JsonKey() final  int totalCandidates;
@override@JsonKey() final  int approvedCandidates;
@override@JsonKey() final  int pendingCandidates;
@override@JsonKey() final  int activeComselecOfficials;
@override@JsonKey() final  int electionViolations;
@override@JsonKey() final  double complianceRate;
@override@JsonKey() final  double turnoutTrend;

/// Create a copy of ElectionStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElectionStatsModelCopyWith<_ElectionStatsModel> get copyWith => __$ElectionStatsModelCopyWithImpl<_ElectionStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ElectionStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ElectionStatsModel&&(identical(other.activeElections, activeElections) || other.activeElections == activeElections)&&(identical(other.upcomingElections, upcomingElections) || other.upcomingElections == upcomingElections)&&(identical(other.completedElections, completedElections) || other.completedElections == completedElections)&&(identical(other.registeredVoters, registeredVoters) || other.registeredVoters == registeredVoters)&&(identical(other.totalVotesCast, totalVotesCast) || other.totalVotesCast == totalVotesCast)&&(identical(other.voterTurnoutRate, voterTurnoutRate) || other.voterTurnoutRate == voterTurnoutRate)&&(identical(other.totalCandidates, totalCandidates) || other.totalCandidates == totalCandidates)&&(identical(other.approvedCandidates, approvedCandidates) || other.approvedCandidates == approvedCandidates)&&(identical(other.pendingCandidates, pendingCandidates) || other.pendingCandidates == pendingCandidates)&&(identical(other.activeComselecOfficials, activeComselecOfficials) || other.activeComselecOfficials == activeComselecOfficials)&&(identical(other.electionViolations, electionViolations) || other.electionViolations == electionViolations)&&(identical(other.complianceRate, complianceRate) || other.complianceRate == complianceRate)&&(identical(other.turnoutTrend, turnoutTrend) || other.turnoutTrend == turnoutTrend));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeElections,upcomingElections,completedElections,registeredVoters,totalVotesCast,voterTurnoutRate,totalCandidates,approvedCandidates,pendingCandidates,activeComselecOfficials,electionViolations,complianceRate,turnoutTrend);

@override
String toString() {
  return 'ElectionStatsModel(activeElections: $activeElections, upcomingElections: $upcomingElections, completedElections: $completedElections, registeredVoters: $registeredVoters, totalVotesCast: $totalVotesCast, voterTurnoutRate: $voterTurnoutRate, totalCandidates: $totalCandidates, approvedCandidates: $approvedCandidates, pendingCandidates: $pendingCandidates, activeComselecOfficials: $activeComselecOfficials, electionViolations: $electionViolations, complianceRate: $complianceRate, turnoutTrend: $turnoutTrend)';
}


}

/// @nodoc
abstract mixin class _$ElectionStatsModelCopyWith<$Res> implements $ElectionStatsModelCopyWith<$Res> {
  factory _$ElectionStatsModelCopyWith(_ElectionStatsModel value, $Res Function(_ElectionStatsModel) _then) = __$ElectionStatsModelCopyWithImpl;
@override @useResult
$Res call({
 int activeElections, int upcomingElections, int completedElections, int registeredVoters, int totalVotesCast, double voterTurnoutRate, int totalCandidates, int approvedCandidates, int pendingCandidates, int activeComselecOfficials, int electionViolations, double complianceRate, double turnoutTrend
});




}
/// @nodoc
class __$ElectionStatsModelCopyWithImpl<$Res>
    implements _$ElectionStatsModelCopyWith<$Res> {
  __$ElectionStatsModelCopyWithImpl(this._self, this._then);

  final _ElectionStatsModel _self;
  final $Res Function(_ElectionStatsModel) _then;

/// Create a copy of ElectionStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeElections = null,Object? upcomingElections = null,Object? completedElections = null,Object? registeredVoters = null,Object? totalVotesCast = null,Object? voterTurnoutRate = null,Object? totalCandidates = null,Object? approvedCandidates = null,Object? pendingCandidates = null,Object? activeComselecOfficials = null,Object? electionViolations = null,Object? complianceRate = null,Object? turnoutTrend = null,}) {
  return _then(_ElectionStatsModel(
activeElections: null == activeElections ? _self.activeElections : activeElections // ignore: cast_nullable_to_non_nullable
as int,upcomingElections: null == upcomingElections ? _self.upcomingElections : upcomingElections // ignore: cast_nullable_to_non_nullable
as int,completedElections: null == completedElections ? _self.completedElections : completedElections // ignore: cast_nullable_to_non_nullable
as int,registeredVoters: null == registeredVoters ? _self.registeredVoters : registeredVoters // ignore: cast_nullable_to_non_nullable
as int,totalVotesCast: null == totalVotesCast ? _self.totalVotesCast : totalVotesCast // ignore: cast_nullable_to_non_nullable
as int,voterTurnoutRate: null == voterTurnoutRate ? _self.voterTurnoutRate : voterTurnoutRate // ignore: cast_nullable_to_non_nullable
as double,totalCandidates: null == totalCandidates ? _self.totalCandidates : totalCandidates // ignore: cast_nullable_to_non_nullable
as int,approvedCandidates: null == approvedCandidates ? _self.approvedCandidates : approvedCandidates // ignore: cast_nullable_to_non_nullable
as int,pendingCandidates: null == pendingCandidates ? _self.pendingCandidates : pendingCandidates // ignore: cast_nullable_to_non_nullable
as int,activeComselecOfficials: null == activeComselecOfficials ? _self.activeComselecOfficials : activeComselecOfficials // ignore: cast_nullable_to_non_nullable
as int,electionViolations: null == electionViolations ? _self.electionViolations : electionViolations // ignore: cast_nullable_to_non_nullable
as int,complianceRate: null == complianceRate ? _self.complianceRate : complianceRate // ignore: cast_nullable_to_non_nullable
as double,turnoutTrend: null == turnoutTrend ? _self.turnoutTrend : turnoutTrend // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
