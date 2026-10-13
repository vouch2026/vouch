// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurveyModel {

 String? get id;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'created_by_user_id') String? get createdByUserId;@JsonKey(name: 'is_open') bool get isOpen;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SurveyModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurveyModelCopyWith<SurveyModel> get copyWith => _$SurveyModelCopyWithImpl<SurveyModel>(this as SurveyModel, _$identity);

  /// Serializes this SurveyModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurveyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,createdByUserId,isOpen,createdAt,updatedAt);

@override
String toString() {
  return 'SurveyModel(id: $id, eventId: $eventId, createdByUserId: $createdByUserId, isOpen: $isOpen, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SurveyModelCopyWith<$Res>  {
  factory $SurveyModelCopyWith(SurveyModel value, $Res Function(SurveyModel) _then) = _$SurveyModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(name: 'is_open') bool isOpen,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SurveyModelCopyWithImpl<$Res>
    implements $SurveyModelCopyWith<$Res> {
  _$SurveyModelCopyWithImpl(this._self, this._then);

  final SurveyModel _self;
  final $Res Function(SurveyModel) _then;

/// Create a copy of SurveyModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? eventId = null,Object? createdByUserId = freezed,Object? isOpen = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SurveyModel].
extension SurveyModelPatterns on SurveyModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurveyModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurveyModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurveyModel value)  $default,){
final _that = this;
switch (_that) {
case _SurveyModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurveyModel value)?  $default,){
final _that = this;
switch (_that) {
case _SurveyModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurveyModel() when $default != null:
return $default(_that.id,_that.eventId,_that.createdByUserId,_that.isOpen,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SurveyModel():
return $default(_that.id,_that.eventId,_that.createdByUserId,_that.isOpen,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'created_by_user_id')  String? createdByUserId, @JsonKey(name: 'is_open')  bool isOpen, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SurveyModel() when $default != null:
return $default(_that.id,_that.eventId,_that.createdByUserId,_that.isOpen,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurveyModel implements SurveyModel {
  const _SurveyModel({this.id, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'created_by_user_id') this.createdByUserId, @JsonKey(name: 'is_open') this.isOpen = true, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _SurveyModel.fromJson(Map<String, dynamic> json) => _$SurveyModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'created_by_user_id') final  String? createdByUserId;
@override@JsonKey(name: 'is_open') final  bool isOpen;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SurveyModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurveyModelCopyWith<_SurveyModel> get copyWith => __$SurveyModelCopyWithImpl<_SurveyModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurveyModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurveyModel&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.createdByUserId, createdByUserId) || other.createdByUserId == createdByUserId)&&(identical(other.isOpen, isOpen) || other.isOpen == isOpen)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,eventId,createdByUserId,isOpen,createdAt,updatedAt);

@override
String toString() {
  return 'SurveyModel(id: $id, eventId: $eventId, createdByUserId: $createdByUserId, isOpen: $isOpen, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SurveyModelCopyWith<$Res> implements $SurveyModelCopyWith<$Res> {
  factory _$SurveyModelCopyWith(_SurveyModel value, $Res Function(_SurveyModel) _then) = __$SurveyModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'created_by_user_id') String? createdByUserId,@JsonKey(name: 'is_open') bool isOpen,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SurveyModelCopyWithImpl<$Res>
    implements _$SurveyModelCopyWith<$Res> {
  __$SurveyModelCopyWithImpl(this._self, this._then);

  final _SurveyModel _self;
  final $Res Function(_SurveyModel) _then;

/// Create a copy of SurveyModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? eventId = null,Object? createdByUserId = freezed,Object? isOpen = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SurveyModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,createdByUserId: freezed == createdByUserId ? _self.createdByUserId : createdByUserId // ignore: cast_nullable_to_non_nullable
as String?,isOpen: null == isOpen ? _self.isOpen : isOpen // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
