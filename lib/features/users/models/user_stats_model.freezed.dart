// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) {
  return _UserStatsModel.fromJson(json);
}

/// @nodoc
mixin _$UserStatsModel {
  int get totalUsers => throw _privateConstructorUsedError;
  int get totalStudents => throw _privateConstructorUsedError;
  int get activeStudents => throw _privateConstructorUsedError;
  int get pendingStudents => throw _privateConstructorUsedError;
  int get suspendedStudents => throw _privateConstructorUsedError;
  int get totalInstructors => throw _privateConstructorUsedError;
  int get activeInstructors => throw _privateConstructorUsedError;
  int get deansCount => throw _privateConstructorUsedError;
  int get programHeadsCount => throw _privateConstructorUsedError;
  int get totalOfficers => throw _privateConstructorUsedError;
  int get orgMembershipsCount => throw _privateConstructorUsedError;
  int get activeGovernanceAccounts => throw _privateConstructorUsedError;
  double get studentTrend => throw _privateConstructorUsedError;
  double get instructorTrend => throw _privateConstructorUsedError;
  double get governanceTrend => throw _privateConstructorUsedError;

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
    UserStatsModel value,
    $Res Function(UserStatsModel) then,
  ) = _$UserStatsModelCopyWithImpl<$Res, UserStatsModel>;
  @useResult
  $Res call({
    int totalUsers,
    int totalStudents,
    int activeStudents,
    int pendingStudents,
    int suspendedStudents,
    int totalInstructors,
    int activeInstructors,
    int deansCount,
    int programHeadsCount,
    int totalOfficers,
    int orgMembershipsCount,
    int activeGovernanceAccounts,
    double studentTrend,
    double instructorTrend,
    double governanceTrend,
  });
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res, $Val extends UserStatsModel>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? totalStudents = null,
    Object? activeStudents = null,
    Object? pendingStudents = null,
    Object? suspendedStudents = null,
    Object? totalInstructors = null,
    Object? activeInstructors = null,
    Object? deansCount = null,
    Object? programHeadsCount = null,
    Object? totalOfficers = null,
    Object? orgMembershipsCount = null,
    Object? activeGovernanceAccounts = null,
    Object? studentTrend = null,
    Object? instructorTrend = null,
    Object? governanceTrend = null,
  }) {
    return _then(
      _value.copyWith(
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStudents: null == totalStudents
                ? _value.totalStudents
                : totalStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            activeStudents: null == activeStudents
                ? _value.activeStudents
                : activeStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            pendingStudents: null == pendingStudents
                ? _value.pendingStudents
                : pendingStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            suspendedStudents: null == suspendedStudents
                ? _value.suspendedStudents
                : suspendedStudents // ignore: cast_nullable_to_non_nullable
                      as int,
            totalInstructors: null == totalInstructors
                ? _value.totalInstructors
                : totalInstructors // ignore: cast_nullable_to_non_nullable
                      as int,
            activeInstructors: null == activeInstructors
                ? _value.activeInstructors
                : activeInstructors // ignore: cast_nullable_to_non_nullable
                      as int,
            deansCount: null == deansCount
                ? _value.deansCount
                : deansCount // ignore: cast_nullable_to_non_nullable
                      as int,
            programHeadsCount: null == programHeadsCount
                ? _value.programHeadsCount
                : programHeadsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOfficers: null == totalOfficers
                ? _value.totalOfficers
                : totalOfficers // ignore: cast_nullable_to_non_nullable
                      as int,
            orgMembershipsCount: null == orgMembershipsCount
                ? _value.orgMembershipsCount
                : orgMembershipsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            activeGovernanceAccounts: null == activeGovernanceAccounts
                ? _value.activeGovernanceAccounts
                : activeGovernanceAccounts // ignore: cast_nullable_to_non_nullable
                      as int,
            studentTrend: null == studentTrend
                ? _value.studentTrend
                : studentTrend // ignore: cast_nullable_to_non_nullable
                      as double,
            instructorTrend: null == instructorTrend
                ? _value.instructorTrend
                : instructorTrend // ignore: cast_nullable_to_non_nullable
                      as double,
            governanceTrend: null == governanceTrend
                ? _value.governanceTrend
                : governanceTrend // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserStatsModelImplCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$$UserStatsModelImplCopyWith(
    _$UserStatsModelImpl value,
    $Res Function(_$UserStatsModelImpl) then,
  ) = __$$UserStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalUsers,
    int totalStudents,
    int activeStudents,
    int pendingStudents,
    int suspendedStudents,
    int totalInstructors,
    int activeInstructors,
    int deansCount,
    int programHeadsCount,
    int totalOfficers,
    int orgMembershipsCount,
    int activeGovernanceAccounts,
    double studentTrend,
    double instructorTrend,
    double governanceTrend,
  });
}

