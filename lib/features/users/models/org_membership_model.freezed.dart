// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'org_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrgMembershipModel _$OrgMembershipModelFromJson(Map<String, dynamic> json) {
  return _OrgMembershipModel.fromJson(json);
}

/// @nodoc
mixin _$OrgMembershipModel {
  String get organizationId => throw _privateConstructorUsedError;
  String get organizationName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime? get joinedAt => throw _privateConstructorUsedError;
  bool get isCurrent => throw _privateConstructorUsedError;
  String? get positionTitle => throw _privateConstructorUsedError;

  /// Serializes this OrgMembershipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrgMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrgMembershipModelCopyWith<OrgMembershipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrgMembershipModelCopyWith<$Res> {
  factory $OrgMembershipModelCopyWith(
    OrgMembershipModel value,
    $Res Function(OrgMembershipModel) then,
  ) = _$OrgMembershipModelCopyWithImpl<$Res, OrgMembershipModel>;
  @useResult
  $Res call({
    String organizationId,
    String organizationName,
    String role,
    DateTime? joinedAt,
    bool isCurrent,
    String? positionTitle,
  });
}

/// @nodoc
class _$OrgMembershipModelCopyWithImpl<$Res, $Val extends OrgMembershipModel>
    implements $OrgMembershipModelCopyWith<$Res> {
  _$OrgMembershipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrgMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = null,
    Object? organizationName = null,
    Object? role = null,
    Object? joinedAt = freezed,
    Object? isCurrent = null,
    Object? positionTitle = freezed,
  }) {
    return _then(
      _value.copyWith(
            organizationId: null == organizationId
                ? _value.organizationId
                : organizationId // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationName: null == organizationName
                ? _value.organizationName
                : organizationName // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: freezed == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isCurrent: null == isCurrent
                ? _value.isCurrent
                : isCurrent // ignore: cast_nullable_to_non_nullable
                      as bool,
            positionTitle: freezed == positionTitle
                ? _value.positionTitle
                : positionTitle // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrgMembershipModelImplCopyWith<$Res>
    implements $OrgMembershipModelCopyWith<$Res> {
  factory _$$OrgMembershipModelImplCopyWith(
    _$OrgMembershipModelImpl value,
    $Res Function(_$OrgMembershipModelImpl) then,
  ) = __$$OrgMembershipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String organizationId,
    String organizationName,
    String role,
    DateTime? joinedAt,
    bool isCurrent,
    String? positionTitle,
  });
}

/// @nodoc
class __$$OrgMembershipModelImplCopyWithImpl<$Res>
    extends _$OrgMembershipModelCopyWithImpl<$Res, _$OrgMembershipModelImpl>
    implements _$$OrgMembershipModelImplCopyWith<$Res> {
  __$$OrgMembershipModelImplCopyWithImpl(
    _$OrgMembershipModelImpl _value,
    $Res Function(_$OrgMembershipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrgMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? organizationId = null,
    Object? organizationName = null,
    Object? role = null,
    Object? joinedAt = freezed,
    Object? isCurrent = null,
    Object? positionTitle = freezed,
  }) {
    return _then(
      _$OrgMembershipModelImpl(
        organizationId: null == organizationId
            ? _value.organizationId
            : organizationId // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationName: null == organizationName
            ? _value.organizationName
            : organizationName // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: freezed == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isCurrent: null == isCurrent
            ? _value.isCurrent
            : isCurrent // ignore: cast_nullable_to_non_nullable
                  as bool,
        positionTitle: freezed == positionTitle
            ? _value.positionTitle
            : positionTitle // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrgMembershipModelImpl implements _OrgMembershipModel {
  const _$OrgMembershipModelImpl({
    required this.organizationId,
    required this.organizationName,
    required this.role,
    this.joinedAt,
    this.isCurrent = true,
    this.positionTitle,
  });

  factory _$OrgMembershipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrgMembershipModelImplFromJson(json);

  @override
  final String organizationId;
  @override
  final String organizationName;
  @override
  final String role;
  @override
  final DateTime? joinedAt;
  @override
  @JsonKey()
  final bool isCurrent;
  @override
  final String? positionTitle;

  @override
  String toString() {
    return 'OrgMembershipModel(organizationId: $organizationId, organizationName: $organizationName, role: $role, joinedAt: $joinedAt, isCurrent: $isCurrent, positionTitle: $positionTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrgMembershipModelImpl &&
            (identical(other.organizationId, organizationId) ||
                other.organizationId == organizationId) &&
            (identical(other.organizationName, organizationName) ||
                other.organizationName == organizationName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.positionTitle, positionTitle) ||
                other.positionTitle == positionTitle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    organizationId,
    organizationName,
    role,
    joinedAt,
    isCurrent,
    positionTitle,
  );

  /// Create a copy of OrgMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrgMembershipModelImplCopyWith<_$OrgMembershipModelImpl> get copyWith =>
      __$$OrgMembershipModelImplCopyWithImpl<_$OrgMembershipModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrgMembershipModelImplToJson(this);
  }
}

abstract class _OrgMembershipModel implements OrgMembershipModel {
  const factory _OrgMembershipModel({
    required final String organizationId,
    required final String organizationName,
    required final String role,
    final DateTime? joinedAt,
    final bool isCurrent,
    final String? positionTitle,
  }) = _$OrgMembershipModelImpl;

  factory _OrgMembershipModel.fromJson(Map<String, dynamic> json) =
      _$OrgMembershipModelImpl.fromJson;

  @override
  String get organizationId;
  @override
  String get organizationName;
  @override
  String get role;
  @override
  DateTime? get joinedAt;
  @override
  bool get isCurrent;
  @override
  String? get positionTitle;

  /// Create a copy of OrgMembershipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrgMembershipModelImplCopyWith<_$OrgMembershipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
