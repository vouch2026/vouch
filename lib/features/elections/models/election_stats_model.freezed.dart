// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'election_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ElectionStatsModel _$ElectionStatsModelFromJson(Map<String, dynamic> json) {
  return _ElectionStatsModel.fromJson(json);
}

/// @nodoc
mixin _$ElectionStatsModel {
  int get activeElections => throw _privateConstructorUsedError;
  int get upcomingElections => throw _privateConstructorUsedError;
  int get completedElections => throw _privateConstructorUsedError;
  int get registeredVoters => throw _privateConstructorUsedError;
  int get totalVotesCast => throw _privateConstructorUsedError;
  double get voterTurnoutRate => throw _privateConstructorUsedError;
  int get totalCandidates => throw _privateConstructorUsedError;
  int get approvedCandidates => throw _privateConstructorUsedError;
  int get pendingCandidates => throw _privateConstructorUsedError;
  int get activeComselecOfficials => throw _privateConstructorUsedError;
  int get electionViolations => throw _privateConstructorUsedError;
  double get complianceRate => throw _privateConstructorUsedError;
  double get turnoutTrend => throw _privateConstructorUsedError;

  /// Serializes this ElectionStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ElectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElectionStatsModelCopyWith<ElectionStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElectionStatsModelCopyWith<$Res> {
  factory $ElectionStatsModelCopyWith(
    ElectionStatsModel value,
    $Res Function(ElectionStatsModel) then,
  ) = _$ElectionStatsModelCopyWithImpl<$Res, ElectionStatsModel>;
  @useResult
  $Res call({
    int activeElections,
    int upcomingElections,
    int completedElections,
    int registeredVoters,
    int totalVotesCast,
    double voterTurnoutRate,
    int totalCandidates,
    int approvedCandidates,
    int pendingCandidates,
    int activeComselecOfficials,
    int electionViolations,
    double complianceRate,
    double turnoutTrend,
  });
}

