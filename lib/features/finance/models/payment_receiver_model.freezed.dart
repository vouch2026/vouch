// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_receiver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentReceiverModel _$PaymentReceiverModelFromJson(Map<String, dynamic> json) {
  return _PaymentReceiverModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentReceiverModel {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'bank_type')
  String get bankType => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_name')
  String get accountName => throw _privateConstructorUsedError;
  @JsonKey(name: 'account_number')
  String get accountNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_type')
  String? get scopeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'scope_id')
  String? get scopeId => throw _privateConstructorUsedError;

  /// Serializes this PaymentReceiverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentReceiverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentReceiverModelCopyWith<PaymentReceiverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentReceiverModelCopyWith<$Res> {
  factory $PaymentReceiverModelCopyWith(
    PaymentReceiverModel value,
    $Res Function(PaymentReceiverModel) then,
  ) = _$PaymentReceiverModelCopyWithImpl<$Res, PaymentReceiverModel>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'bank_type') String bankType,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'account_number') String accountNumber,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
    @JsonKey(name: 'scope_type') String? scopeType,
    @JsonKey(name: 'scope_id') String? scopeId,
  });
}

/// @nodoc
class _$PaymentReceiverModelCopyWithImpl<
  $Res,
  $Val extends PaymentReceiverModel
>
    implements $PaymentReceiverModelCopyWith<$Res> {
  _$PaymentReceiverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentReceiverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bankType = null,
    Object? accountName = null,
    Object? accountNumber = null,
    Object? createdByUserId = freezed,
    Object? scopeType = freezed,
    Object? scopeId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            bankType: null == bankType
                ? _value.bankType
                : bankType // ignore: cast_nullable_to_non_nullable
                      as String,
            accountName: null == accountName
                ? _value.accountName
                : accountName // ignore: cast_nullable_to_non_nullable
                      as String,
            accountNumber: null == accountNumber
                ? _value.accountNumber
                : accountNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByUserId: freezed == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            scopeType: freezed == scopeType
                ? _value.scopeType
                : scopeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            scopeId: freezed == scopeId
                ? _value.scopeId
                : scopeId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentReceiverModelImplCopyWith<$Res>
    implements $PaymentReceiverModelCopyWith<$Res> {
  factory _$$PaymentReceiverModelImplCopyWith(
    _$PaymentReceiverModelImpl value,
    $Res Function(_$PaymentReceiverModelImpl) then,
  ) = __$$PaymentReceiverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'bank_type') String bankType,
    @JsonKey(name: 'account_name') String accountName,
    @JsonKey(name: 'account_number') String accountNumber,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
    @JsonKey(name: 'scope_type') String? scopeType,
    @JsonKey(name: 'scope_id') String? scopeId,
  });
}

/// @nodoc
class __$$PaymentReceiverModelImplCopyWithImpl<$Res>
    extends _$PaymentReceiverModelCopyWithImpl<$Res, _$PaymentReceiverModelImpl>
    implements _$$PaymentReceiverModelImplCopyWith<$Res> {
  __$$PaymentReceiverModelImplCopyWithImpl(
    _$PaymentReceiverModelImpl _value,
    $Res Function(_$PaymentReceiverModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentReceiverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bankType = null,
    Object? accountName = null,
    Object? accountNumber = null,
    Object? createdByUserId = freezed,
    Object? scopeType = freezed,
    Object? scopeId = freezed,
  }) {
    return _then(
      _$PaymentReceiverModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        bankType: null == bankType
            ? _value.bankType
            : bankType // ignore: cast_nullable_to_non_nullable
                  as String,
        accountName: null == accountName
            ? _value.accountName
            : accountName // ignore: cast_nullable_to_non_nullable
                  as String,
        accountNumber: null == accountNumber
            ? _value.accountNumber
            : accountNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByUserId: freezed == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        scopeType: freezed == scopeType
            ? _value.scopeType
            : scopeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        scopeId: freezed == scopeId
            ? _value.scopeId
            : scopeId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentReceiverModelImpl implements _PaymentReceiverModel {
  const _$PaymentReceiverModelImpl({
    this.id,
    @JsonKey(name: 'bank_type') required this.bankType,
    @JsonKey(name: 'account_name') required this.accountName,
    @JsonKey(name: 'account_number') required this.accountNumber,
    @JsonKey(name: 'created_by_user_id') this.createdByUserId,
    @JsonKey(name: 'scope_type') this.scopeType,
    @JsonKey(name: 'scope_id') this.scopeId,
  });

  factory _$PaymentReceiverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentReceiverModelImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'bank_type')
  final String bankType;
  @override
  @JsonKey(name: 'account_name')
  final String accountName;
  @override
  @JsonKey(name: 'account_number')
  final String accountNumber;
  @override
  @JsonKey(name: 'created_by_user_id')
  final String? createdByUserId;
  @override
  @JsonKey(name: 'scope_type')
  final String? scopeType;
  @override
  @JsonKey(name: 'scope_id')
  final String? scopeId;

  @override
  String toString() {
    return 'PaymentReceiverModel(id: $id, bankType: $bankType, accountName: $accountName, accountNumber: $accountNumber, createdByUserId: $createdByUserId, scopeType: $scopeType, scopeId: $scopeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentReceiverModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bankType, bankType) ||
                other.bankType == bankType) &&
            (identical(other.accountName, accountName) ||
                other.accountName == accountName) &&
            (identical(other.accountNumber, accountNumber) ||
                other.accountNumber == accountNumber) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.scopeType, scopeType) ||
                other.scopeType == scopeType) &&
            (identical(other.scopeId, scopeId) || other.scopeId == scopeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    bankType,
    accountName,
    accountNumber,
    createdByUserId,
    scopeType,
    scopeId,
  );

  /// Create a copy of PaymentReceiverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentReceiverModelImplCopyWith<_$PaymentReceiverModelImpl>
  get copyWith =>
      __$$PaymentReceiverModelImplCopyWithImpl<_$PaymentReceiverModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentReceiverModelImplToJson(this);
  }
}

abstract class _PaymentReceiverModel implements PaymentReceiverModel {
  const factory _PaymentReceiverModel({
    final String? id,
    @JsonKey(name: 'bank_type') required final String bankType,
    @JsonKey(name: 'account_name') required final String accountName,
    @JsonKey(name: 'account_number') required final String accountNumber,
    @JsonKey(name: 'created_by_user_id') final String? createdByUserId,
    @JsonKey(name: 'scope_type') final String? scopeType,
    @JsonKey(name: 'scope_id') final String? scopeId,
  }) = _$PaymentReceiverModelImpl;

  factory _PaymentReceiverModel.fromJson(Map<String, dynamic> json) =
      _$PaymentReceiverModelImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'bank_type')
  String get bankType;
  @override
  @JsonKey(name: 'account_name')
  String get accountName;
  @override
  @JsonKey(name: 'account_number')
  String get accountNumber;
  @override
  @JsonKey(name: 'created_by_user_id')
  String? get createdByUserId;
  @override
  @JsonKey(name: 'scope_type')
  String? get scopeType;
  @override
  @JsonKey(name: 'scope_id')
  String? get scopeId;

  /// Create a copy of PaymentReceiverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentReceiverModelImplCopyWith<_$PaymentReceiverModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
