// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'election_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ElectionModel _$ElectionModelFromJson(Map<String, dynamic> json) {
  return _ElectionModel.fromJson(json);
}

/// @nodoc
mixin _$ElectionModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get organizationId => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // Organization, SSC, Department, COMSELEC
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // draft, upcoming, ongoing, completed, archived, cancelled
  String get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  int? get candidateCount => throw _privateConstructorUsedError;
  int? get votesCast => throw _privateConstructorUsedError;

  /// Serializes this ElectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ElectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElectionModelCopyWith<ElectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElectionModelCopyWith<$Res> {
  factory $ElectionModelCopyWith(
    ElectionModel value,
    $Res Function(ElectionModel) then,
  ) = _$ElectionModelCopyWithImpl<$Res, ElectionModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String organizationId,
    String type,
    DateTime startTime,
    DateTime endTime,
    String status,
    String createdBy,
    DateTime? createdAt,
    int? candidateCount,
    int? votesCast,
  });
}

/// @nodoc
class _$ElectionModelCopyWithImpl<$Res, $Val extends ElectionModel>
    implements $ElectionModelCopyWith<$Res> {
  _$ElectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ElectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? organizationId = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? candidateCount = freezed,
    Object? votesCast = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationId: null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            candidateCount: freezed == candidateCount
                ? _value.candidateCount
                : candidateCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            votesCast: freezed == votesCast
                ? _value.votesCast
                : votesCast // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ElectionModelImplCopyWith<$Res>
    implements $ElectionModelCopyWith<$Res> {
  factory _$$ElectionModelImplCopyWith(
    _$ElectionModelImpl value,
    $Res Function(_$ElectionModelImpl) then,
  ) = __$$ElectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String organizationId,
    String type,
    DateTime startTime,
    DateTime endTime,
    String status,
    String createdBy,
    DateTime? createdAt,
    int? candidateCount,
    int? votesCast,
  });
}

/// @nodoc
class __$$ElectionModelImplCopyWithImpl<$Res>
    extends _$ElectionModelCopyWithImpl<$Res, _$ElectionModelImpl>
    implements _$$ElectionModelImplCopyWith<$Res> {
  __$$ElectionModelImplCopyWithImpl(
    _$ElectionModelImpl _value,
    $Res Function(_$ElectionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ElectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? organizationId = null,
    Object? type = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = null,
    Object? createdBy = null,
    Object? createdAt = freezed,
    Object? candidateCount = freezed,
    Object? votesCast = freezed,
  }) {
    return _then(
      _$ElectionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationId: null == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        candidateCount: freezed == candidateCount
            ? _value.candidateCount
            : candidateCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        votesCast: freezed == votesCast
            ? _value.votesCast
            : votesCast // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ElectionModelImpl implements _ElectionModel {
  const _$ElectionModelImpl({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.type,
    required this.startTime,
    required this.endTime,
    this.status = 'draft',
    required this.createdBy,
    this.createdAt,
    this.candidateCount,
    this.votesCast,
  });

  factory _$ElectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String organizationId;
  @override
  final String type;
  // Organization, SSC, Department, COMSELEC
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  @JsonKey()
  final String status;
  // draft, upcoming, ongoing, completed, archived, cancelled
  @override
  final String createdBy;
  @override
  final DateTime? createdAt;
  @override
  final int? candidateCount;
  @override
  final int? votesCast;

  @override
  String toString() {
    return 'ElectionModel(id: $id, name: $name, organizationId: $organizationId, type: $type, startTime: $startTime, endTime: $endTime, status: $status, createdBy: $createdBy, createdAt: $createdAt, candidateCount: $candidateCount, votesCast: $votesCast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.candidateCount, candidateCount) ||
                other.candidateCount == candidateCount) &&
            (identical(other.votesCast, votesCast) ||
                other.votesCast == votesCast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    organizationId,
    type,
    startTime,
    endTime,
    status,
    createdBy,
    createdAt,
    candidateCount,
    votesCast,
  );

  /// Create a copy of ElectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElectionModelImplCopyWith<_$ElectionModelImpl> get copyWith =>
      __$$ElectionModelImplCopyWithImpl<_$ElectionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElectionModelImplToJson(this);
  }
}

abstract class _ElectionModel implements ElectionModel {
  const factory _ElectionModel({
    required final String id,
    required final String name,
    required final String organizationId,
    required final String type,
    required final DateTime startTime,
    required final DateTime endTime,
    final String status,
    required final String createdBy,
    final DateTime? createdAt,
    final int? candidateCount,
    final int? votesCast,
  }) = _$ElectionModelImpl;

  factory _ElectionModel.fromJson(Map<String, dynamic> json) =
      _$ElectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get organizationId;
  @override
  String get type; // Organization, SSC, Department, COMSELEC
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  String get status; // draft, upcoming, ongoing, completed, archived, cancelled
  @override
  String get createdBy;
  @override
  DateTime? get createdAt;
  @override
  int? get candidateCount;
  @override
  int? get votesCast;

  /// Create a copy of ElectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElectionModelImplCopyWith<_$ElectionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
