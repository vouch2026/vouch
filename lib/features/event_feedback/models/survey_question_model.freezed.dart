// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey_question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SurveyQuestionModel {

 String? get id;@JsonKey(name: 'survey_id') String get surveyId;@JsonKey(name: 'question_text') String get questionText;@JsonKey(name: 'question_type') String get questionType; List<String> get options;@JsonKey(name: 'is_required') bool get isRequired;@JsonKey(name: 'sort_order') int get sortOrder;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of SurveyQuestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SurveyQuestionModelCopyWith<SurveyQuestionModel> get copyWith => _$SurveyQuestionModelCopyWithImpl<SurveyQuestionModel>(this as SurveyQuestionModel, _$identity);

  /// Serializes this SurveyQuestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SurveyQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.questionText, questionText) || other.questionText == questionText)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,questionText,questionType,const DeepCollectionEquality().hash(options),isRequired,sortOrder,createdAt);

@override
String toString() {
  return 'SurveyQuestionModel(id: $id, surveyId: $surveyId, questionText: $questionText, questionType: $questionType, options: $options, isRequired: $isRequired, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SurveyQuestionModelCopyWith<$Res>  {
  factory $SurveyQuestionModelCopyWith(SurveyQuestionModel value, $Res Function(SurveyQuestionModel) _then) = _$SurveyQuestionModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'survey_id') String surveyId,@JsonKey(name: 'question_text') String questionText,@JsonKey(name: 'question_type') String questionType, List<String> options,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$SurveyQuestionModelCopyWithImpl<$Res>
    implements $SurveyQuestionModelCopyWith<$Res> {
  _$SurveyQuestionModelCopyWithImpl(this._self, this._then);

  final SurveyQuestionModel _self;
  final $Res Function(SurveyQuestionModel) _then;

/// Create a copy of SurveyQuestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? surveyId = null,Object? questionText = null,Object? questionType = null,Object? options = null,Object? isRequired = null,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,questionText: null == questionText ? _self.questionText : questionText // ignore: cast_nullable_to_non_nullable
as String,questionType: null == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<String>,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SurveyQuestionModel].
extension SurveyQuestionModelPatterns on SurveyQuestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SurveyQuestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SurveyQuestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SurveyQuestionModel value)  $default,){
final _that = this;
switch (_that) {
case _SurveyQuestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SurveyQuestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SurveyQuestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'survey_id')  String surveyId, @JsonKey(name: 'question_text')  String questionText, @JsonKey(name: 'question_type')  String questionType,  List<String> options, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SurveyQuestionModel() when $default != null:
return $default(_that.id,_that.surveyId,_that.questionText,_that.questionType,_that.options,_that.isRequired,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'survey_id')  String surveyId, @JsonKey(name: 'question_text')  String questionText, @JsonKey(name: 'question_type')  String questionType,  List<String> options, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _SurveyQuestionModel():
return $default(_that.id,_that.surveyId,_that.questionText,_that.questionType,_that.options,_that.isRequired,_that.sortOrder,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'survey_id')  String surveyId, @JsonKey(name: 'question_text')  String questionText, @JsonKey(name: 'question_type')  String questionType,  List<String> options, @JsonKey(name: 'is_required')  bool isRequired, @JsonKey(name: 'sort_order')  int sortOrder, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SurveyQuestionModel() when $default != null:
return $default(_that.id,_that.surveyId,_that.questionText,_that.questionType,_that.options,_that.isRequired,_that.sortOrder,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SurveyQuestionModel implements SurveyQuestionModel {
  const _SurveyQuestionModel({this.id, @JsonKey(name: 'survey_id') required this.surveyId, @JsonKey(name: 'question_text') required this.questionText, @JsonKey(name: 'question_type') required this.questionType, final  List<String> options = const [], @JsonKey(name: 'is_required') this.isRequired = true, @JsonKey(name: 'sort_order') this.sortOrder = 0, @JsonKey(name: 'created_at') this.createdAt}): _options = options;
  factory _SurveyQuestionModel.fromJson(Map<String, dynamic> json) => _$SurveyQuestionModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'survey_id') final  String surveyId;
@override@JsonKey(name: 'question_text') final  String questionText;
@override@JsonKey(name: 'question_type') final  String questionType;
 final  List<String> _options;
@override@JsonKey() List<String> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override@JsonKey(name: 'is_required') final  bool isRequired;
@override@JsonKey(name: 'sort_order') final  int sortOrder;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of SurveyQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SurveyQuestionModelCopyWith<_SurveyQuestionModel> get copyWith => __$SurveyQuestionModelCopyWithImpl<_SurveyQuestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SurveyQuestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SurveyQuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.questionText, questionText) || other.questionText == questionText)&&(identical(other.questionType, questionType) || other.questionType == questionType)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,questionText,questionType,const DeepCollectionEquality().hash(_options),isRequired,sortOrder,createdAt);

@override
String toString() {
  return 'SurveyQuestionModel(id: $id, surveyId: $surveyId, questionText: $questionText, questionType: $questionType, options: $options, isRequired: $isRequired, sortOrder: $sortOrder, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SurveyQuestionModelCopyWith<$Res> implements $SurveyQuestionModelCopyWith<$Res> {
  factory _$SurveyQuestionModelCopyWith(_SurveyQuestionModel value, $Res Function(_SurveyQuestionModel) _then) = __$SurveyQuestionModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'survey_id') String surveyId,@JsonKey(name: 'question_text') String questionText,@JsonKey(name: 'question_type') String questionType, List<String> options,@JsonKey(name: 'is_required') bool isRequired,@JsonKey(name: 'sort_order') int sortOrder,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$SurveyQuestionModelCopyWithImpl<$Res>
    implements _$SurveyQuestionModelCopyWith<$Res> {
  __$SurveyQuestionModelCopyWithImpl(this._self, this._then);

  final _SurveyQuestionModel _self;
  final $Res Function(_SurveyQuestionModel) _then;

/// Create a copy of SurveyQuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? surveyId = null,Object? questionText = null,Object? questionType = null,Object? options = null,Object? isRequired = null,Object? sortOrder = null,Object? createdAt = freezed,}) {
  return _then(_SurveyQuestionModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,questionText: null == questionText ? _self.questionText : questionText // ignore: cast_nullable_to_non_nullable
as String,questionType: null == questionType ? _self.questionType : questionType // ignore: cast_nullable_to_non_nullable
as String,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<String>,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
