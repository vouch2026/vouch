// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'candidate_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CandidateModel _$CandidateModelFromJson(Map<String, dynamic> json) {
  return _CandidateModel.fromJson(json);
}

/// @nodoc
mixin _$CandidateModel {
  String get id => throw _privateConstructorUsedError;
  String get electionId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  String? get partyList => throw _privateConstructorUsedError;
  String? get platform => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, approved, rejected, withdrawn, disqualified
  int get votes => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get organizationName => throw _privateConstructorUsedError;

  /// Serializes this CandidateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CandidateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CandidateModelCopyWith<CandidateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CandidateModelCopyWith<$Res> {
  factory $CandidateModelCopyWith(
    CandidateModel value,
    $Res Function(CandidateModel) then,
  ) = _$CandidateModelCopyWithImpl<$Res, CandidateModel>;
  @useResult
  $Res call({
    String id,
    String electionId,
    String userId,
    String fullName,
    String position,
    String? partyList,
    String? platform,
    String status,
    int votes,
    String? avatarUrl,
    String? organizationName,
  });
}

/// @nodoc
class _$CandidateModelCopyWithImpl<$Res, $Val extends CandidateModel>
    implements $CandidateModelCopyWith<$Res> {
  _$CandidateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CandidateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? userId = null,
    Object? fullName = null,
    Object? position = null,
    Object? partyList = freezed,
    Object? platform = freezed,
    Object? status = null,
    Object? votes = null,
    Object? avatarUrl = freezed,
    Object? organizationName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            electionId: null == electionId
                ? _value.electionId
                : electionId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as String,
            partyList: freezed == partyList
                ? _value.partyList
                : partyList // ignore: cast_nullable_to_non_nullable
                      as String?,
            platform: freezed == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            votes: null == votes
                ? _value.votes
                : votes // ignore: cast_nullable_to_non_nullable
                      as int,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            organizationName: freezed == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CandidateModelImplCopyWith<$Res>
    implements $CandidateModelCopyWith<$Res> {
  factory _$$CandidateModelImplCopyWith(
    _$CandidateModelImpl value,
    $Res Function(_$CandidateModelImpl) then,
  ) = __$$CandidateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String electionId,
    String userId,
    String fullName,
    String position,
    String? partyList,
    String? platform,
    String status,
    int votes,
    String? avatarUrl,
    String? organizationName,
  });
}

/// @nodoc
class __$$CandidateModelImplCopyWithImpl<$Res>
    extends _$CandidateModelCopyWithImpl<$Res, _$CandidateModelImpl>
    implements _$$CandidateModelImplCopyWith<$Res> {
  __$$CandidateModelImplCopyWithImpl(
    _$CandidateModelImpl _value,
    $Res Function(_$CandidateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CandidateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? electionId = null,
    Object? userId = null,
    Object? fullName = null,
    Object? position = null,
    Object? partyList = freezed,
    Object? platform = freezed,
    Object? status = null,
    Object? votes = null,
    Object? avatarUrl = freezed,
    Object? organizationName = freezed,
  }) {
    return _then(
      _$CandidateModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        electionId: null == electionId
            ? _value.electionId
            : electionId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as String,
        partyList: freezed == partyList
            ? _value.partyList
            : partyList // ignore: cast_nullable_to_non_nullable
                  as String?,
        platform: freezed == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        votes: null == votes
            ? _value.votes
            : votes // ignore: cast_nullable_to_non_nullable
                  as int,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        organizationName: freezed == organizationName
            ? _value.organizationName
            : organizationName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CandidateModelImpl implements _CandidateModel {
  const _$CandidateModelImpl({
    required this.id,
    required this.electionId,
    required this.userId,
    required this.fullName,
    required this.position,
    this.partyList,
    this.platform,
    this.status = 'pending',
    this.votes = 0,
    this.avatarUrl,
    this.organizationName,
  });

  factory _$CandidateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CandidateModelImplFromJson(json);

  @override
  final String id;
  @override
  final String electionId;
  @override
  final String userId;
  @override
  final String fullName;
  @override
  final String position;
  @override
  final String? partyList;
  @override
  final String? platform;
  @override
  @JsonKey()
  final String status;
  // pending, approved, rejected, withdrawn, disqualified
  @override
  @JsonKey()
  final int votes;
  @override
  final String? avatarUrl;
  @override
  final String? organizationName;

  @override
  String toString() {
    return 'CandidateModel(id: $id, electionId: $electionId, userId: $userId, fullName: $fullName, position: $position, partyList: $partyList, platform: $platform, status: $status, votes: $votes, avatarUrl: $avatarUrl, organizationName: $organizationName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CandidateModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.electionId, electionId) ||
                other.electionId == electionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.partyList, partyList) ||
                other.partyList == partyList) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.votes, votes) || other.votes == votes) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    electionId,
    userId,
    fullName,
    position,
    partyList,
    platform,
    status,
    votes,
    avatarUrl,
    organizationName,
  );

  /// Create a copy of CandidateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CandidateModelImplCopyWith<_$CandidateModelImpl> get copyWith =>
      __$$CandidateModelImplCopyWithImpl<_$CandidateModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CandidateModelImplToJson(this);
  }
}

abstract class _CandidateModel implements CandidateModel {
  const factory _CandidateModel({
    required final String id,
    required final String electionId,
    required final String userId,
    required final String fullName,
    required final String position,
    final String? partyList,
    final String? platform,
    final String status,
    final int votes,
    final String? avatarUrl,
    final String? organizationName,
  }) = _$CandidateModelImpl;

  factory _CandidateModel.fromJson(Map<String, dynamic> json) =
      _$CandidateModelImpl.fromJson;

  @override
  String get id;
  @override
  String get electionId;
  @override
  String get userId;
  @override
  String get fullName;
  @override
  String get position;
  @override
  String? get partyList;
  @override
  String? get platform;
  @override
  String get status; // pending, approved, rejected, withdrawn, disqualified
  @override
  int get votes;
  @override
  String? get avatarUrl;
  @override
  String? get organizationName;

  /// Create a copy of CandidateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CandidateModelImplCopyWith<_$CandidateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
