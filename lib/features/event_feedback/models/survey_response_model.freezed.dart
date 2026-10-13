// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurveyResponseModel {

 String? get id;@JsonKey(name: 'survey_id') String? get surveyId;@JsonKey(name: 'event_id') String get eventId;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'overall_rating') int get overallRating; String? get comment;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of SurveyResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurveyResponseModelCopyWith<SurveyResponseModel> get copyWith => _$SurveyResponseModelCopyWithImpl<SurveyResponseModel>(this as SurveyResponseModel, _$identity);

  /// Serializes this SurveyResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurveyResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.overallRating, overallRating) || other.overallRating == overallRating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,eventId,userId,overallRating,comment,createdAt,updatedAt);

@override
String toString() {
  return 'SurveyResponseModel(id: $id, surveyId: $surveyId, eventId: $eventId, userId: $userId, overallRating: $overallRating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SurveyResponseModelCopyWith<$Res>  {
  factory $SurveyResponseModelCopyWith(SurveyResponseModel value, $Res Function(SurveyResponseModel) _then) = _$SurveyResponseModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'survey_id') String? surveyId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'overall_rating') int overallRating, String? comment,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$SurveyResponseModelCopyWithImpl<$Res>
    implements $SurveyResponseModelCopyWith<$Res> {
  _$SurveyResponseModelCopyWithImpl(this._self, this._then);

  final SurveyResponseModel _self;
  final $Res Function(SurveyResponseModel) _then;

/// Create a copy of SurveyResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? surveyId = freezed,Object? eventId = null,Object? userId = null,Object? overallRating = null,Object? comment = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,surveyId: freezed == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,overallRating: null == overallRating ? _self.overallRating : overallRating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SurveyResponseModel].
extension SurveyResponseModelPatterns on SurveyResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurveyResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurveyResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurveyResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SurveyResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurveyResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SurveyResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'survey_id')  String? surveyId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'overall_rating')  int overallRating,  String? comment, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurveyResponseModel() when $default != null:
return $default(_that.id,_that.surveyId,_that.eventId,_that.userId,_that.overallRating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'survey_id')  String? surveyId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'overall_rating')  int overallRating,  String? comment, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SurveyResponseModel():
return $default(_that.id,_that.surveyId,_that.eventId,_that.userId,_that.overallRating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'survey_id')  String? surveyId, @JsonKey(name: 'event_id')  String eventId, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'overall_rating')  int overallRating,  String? comment, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SurveyResponseModel() when $default != null:
return $default(_that.id,_that.surveyId,_that.eventId,_that.userId,_that.overallRating,_that.comment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurveyResponseModel implements SurveyResponseModel {
  const _SurveyResponseModel({this.id, @JsonKey(name: 'survey_id') this.surveyId, @JsonKey(name: 'event_id') required this.eventId, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'overall_rating') required this.overallRating, this.comment, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _SurveyResponseModel.fromJson(Map<String, dynamic> json) => _$SurveyResponseModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'survey_id') final  String? surveyId;
@override@JsonKey(name: 'event_id') final  String eventId;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'overall_rating') final  int overallRating;
@override final  String? comment;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of SurveyResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurveyResponseModelCopyWith<_SurveyResponseModel> get copyWith => __$SurveyResponseModelCopyWithImpl<_SurveyResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurveyResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurveyResponseModel&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.overallRating, overallRating) || other.overallRating == overallRating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,eventId,userId,overallRating,comment,createdAt,updatedAt);

@override
String toString() {
  return 'SurveyResponseModel(id: $id, surveyId: $surveyId, eventId: $eventId, userId: $userId, overallRating: $overallRating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SurveyResponseModelCopyWith<$Res> implements $SurveyResponseModelCopyWith<$Res> {
  factory _$SurveyResponseModelCopyWith(_SurveyResponseModel value, $Res Function(_SurveyResponseModel) _then) = __$SurveyResponseModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'survey_id') String? surveyId,@JsonKey(name: 'event_id') String eventId,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'overall_rating') int overallRating, String? comment,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$SurveyResponseModelCopyWithImpl<$Res>
    implements _$SurveyResponseModelCopyWith<$Res> {
  __$SurveyResponseModelCopyWithImpl(this._self, this._then);

  final _SurveyResponseModel _self;
  final $Res Function(_SurveyResponseModel) _then;

/// Create a copy of SurveyResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? surveyId = freezed,Object? eventId = null,Object? userId = null,Object? overallRating = null,Object? comment = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SurveyResponseModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,surveyId: freezed == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String?,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,overallRating: null == overallRating ? _self.overallRating : overallRating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