/// @nodoc
class _$ElectionStatsModelCopyWithImpl<$Res, $Val extends ElectionStatsModel>
    implements $ElectionStatsModelCopyWith<$Res> {
  _$ElectionStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ElectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeElections = null,
    Object? upcomingElections = null,
    Object? completedElections = null,
    Object? registeredVoters = null,
    Object? totalVotesCast = null,
    Object? voterTurnoutRate = null,
    Object? totalCandidates = null,
    Object? approvedCandidates = null,
    Object? pendingCandidates = null,
    Object? activeComselecOfficials = null,
    Object? electionViolations = null,
    Object? complianceRate = null,
    Object? turnoutTrend = null,
  }) {
    return _then(
      _value.copyWith(
            activeElections: null == activeElections
                ? _value.activeElections
                : activeElections // ignore: cast_nullable_to_non_nullable
                      as int,
            upcomingElections: null == upcomingElections
                ? _value.upcomingElections
                : upcomingElections // ignore: cast_nullable_to_non_nullable
                      as int,
            completedElections: null == completedElections
                ? _value.completedElections
                : completedElections // ignore: cast_nullable_to_non_nullable
                      as int,
            registeredVoters: null == registeredVoters
                ? _value.registeredVoters
                : registeredVoters // ignore: cast_nullable_to_non_nullable
                      as int,
            totalVotesCast: null == totalVotesCast
                ? _value.totalVotesCast
                : totalVotesCast // ignore: cast_nullable_to_non_nullable
                      as int,
            voterTurnoutRate: null == voterTurnoutRate
                ? _value.voterTurnoutRate
                : voterTurnoutRate // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCandidates: null == totalCandidates
                ? _value.totalCandidates
                : totalCandidates // ignore: cast_nullable_to_non_nullable
                      as int,
            approvedCandidates: null == approvedCandidates
                ? _value.approvedCandidates
                : approvedCandidates // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingCandidates: null == pendingCandidates
                ? _value.pendingCandidates
                : pendingCandidates // ignore: cast_nullable_to_non_nullable
                      as int,
            activeComselecOfficials: null == activeComselecOfficials
                ? _value.activeComselecOfficials
                : activeComselecOfficials // ignore: cast_nullable_to_non_nullable
                      as int,
            electionViolations: null == electionViolations
                ? _value.electionViolations
                : electionViolations // ignore: cast_nullable_to_non_nullable
                      as int,
            complianceRate: null == complianceRate
                ? _value.complianceRate
                : complianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            turnoutTrend: null == turnoutTrend
                ? _value.turnoutTrend
                : turnoutTrend // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ElectionStatsModelImplCopyWith<$Res>
    implements $ElectionStatsModelCopyWith<$Res> {
  factory _$$ElectionStatsModelImplCopyWith(
    _$ElectionStatsModelImpl value,
    $Res Function(_$ElectionStatsModelImpl) then,
  ) = __$$ElectionStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int activeElections,
    int upcomingElections,
    int completedElections,
    int registeredVoters,
    int totalVotesCast,
    double voterTurnoutRate,
    int totalCandidates,
    int approvedCandidates,
    int pendingCandidates,
    int activeComselecOfficials,
    int electionViolations,
    double complianceRate,
    double turnoutTrend,
  });
}

/// @nodoc
class __$$ElectionStatsModelImplCopyWithImpl<$Res>
    extends _$ElectionStatsModelCopyWithImpl<$Res, _$ElectionStatsModelImpl>
    implements _$$ElectionStatsModelImplCopyWith<$Res> {
  __$$ElectionStatsModelImplCopyWithImpl(
    _$ElectionStatsModelImpl _value,
    $Res Function(_$ElectionStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ElectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeElections = null,
    Object? upcomingElections = null,
    Object? completedElections = null,
    Object? registeredVoters = null,
    Object? totalVotesCast = null,
    Object? voterTurnoutRate = null,
    Object? totalCandidates = null,
    Object? approvedCandidates = null,
    Object? pendingCandidates = null,
    Object? activeComselecOfficials = null,
    Object? electionViolations = null,
    Object? complianceRate = null,
    Object? turnoutTrend = null,
  }) {
    return _then(
      _$ElectionStatsModelImpl(
        activeElections: null == activeElections
            ? _value.activeElections
            : activeElections // ignore: cast_nullable_to_non_nullable
                  as int,
        upcomingElections: null == upcomingElections
            ? _value.upcomingElections
            : upcomingElections // ignore: cast_nullable_to_non_nullable
                  as int,
        completedElections: null == completedElections
            ? _value.completedElections
            : completedElections // ignore: cast_nullable_to_non_nullable
                  as int,
        registeredVoters: null == registeredVoters
            ? _value.registeredVoters
            : registeredVoters // ignore: cast_nullable_to_non_nullable
                  as int,
        totalVotesCast: null == totalVotesCast
            ? _value.totalVotesCast
            : totalVotesCast // ignore: cast_nullable_to_non_nullable
                  as int,
        voterTurnoutRate: null == voterTurnoutRate
            ? _value.voterTurnoutRate
            : voterTurnoutRate // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCandidates: null == totalCandidates
            ? _value.totalCandidates
            : totalCandidates // ignore: cast_nullable_to_non_nullable
                  as int,
        approvedCandidates: null == approvedCandidates
            ? _value.approvedCandidates
            : approvedCandidates // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingCandidates: null == pendingCandidates
            ? _value.pendingCandidates
            : pendingCandidates // ignore: cast_nullable_to_non_nullable
                  as int,
        activeComselecOfficials: null == activeComselecOfficials
            ? _value.activeComselecOfficials
            : activeComselecOfficials // ignore: cast_nullable_to_non_nullable
                  as int,
        electionViolations: null == electionViolations
            ? _value.electionViolations
            : electionViolations // ignore: cast_nullable_to_non_nullable
                  as int,
        complianceRate: null == complianceRate
            ? _value.complianceRate
            : complianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        turnoutTrend: null == turnoutTrend
            ? _value.turnoutTrend
            : turnoutTrend // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ElectionStatsModelImpl implements _ElectionStatsModel {
  const _$ElectionStatsModelImpl({
    this.activeElections = 0,
    this.upcomingElections = 0,
    this.completedElections = 0,
    this.registeredVoters = 0,
    this.totalVotesCast = 0,
    this.voterTurnoutRate = 0.0,
    this.totalCandidates = 0,
    this.approvedCandidates = 0,
    this.pendingCandidates = 0,
    this.activeComselecOfficials = 0,
    this.electionViolations = 0,
    this.complianceRate = 0.0,
    this.turnoutTrend = 0.0,
  });

  factory _$ElectionStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElectionStatsModelImplFromJson(json);

  @override
  @JsonKey()
  final int activeElections;
  @override
  @JsonKey()
  final int upcomingElections;
  @override
  @JsonKey()
  final int completedElections;
  @override
  @JsonKey()
  final int registeredVoters;
  @override
  @JsonKey()
  final int totalVotesCast;
  @override
  @JsonKey()
  final double voterTurnoutRate;
  @override
  @JsonKey()
  final int totalCandidates;
  @override
  @JsonKey()
  final int approvedCandidates;
  @override
  @JsonKey()
  final int pendingCandidates;
  @override
  @JsonKey()
  final int activeComselecOfficials;
  @override
  @JsonKey()
  final int electionViolations;
  @override
  @JsonKey()
  final double complianceRate;
  @override
  @JsonKey()
  final double turnoutTrend;

  @override
  String toString() {
    return 'ElectionStatsModel(activeElections: $activeElections, upcomingElections: $upcomingElections, completedElections: $completedElections, registeredVoters: $registeredVoters, totalVotesCast: $totalVotesCast, voterTurnoutRate: $voterTurnoutRate, totalCandidates: $totalCandidates, approvedCandidates: $approvedCandidates, pendingCandidates: $pendingCandidates, activeComselecOfficials: $activeComselecOfficials, electionViolations: $electionViolations, complianceRate: $complianceRate, turnoutTrend: $turnoutTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElectionStatsModelImpl &&
            (identical(other.activeElections, activeElections) ||
                other.activeElections == activeElections) &&
            (identical(other.upcomingElections, upcomingElections) ||
                other.upcomingElections == upcomingElections) &&
            (identical(other.completedElections, completedElections) ||
                other.completedElections == completedElections) &&
            (identical(other.registeredVoters, registeredVoters) ||
                other.registeredVoters == registeredVoters) &&
            (identical(other.totalVotesCast, totalVotesCast) ||
                other.totalVotesCast == totalVotesCast) &&
            (identical(other.voterTurnoutRate, voterTurnoutRate) ||
                other.voterTurnoutRate == voterTurnoutRate) &&
            (identical(other.totalCandidates, totalCandidates) ||
                other.totalCandidates == totalCandidates) &&
            (identical(other.approvedCandidates, approvedCandidates) ||
                other.approvedCandidates == approvedCandidates) &&
            (identical(other.pendingCandidates, pendingCandidates) ||
                other.pendingCandidates == pendingCandidates) &&
            (identical(
                  other.activeComselecOfficials,
                  activeComselecOfficials,
                ) ||
                other.activeComselecOfficials == activeComselecOfficials) &&
            (identical(other.electionViolations, electionViolations) ||
                other.electionViolations == electionViolations) &&
            (identical(other.complianceRate, complianceRate) ||
                other.complianceRate == complianceRate) &&
            (identical(other.turnoutTrend, turnoutTrend) ||
                other.turnoutTrend == turnoutTrend));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    activeElections,
    upcomingElections,
    completedElections,
    registeredVoters,
    totalVotesCast,
    voterTurnoutRate,
    totalCandidates,
    approvedCandidates,
    pendingCandidates,
    activeComselecOfficials,
    electionViolations,
    complianceRate,
    turnoutTrend,
  );

  /// Create a copy of ElectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElectionStatsModelImplCopyWith<_$ElectionStatsModelImpl> get copyWith =>
      __$$ElectionStatsModelImplCopyWithImpl<_$ElectionStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ElectionStatsModelImplToJson(this);
  }
}

abstract class _ElectionStatsModel implements ElectionStatsModel {
  const factory _ElectionStatsModel({
    final int activeElections,
    final int upcomingElections,
    final int completedElections,
    final int registeredVoters,
    final int totalVotesCast,
    final double voterTurnoutRate,
    final int totalCandidates,
    final int approvedCandidates,
    final int pendingCandidates,
    final int activeComselecOfficials,
    final int electionViolations,
    final double complianceRate,
    final double turnoutTrend,
  }) = _$ElectionStatsModelImpl;

  factory _ElectionStatsModel.fromJson(Map<String, dynamic> json) =
      _$ElectionStatsModelImpl.fromJson;

  @override
  int get activeElections;
  @override
  int get upcomingElections;
  @override
  int get completedElections;
  @override
  int get registeredVoters;
  @override
  int get totalVotesCast;
  @override
  double get voterTurnoutRate;
  @override
  int get totalCandidates;
  @override
  int get approvedCandidates;
  @override
  int get pendingCandidates;
  @override
  int get activeComselecOfficials;
  @override
  int get electionViolations;
  @override
  double get complianceRate;
  @override
  double get turnoutTrend;

  /// Create a copy of ElectionStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElectionStatsModelImplCopyWith<_$ElectionStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
