// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_answer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurveyAnswerModel {

 String? get id;@JsonKey(name: 'response_id') String get responseId;@JsonKey(name: 'question_id') String get questionId;@JsonKey(name: 'answer_text') String? get answerText;@JsonKey(name: 'answer_option') String? get answerOption;@JsonKey(name: 'answer_bool') bool? get answerBool;@JsonKey(name: 'answer_rating') int? get answerRating;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of SurveyAnswerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurveyAnswerModelCopyWith<SurveyAnswerModel> get copyWith => _$SurveyAnswerModelCopyWithImpl<SurveyAnswerModel>(this as SurveyAnswerModel, _$identity);

  /// Serializes this SurveyAnswerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurveyAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.responseId, responseId) || other.responseId == responseId)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.answerText, answerText) || other.answerText == answerText)&&(identical(other.answerOption, answerOption) || other.answerOption == answerOption)&&(identical(other.answerBool, answerBool) || other.answerBool == answerBool)&&(identical(other.answerRating, answerRating) || other.answerRating == answerRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,responseId,questionId,answerText,answerOption,answerBool,answerRating,createdAt);

@override
String toString() {
  return 'SurveyAnswerModel(id: $id, responseId: $responseId, questionId: $questionId, answerText: $answerText, answerOption: $answerOption, answerBool: $answerBool, answerRating: $answerRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SurveyAnswerModelCopyWith<$Res>  {
  factory $SurveyAnswerModelCopyWith(SurveyAnswerModel value, $Res Function(SurveyAnswerModel) _then) = _$SurveyAnswerModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'response_id') String responseId,@JsonKey(name: 'question_id') String questionId,@JsonKey(name: 'answer_text') String? answerText,@JsonKey(name: 'answer_option') String? answerOption,@JsonKey(name: 'answer_bool') bool? answerBool,@JsonKey(name: 'answer_rating') int? answerRating,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$SurveyAnswerModelCopyWithImpl<$Res>
    implements $SurveyAnswerModelCopyWith<$Res> {
  _$SurveyAnswerModelCopyWithImpl(this._self, this._then);

  final SurveyAnswerModel _self;
  final $Res Function(SurveyAnswerModel) _then;

/// Create a copy of SurveyAnswerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? responseId = null,Object? questionId = null,Object? answerText = freezed,Object? answerOption = freezed,Object? answerBool = freezed,Object? answerRating = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,responseId: null == responseId ? _self.responseId : responseId // ignore: cast_nullable_to_non_nullable
as String,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,answerText: freezed == answerText ? _self.answerText : answerText // ignore: cast_nullable_to_non_nullable
as String?,answerOption: freezed == answerOption ? _self.answerOption : answerOption // ignore: cast_nullable_to_non_nullable
as String?,answerBool: freezed == answerBool ? _self.answerBool : answerBool // ignore: cast_nullable_to_non_nullable
as bool?,answerRating: freezed == answerRating ? _self.answerRating : answerRating // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SurveyAnswerModel].
extension SurveyAnswerModelPatterns on SurveyAnswerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurveyAnswerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurveyAnswerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurveyAnswerModel value)  $default,){
final _that = this;
switch (_that) {
case _SurveyAnswerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurveyAnswerModel value)?  $default,){
final _that = this;
switch (_that) {
case _SurveyAnswerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'response_id')  String responseId, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_text')  String? answerText, @JsonKey(name: 'answer_option')  String? answerOption, @JsonKey(name: 'answer_bool')  bool? answerBool, @JsonKey(name: 'answer_rating')  int? answerRating, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurveyAnswerModel() when $default != null:
return $default(_that.id,_that.responseId,_that.questionId,_that.answerText,_that.answerOption,_that.answerBool,_that.answerRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'response_id')  String responseId, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_text')  String? answerText, @JsonKey(name: 'answer_option')  String? answerOption, @JsonKey(name: 'answer_bool')  bool? answerBool, @JsonKey(name: 'answer_rating')  int? answerRating, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SurveyAnswerModel():
return $default(_that.id,_that.responseId,_that.questionId,_that.answerText,_that.answerOption,_that.answerBool,_that.answerRating,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'response_id')  String responseId, @JsonKey(name: 'question_id')  String questionId, @JsonKey(name: 'answer_text')  String? answerText, @JsonKey(name: 'answer_option')  String? answerOption, @JsonKey(name: 'answer_bool')  bool? answerBool, @JsonKey(name: 'answer_rating')  int? answerRating, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SurveyAnswerModel() when $default != null:
return $default(_that.id,_that.responseId,_that.questionId,_that.answerText,_that.answerOption,_that.answerBool,_that.answerRating,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurveyAnswerModel implements SurveyAnswerModel {
  const _SurveyAnswerModel({this.id, @JsonKey(name: 'response_id') required this.responseId, @JsonKey(name: 'question_id') required this.questionId, @JsonKey(name: 'answer_text') this.answerText, @JsonKey(name: 'answer_option') this.answerOption, @JsonKey(name: 'answer_bool') this.answerBool, @JsonKey(name: 'answer_rating') this.answerRating, @JsonKey(name: 'created_at') this.createdAt});
  factory _SurveyAnswerModel.fromJson(Map<String, dynamic> json) => _$SurveyAnswerModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'response_id') final  String responseId;
@override@JsonKey(name: 'question_id') final  String questionId;
@override@JsonKey(name: 'answer_text') final  String? answerText;
@override@JsonKey(name: 'answer_option') final  String? answerOption;
@override@JsonKey(name: 'answer_bool') final  bool? answerBool;
@override@JsonKey(name: 'answer_rating') final  int? answerRating;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of SurveyAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurveyAnswerModelCopyWith<_SurveyAnswerModel> get copyWith => __$SurveyAnswerModelCopyWithImpl<_SurveyAnswerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurveyAnswerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurveyAnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.responseId, responseId) || other.responseId == responseId)&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.answerText, answerText) || other.answerText == answerText)&&(identical(other.answerOption, answerOption) || other.answerOption == answerOption)&&(identical(other.answerBool, answerBool) || other.answerBool == answerBool)&&(identical(other.answerRating, answerRating) || other.answerRating == answerRating)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,responseId,questionId,answerText,answerOption,answerBool,answerRating,createdAt);