/// @nodoc
class __$$UserStatsModelImplCopyWithImpl<$Res>
    extends _$UserStatsModelCopyWithImpl<$Res, _$UserStatsModelImpl>
    implements _$$UserStatsModelImplCopyWith<$Res> {
  __$$UserStatsModelImplCopyWithImpl(
    _$UserStatsModelImpl _value,
    $Res Function(_$UserStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalUsers = null,
    Object? totalStudents = null,
    Object? activeStudents = null,
    Object? pendingStudents = null,
    Object? suspendedStudents = null,
    Object? totalInstructors = null,
    Object? activeInstructors = null,
    Object? deansCount = null,
    Object? programHeadsCount = null,
    Object? totalOfficers = null,
    Object? orgMembershipsCount = null,
    Object? activeGovernanceAccounts = null,
    Object? studentTrend = null,
    Object? instructorTrend = null,
    Object? governanceTrend = null,
  }) {
    return _then(
      _$UserStatsModelImpl(
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStudents: null == totalStudents
            ? _value.totalStudents
            : totalStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        activeStudents: null == activeStudents
            ? _value.activeStudents
            : activeStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        pendingStudents: null == pendingStudents
            ? _value.pendingStudents
            : pendingStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        suspendedStudents: null == suspendedStudents
            ? _value.suspendedStudents
            : suspendedStudents // ignore: cast_nullable_to_non_nullable
                  as int,
        totalInstructors: null == totalInstructors
            ? _value.totalInstructors
            : totalInstructors // ignore: cast_nullable_to_non_nullable
                  as int,
        activeInstructors: null == activeInstructors
            ? _value.activeInstructors
            : activeInstructors // ignore: cast_nullable_to_non_nullable
                  as int,
        deansCount: null == deansCount
            ? _value.deansCount
            : deansCount // ignore: cast_nullable_to_non_nullable
                  as int,
        programHeadsCount: null == programHeadsCount
            ? _value.programHeadsCount
            : programHeadsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOfficers: null == totalOfficers
            ? _value.totalOfficers
            : totalOfficers // ignore: cast_nullable_to_non_nullable
                  as int,
        orgMembershipsCount: null == orgMembershipsCount
            ? _value.orgMembershipsCount
            : orgMembershipsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        activeGovernanceAccounts: null == activeGovernanceAccounts
            ? _value.activeGovernanceAccounts
            : activeGovernanceAccounts // ignore: cast_nullable_to_non_nullable
                  as int,
        studentTrend: null == studentTrend
            ? _value.studentTrend
            : studentTrend // ignore: cast_nullable_to_non_nullable
                  as double,
        instructorTrend: null == instructorTrend
            ? _value.instructorTrend
            : instructorTrend // ignore: cast_nullable_to_non_nullable
                  as double,
        governanceTrend: null == governanceTrend
            ? _value.governanceTrend
            : governanceTrend // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsModelImpl extends _UserStatsModel {
  const _$UserStatsModelImpl({
    this.totalUsers = 0,
    this.totalStudents = 0,
    this.activeStudents = 0,
    this.pendingStudents = 0,
    this.suspendedStudents = 0,
    this.totalInstructors = 0,
    this.activeInstructors = 0,
    this.deansCount = 0,
    this.programHeadsCount = 0,
    this.totalOfficers = 0,
    this.orgMembershipsCount = 0,
    this.activeGovernanceAccounts = 0,
    this.studentTrend = 0.0,
    this.instructorTrend = 0.0,
    this.governanceTrend = 0.0,
  }) : super._();

  factory _$UserStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelImplFromJson(json);

  @override
  @JsonKey()
  final int totalUsers;
  @override
  @JsonKey()
  final int totalStudents;
  @override
  @JsonKey()
  final int activeStudents;
  @override
  @JsonKey()
  final int pendingStudents;
  @override
  @JsonKey()
  final int suspendedStudents;
  @override
  @JsonKey()
  final int totalInstructors;
  @override
  @JsonKey()
  final int activeInstructors;
  @override
  @JsonKey()
  final int deansCount;
  @override
  @JsonKey()
  final int programHeadsCount;
  @override
  @JsonKey()
  final int totalOfficers;
  @override
  @JsonKey()
  final int orgMembershipsCount;
  @override
  @JsonKey()
  final int activeGovernanceAccounts;
  @override
  @JsonKey()
  final double studentTrend;
  @override
  @JsonKey()
  final double instructorTrend;
  @override
  @JsonKey()
  final double governanceTrend;

  @override
  String toString() {
    return 'UserStatsModel(totalUsers: $totalUsers, totalStudents: $totalStudents, activeStudents: $activeStudents, pendingStudents: $pendingStudents, suspendedStudents: $suspendedStudents, totalInstructors: $totalInstructors, activeInstructors: $activeInstructors, deansCount: $deansCount, programHeadsCount: $programHeadsCount, totalOfficers: $totalOfficers, orgMembershipsCount: $orgMembershipsCount, activeGovernanceAccounts: $activeGovernanceAccounts, studentTrend: $studentTrend, instructorTrend: $instructorTrend, governanceTrend: $governanceTrend)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsModelImpl &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.totalStudents, totalStudents) ||
                other.totalStudents == totalStudents) &&
            (identical(other.activeStudents, activeStudents) ||
                other.activeStudents == activeStudents) &&
            (identical(other.pendingStudents, pendingStudents) ||
                other.pendingStudents == pendingStudents) &&
            (identical(other.suspendedStudents, suspendedStudents) ||
                other.suspendedStudents == suspendedStudents) &&
            (identical(other.totalInstructors, totalInstructors) ||
                other.totalInstructors == totalInstructors) &&
            (identical(other.activeInstructors, activeInstructors) ||
                other.activeInstructors == activeInstructors) &&
            (identical(other.deansCount, deansCount) ||
                other.deansCount == deansCount) &&
            (identical(other.programHeadsCount, programHeadsCount) ||
                other.programHeadsCount == programHeadsCount) &&
            (identical(other.totalOfficers, totalOfficers) ||
                other.totalOfficers == totalOfficers) &&
            (identical(other.orgMembershipsCount, orgMembershipsCount) ||
                other.orgMembershipsCount == orgMembershipsCount) &&
            (identical(
                  other.activeGovernanceAccounts,
                  activeGovernanceAccounts,
                ) ||
                other.activeGovernanceAccounts == activeGovernanceAccounts) &&
            (identical(other.studentTrend, studentTrend) ||
                other.studentTrend == studentTrend) &&
            (identical(other.instructorTrend, instructorTrend) ||
                other.instructorTrend == instructorTrend) &&
            (identical(other.governanceTrend, governanceTrend) ||
                other.governanceTrend == governanceTrend));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalUsers,
    totalStudents,
    activeStudents,
    pendingStudents,
    suspendedStudents,
    totalInstructors,
    activeInstructors,
    deansCount,
    programHeadsCount,
    totalOfficers,
    orgMembershipsCount,
    activeGovernanceAccounts,
    studentTrend,
    instructorTrend,
    governanceTrend,
  );

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      __$$UserStatsModelImplCopyWithImpl<_$UserStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsModelImplToJson(this);
  }
}

abstract class _UserStatsModel extends UserStatsModel {
  const factory _UserStatsModel({
    final int totalUsers,
    final int totalStudents,
    final int activeStudents,
    final int pendingStudents,
    final int suspendedStudents,
    final int totalInstructors,
    final int activeInstructors,
    final int deansCount,
    final int programHeadsCount,
    final int totalOfficers,
    final int orgMembershipsCount,
    final int activeGovernanceAccounts,
    final double studentTrend,
    final double instructorTrend,
    final double governanceTrend,
  }) = _$UserStatsModelImpl;
  const _UserStatsModel._() : super._();

  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelImpl.fromJson;

  @override
  int get totalUsers;
  @override
  int get totalStudents;
  @override
  int get activeStudents;
  @override
  int get pendingStudents;
  @override
  int get suspendedStudents;
  @override
  int get totalInstructors;
  @override
  int get activeInstructors;
  @override
  int get deansCount;
  @override
  int get programHeadsCount;
  @override
  int get totalOfficers;
  @override
  int get orgMembershipsCount;
  @override
  int get activeGovernanceAccounts;
  @override
  double get studentTrend;
  @override
  double get instructorTrend;
  @override
  double get governanceTrend;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
