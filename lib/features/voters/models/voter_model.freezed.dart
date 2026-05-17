// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VoterModel _$VoterModelFromJson(Map<String, dynamic> json) {
  return _VoterModel.fromJson(json);
}

/// @nodoc
mixin _$VoterModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get electionId => throw _privateConstructorUsedError;
  String get studentNumber => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get campusName => throw _privateConstructorUsedError;
  String? get facultyName => throw _privateConstructorUsedError;
  String? get programName => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // eligible, voted, not_voted, restricted
  DateTime? get votedAt => throw _privateConstructorUsedError;

  /// Serializes this VoterModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoterModelCopyWith<VoterModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoterModelCopyWith<$Res> {
  factory $VoterModelCopyWith(
    VoterModel value,
    $Res Function(VoterModel) then,
  ) = _$VoterModelCopyWithImpl<$Res, VoterModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String electionId,
    String studentNumber,
    String fullName,
    String? campusName,
    String? facultyName,
    String? programName,
    String status,
    DateTime? votedAt,
  });
}

/// @nodoc
class _$VoterModelCopyWithImpl<$Res, $Val extends VoterModel>
    implements $VoterModelCopyWith<$Res> {
  _$VoterModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? electionId = null,
    Object? studentNumber = null,
    Object? fullName = null,
    Object? campusName = freezed,
    Object? facultyName = freezed,
    Object? programName = freezed,
    Object? status = null,
    Object? votedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            electionId: null == electionId
                ? _value.electionId
                : electionId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentNumber: null == studentNumber
                ? _value.studentNumber
                : studentNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            campusName: freezed == campusName
                ? _value.campusName
                : campusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            facultyName: freezed == facultyName
                ? _value.facultyName
                : facultyName // ignore: cast_nullable_to_non_nullable
                      as String?,
            programName: freezed == programName
                ? _value.programName
                : programName // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            votedAt: freezed == votedAt
                ? _value.votedAt
                : votedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VoterModelImplCopyWith<$Res>
    implements $VoterModelCopyWith<$Res> {
  factory _$$VoterModelImplCopyWith(
    _$VoterModelImpl value,
    $Res Function(_$VoterModelImpl) then,
  ) = __$$VoterModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String electionId,
    String studentNumber,
    String fullName,
    String? campusName,
    String? facultyName,
    String? programName,
    String status,
    DateTime? votedAt,
  });
}

/// @nodoc
class __$$VoterModelImplCopyWithImpl<$Res>
    extends _$VoterModelCopyWithImpl<$Res, _$VoterModelImpl>
    implements _$$VoterModelImplCopyWith<$Res> {
  __$$VoterModelImplCopyWithImpl(
    _$VoterModelImpl _value,
    $Res Function(_$VoterModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VoterModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? electionId = null,
    Object? studentNumber = null,
    Object? fullName = null,
    Object? campusName = freezed,
    Object? facultyName = freezed,
    Object? programName = freezed,
    Object? status = null,
    Object? votedAt = freezed,
  }) {
    return _then(
      _$VoterModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        electionId: null == electionId
            ? _value.electionId
            : electionId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentNumber: null == studentNumber
            ? _value.studentNumber
            : studentNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        campusName: freezed == campusName
            ? _value.campusName
            : campusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        facultyName: freezed == facultyName
            ? _value.facultyName
            : facultyName // ignore: cast_nullable_to_non_nullable
                  as String?,
        programName: freezed == programName
            ? _value.programName
            : programName // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        votedAt: freezed == votedAt
            ? _value.votedAt
            : votedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VoterModelImpl implements _VoterModel {
  const _$VoterModelImpl({
    required this.id,
    required this.userId,
    required this.electionId,
    required this.studentNumber,
    required this.fullName,
    this.campusName,
    this.facultyName,
    this.programName,
    this.status = 'eligible',
    this.votedAt,
  });

  factory _$VoterModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoterModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String electionId;
  @override
  final String studentNumber;
  @override
  final String fullName;
  @override
  final String? campusName;
  @override
  final String? facultyName;
  @override
  final String? programName;
  @override
  @JsonKey()
  final String status;
  // eligible, voted, not_voted, restricted
  @override
  final DateTime? votedAt;

  @override
  String toString() {
    return 'VoterModel(id: $id, userId: $userId, electionId: $electionId, studentNumber: $studentNumber, fullName: $fullName, campusName: $campusName, facultyName: $facultyName, programName: $programName, status: $status, votedAt: $votedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoterModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.electionId, electionId) ||
                other.electionId == electionId) &&
            (identical(other.studentNumber, studentNumber) ||
                other.studentNumber == studentNumber) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.campusName, campusName) ||
                other.campusName == campusName) &&
            (identical(other.facultyName, facultyName) ||
                other.facultyName == facultyName) &&
            (identical(other.programName, programName) ||
                other.programName == programName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.votedAt, votedAt) || other.votedAt == votedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    electionId,
    studentNumber,
    fullName,
    campusName,
    facultyName,
    programName,
    status,
    votedAt,
  );

  /// Create a copy of VoterModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoterModelImplCopyWith<_$VoterModelImpl> get copyWith =>
      __$$VoterModelImplCopyWithImpl<_$VoterModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoterModelImplToJson(this);
  }
}

abstract class _VoterModel implements VoterModel {
  const factory _VoterModel({
    required final String id,
    required final String userId,
    required final String electionId,
    required final String studentNumber,
    required final String fullName,
    final String? campusName,
    final String? facultyName,
    final String? programName,
    final String status,
    final DateTime? votedAt,
  }) = _$VoterModelImpl;

  factory _VoterModel.fromJson(Map<String, dynamic> json) =
      _$VoterModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get electionId;
  @override
  String get studentNumber;
  @override
  String get fullName;
  @override
  String? get campusName;
  @override
  String? get facultyName;
  @override
  String? get programName;
  @override
  String get status; // eligible, voted, not_voted, restricted
  @override
  DateTime? get votedAt;

  /// Create a copy of VoterModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoterModelImplCopyWith<_$VoterModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