@override
String toString() {
  return 'SurveyAnswerModel(id: $id, responseId: $responseId, questionId: $questionId, answerText: $answerText, answerOption: $answerOption, answerBool: $answerBool, answerRating: $answerRating, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SurveyAnswerModelCopyWith<$Res> implements $SurveyAnswerModelCopyWith<$Res> {
  factory _$SurveyAnswerModelCopyWith(_SurveyAnswerModel value, $Res Function(_SurveyAnswerModel) _then) = __$SurveyAnswerModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'response_id') String responseId,@JsonKey(name: 'question_id') String questionId,@JsonKey(name: 'answer_text') String? answerText,@JsonKey(name: 'answer_option') String? answerOption,@JsonKey(name: 'answer_bool') bool? answerBool,@JsonKey(name: 'answer_rating') int? answerRating,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$SurveyAnswerModelCopyWithImpl<$Res>
    implements _$SurveyAnswerModelCopyWith<$Res> {
  __$SurveyAnswerModelCopyWithImpl(this._self, this._then);

  final _SurveyAnswerModel _self;
  final $Res Function(_SurveyAnswerModel) _then;

/// Create a copy of SurveyAnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? responseId = null,Object? questionId = null,Object? answerText = freezed,Object? answerOption = freezed,Object? answerBool = freezed,Object? answerRating = freezed,Object? createdAt = freezed,}) {
  return _then(_SurveyAnswerModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,responseId: null == responseId ? _self.responseId : responseId // ignore: cast_nullable_to_non_nullable
as String,questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,answerText: freezed == answerText ? _self.answerText : answerText // ignore: cast_nullable_to_non_nullable
as String?,answerOption: freezed == answerOption ? _self.answerOption : answerOption // ignore: cast_nullable_to_non_nullable
as String?,answerBool: freezed == answerBool ? _self.answerBool : answerBool // ignore: cast_nullable_to_non_nullable
as bool?,answerRating: freezed == answerRating ? _self.answerRating : answerRating // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
