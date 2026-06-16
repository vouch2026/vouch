// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_receiver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentReceiverModel {

 String? get id;@JsonKey(name: 'bank_type') String get bankType;@JsonKey(name: 'account_name') String get accountName;@JsonKey(name: 'account_number') String get accountNumber;@JsonKey(name: 'created_by_user_id') String? get createdByUserId;@JsonKey(name: 'scope_type') String? get scopeType;@JsonKey(name: 'scope_id') String? get scopeId;
/// Create a copy of PaymentReceiverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentReceiverModelCopyWith<PaymentReceiverModel> get copyWith => _$PaymentReceiverModelCopyWithImpl<PaymentReceiverModel>(this as PaymentReceiverModel, _$identity);

  /// Serializes this PaymentReceiverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentReceiverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bankType,accountName,accountNumber,createdByUserId,scopeType,scopeId);

@override
String toString() {
  return 'PaymentReceiverModel(id: $id, bankType: $bankType, accountName: $accountName, accountNumber: $accountNumber, createdByUserId: $createdByUserId, scopeType: $scopeType, scopeId: $scopeId)';
}


}

/// @nodoc
abstract mixin class $PaymentReceiverModelCopyWith<$Res>  {
  factory $PaymentReceiverModelCopyWith(PaymentReceiverModel value, $Res Function(PaymentReceiverModel) _then) = _$PaymentReceiverModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'bank_type') String bankType,@JsonKey(name: 'account_name') String accountName,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(name: 'scope_type') String? scopeType,@JsonKey(name: 'scope_id') String? scopeId
});




}
/// @nodoc
class _$PaymentReceiverModelCopyWithImpl<$Res>
    implements $PaymentReceiverModelCopyWith<$Res> {
  _$PaymentReceiverModelCopyWithImpl(this._self, this._then);

  final PaymentReceiverModel _self;
  final $Res Function(PaymentReceiverModel) _then;

/// Create a copy of PaymentReceiverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? bankType = null,Object? accountName = null,Object? accountNumber = null,Object? createdByUserId = freezed,Object? scopeType = freezed,Object? scopeId = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,scopeType: freezed == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String?,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentReceiverModel].
extension PaymentReceiverModelPatterns on PaymentReceiverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentReceiverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentReceiverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentReceiverModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentReceiverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentReceiverModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentReceiverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'bank_type')  String bankType, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'scope_type')  String? scopeType, @JsonKey(name: 'scope_id')  String? scopeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentReceiverModel() when $default != null:
return $default(_that.id,_that.bankType,_that.accountName,_that.accountNumber,_that.createdByUserId,_that.scopeType,_that.scopeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'bank_type')  String bankType, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'scope_type')  String? scopeType, @JsonKey(name: 'scope_id')  String? scopeId)  $default,) {final _that = this;
switch (_that) {
case _PaymentReceiverModel():
return $default(_that.id,_that.bankType,_that.accountName,_that.accountNumber,_that.createdByUserId,_that.scopeType,_that.scopeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'bank_type')  String bankType, @JsonKey(name: 'account_name')  String accountName, @JsonKey(name: 'account_number')  String accountNumber, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'scope_type')  String? scopeType, @JsonKey(name: 'scope_id')  String? scopeId)?  $default,) {final _that = this;
switch (_that) {
case _PaymentReceiverModel() when $default != null:
return $default(_that.id,_that.bankType,_that.accountName,_that.accountNumber,_that.createdByUserId,_that.scopeType,_that.scopeId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentReceiverModel implements PaymentReceiverModel {
  const _PaymentReceiverModel({this.id, @JsonKey(name: 'bank_type') required this.bankType, @JsonKey(name: 'account_name') required this.accountName, @JsonKey(name: 'account_number') required this.accountNumber, @JsonKey(name: 'created_by_user_id') this.createdByUserId, @JsonKey(name: 'scope_type') this.scopeType, @JsonKey(name: 'scope_id') this.scopeId});
  factory _PaymentReceiverModel.fromJson(Map<String, dynamic> json) => _$PaymentReceiverModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'bank_type') final  String bankType;
@override@JsonKey(name: 'account_name') final  String accountName;
@override@JsonKey(name: 'account_number') final  String accountNumber;
@override@JsonKey(name: 'created_by_user_id') final  String? createdByUserId;
@override@JsonKey(name: 'scope_type') final  String? scopeType;
@override@JsonKey(name: 'scope_id') final  String? scopeId;

/// Create a copy of PaymentReceiverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentReceiverModelCopyWith<_PaymentReceiverModel> get copyWith => __$PaymentReceiverModelCopyWithImpl<_PaymentReceiverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentReceiverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentReceiverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.bankType, bankType) || other.bankType == bankType)&&(identical(other.accountName, accountName) || other.accountName == accountName)&&(identical(other.accountNumber, accountNumber) || other.accountNumber == accountNumber)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bankType,accountName,accountNumber,createdByUserId,scopeType,scopeId);

@override
String toString() {
  return 'PaymentReceiverModel(id: $id, bankType: $bankType, accountName: $accountName, accountNumber: $accountNumber, createdByUserId: $createdByUserId, scopeType: $scopeType, scopeId: $scopeId)';
}


}

/// @nodoc
abstract mixin class _$PaymentReceiverModelCopyWith<$Res> implements $PaymentReceiverModelCopyWith<$Res> {
  factory _$PaymentReceiverModelCopyWith(_PaymentReceiverModel value, $Res Function(_PaymentReceiverModel) _then) = __$PaymentReceiverModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'bank_type') String bankType,@JsonKey(name: 'account_name') String accountName,@JsonKey(name: 'account_number') String accountNumber,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(name: 'scope_type') String? scopeType,@JsonKey(name: 'scope_id') String? scopeId
});




}
/// @nodoc
class __$PaymentReceiverModelCopyWithImpl<$Res>
    implements _$PaymentReceiverModelCopyWith<$Res> {
  __$PaymentReceiverModelCopyWithImpl(this._self, this._then);

  final _PaymentReceiverModel _self;
  final $Res Function(_PaymentReceiverModel) _then;

/// Create a copy of PaymentReceiverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? bankType = null,Object? accountName = null,Object? accountNumber = null,Object? createdByUserId = freezed,Object? scopeType = freezed,Object? scopeId = freezed,}) {
  return _then(_PaymentReceiverModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,bankType: null == bankType ? _self.bankType : bankType // ignore: cast_nullable_to_non_nullable
as String,accountName: null == accountName ? _self.accountName : accountName // ignore: cast_nullable_to_non_nullable
as String,accountNumber: null == accountNumber ? _self.accountNumber : accountNumber // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,scopeType: freezed == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String?,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
