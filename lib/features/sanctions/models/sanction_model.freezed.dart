// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sanction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SanctionModel {

 String get id;@JsonKey(name: 'student_id') String get studentId;@JsonKey(name: 'scope_type') String get scopeType;@JsonKey(name: 'scope_id') String get scopeId;@JsonKey(name: 'academic_term_id') String get academicTermId;@JsonKey(name: 'total_absences') double get totalAbsences;@JsonKey(name: 'required_item') String get requiredItem; String get status;@JsonKey(name: 'received_by_user_id') String? get receivedByUserId;@JsonKey(name: 'received_at') DateTime? get receivedAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;// Join fields
@JsonKey(name: 'student_name') String? get studentName;@JsonKey(name: 'student_id_number') String? get studentIdNumber;@JsonKey(name: 'program_name') String? get programName;@JsonKey(name: 'year_level') int? get yearLevel;@JsonKey(name: 'received_by_name') String? get receivedByName;
/// Create a copy of SanctionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SanctionModelCopyWith<SanctionModel> get copyWith => _$SanctionModelCopyWithImpl<SanctionModel>(this as SanctionModel, _$identity);

  /// Serializes this SanctionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SanctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.totalAbsences, totalAbsences) || other.totalAbsences == totalAbsences)&&(identical(other.requiredItem, requiredItem) || other.requiredItem == requiredItem)&&(identical(other.status, status) || other.status == status)&&(identical(other.receivedByUserId, receivedByUserId) || other.receivedByUserId == receivedByUserId)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.receivedByName, receivedByName) || other.receivedByName == receivedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,scopeType,scopeId,academicTermId,totalAbsences,requiredItem,status,receivedByUserId,receivedAt,updatedAt,studentName,studentIdNumber,programName,yearLevel,receivedByName);

@override
String toString() {
  return 'SanctionModel(id: $id, studentId: $studentId, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, totalAbsences: $totalAbsences, requiredItem: $requiredItem, status: $status, receivedByUserId: $receivedByUserId, receivedAt: $receivedAt, updatedAt: $updatedAt, studentName: $studentName, studentIdNumber: $studentIdNumber, programName: $programName, yearLevel: $yearLevel, receivedByName: $receivedByName)';
}


}

/// @nodoc
abstract mixin class $SanctionModelCopyWith<$Res>  {
  factory $SanctionModelCopyWith(SanctionModel value, $Res Function(SanctionModel) _then) = _$SanctionModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'total_absences') double totalAbsences,@JsonKey(name: 'required_item') String requiredItem, String status,@JsonKey(name: 'received_by_user_id') String? receivedByUserId,@JsonKey(name: 'received_at') DateTime? receivedAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'student_name') String? studentName,@JsonKey(name: 'student_id_number') String? studentIdNumber,@JsonKey(name: 'program_name') String? programName,@JsonKey(name: 'year_level') int? yearLevel,@JsonKey(name: 'received_by_name') String? receivedByName
});




}
/// @nodoc
class _$SanctionModelCopyWithImpl<$Res>
    implements $SanctionModelCopyWith<$Res> {
  _$SanctionModelCopyWithImpl(this._self, this._then);

  final SanctionModel _self;
  final $Res Function(SanctionModel) _then;

/// Create a copy of SanctionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? totalAbsences = null,Object? requiredItem = null,Object? status = null,Object? receivedByUserId = freezed,Object? receivedAt = freezed,Object? updatedAt = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? programName = freezed,Object? yearLevel = freezed,Object? receivedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,totalAbsences: null == totalAbsences ? _self.totalAbsences : totalAbsences // ignore: cast_nullable_to_non_nullable
as double,requiredItem: null == requiredItem ? _self.requiredItem : requiredItem // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,receivedByUserId: freezed == receivedByUserId ? _self.receivedByUserId : receivedByUserId // ignore: cast_nullable_to_non_nullable
as String?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,receivedByName: freezed == receivedByName ? _self.receivedByName : receivedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SanctionModel].
extension SanctionModelPatterns on SanctionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SanctionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SanctionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SanctionModel value)  $default,){
final _that = this;
switch (_that) {
case _SanctionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SanctionModel value)?  $default,){
final _that = this;
switch (_that) {
case _SanctionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'total_absences')  double totalAbsences, @JsonKey(name: 'required_item')  String requiredItem,  String status, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(name: 'received_at')  DateTime? receivedAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'program_name')  String? programName, @JsonKey(name: 'year_level')  int? yearLevel, @JsonKey(name: 'received_by_name')  String? receivedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SanctionModel() when $default != null:
return $default(_that.id,_that.studentId,_that.scopeType,_that.scopeId,_that.academicTermId,_that.totalAbsences,_that.requiredItem,_that.status,_that.receivedByUserId,_that.receivedAt,_that.updatedAt,_that.studentName,_that.studentIdNumber,_that.programName,_that.yearLevel,_that.receivedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'total_absences')  double totalAbsences, @JsonKey(name: 'required_item')  String requiredItem,  String status, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(name: 'received_at')  DateTime? receivedAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'program_name')  String? programName, @JsonKey(name: 'year_level')  int? yearLevel, @JsonKey(name: 'received_by_name')  String? receivedByName)  $default,) {final _that = this;
switch (_that) {
case _SanctionModel():
return $default(_that.id,_that.studentId,_that.scopeType,_that.scopeId,_that.academicTermId,_that.totalAbsences,_that.requiredItem,_that.status,_that.receivedByUserId,_that.receivedAt,_that.updatedAt,_that.studentName,_that.studentIdNumber,_that.programName,_that.yearLevel,_that.receivedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'student_id')  String studentId, @JsonKey(name: 'scope_type')  String scopeType, @JsonKey(name: 'scope_id')  String scopeId, @JsonKey(name: 'academic_term_id')  String academicTermId, @JsonKey(name: 'total_absences')  double totalAbsences, @JsonKey(name: 'required_item')  String requiredItem,  String status, @JsonKey(name: 'received_by_user_id')  String? receivedByUserId, @JsonKey(name: 'received_at')  DateTime? receivedAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'student_name')  String? studentName, @JsonKey(name: 'student_id_number')  String? studentIdNumber, @JsonKey(name: 'program_name')  String? programName, @JsonKey(name: 'year_level')  int? yearLevel, @JsonKey(name: 'received_by_name')  String? receivedByName)?  $default,) {final _that = this;
switch (_that) {
case _SanctionModel() when $default != null:
return $default(_that.id,_that.studentId,_that.scopeType,_that.scopeId,_that.academicTermId,_that.totalAbsences,_that.requiredItem,_that.status,_that.receivedByUserId,_that.receivedAt,_that.updatedAt,_that.studentName,_that.studentIdNumber,_that.programName,_that.yearLevel,_that.receivedByName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SanctionModel implements SanctionModel {
  const _SanctionModel({required this.id, @JsonKey(name: 'student_id') required this.studentId, @JsonKey(name: 'scope_type') required this.scopeType, @JsonKey(name: 'scope_id') required this.scopeId, @JsonKey(name: 'academic_term_id') required this.academicTermId, @JsonKey(name: 'total_absences') required this.totalAbsences, @JsonKey(name: 'required_item') required this.requiredItem, this.status = 'Pending Item', @JsonKey(name: 'received_by_user_id') this.receivedByUserId, @JsonKey(name: 'received_at') this.receivedAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'student_name') this.studentName, @JsonKey(name: 'student_id_number') this.studentIdNumber, @JsonKey(name: 'program_name') this.programName, @JsonKey(name: 'year_level') this.yearLevel, @JsonKey(name: 'received_by_name') this.receivedByName});
  factory _SanctionModel.fromJson(Map<String, dynamic> json) => _$SanctionModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'student_id') final  String studentId;
@override@JsonKey(name: 'scope_type') final  String scopeType;
@override@JsonKey(name: 'scope_id') final  String scopeId;
@override@JsonKey(name: 'academic_term_id') final  String academicTermId;
@override@JsonKey(name: 'total_absences') final  double totalAbsences;
@override@JsonKey(name: 'required_item') final  String requiredItem;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'received_by_user_id') final  String? receivedByUserId;
@override@JsonKey(name: 'received_at') final  DateTime? receivedAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
// Join fields
@override@JsonKey(name: 'student_name') final  String? studentName;
@override@JsonKey(name: 'student_id_number') final  String? studentIdNumber;
@override@JsonKey(name: 'program_name') final  String? programName;
@override@JsonKey(name: 'year_level') final  int? yearLevel;
@override@JsonKey(name: 'received_by_name') final  String? receivedByName;

/// Create a copy of SanctionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SanctionModelCopyWith<_SanctionModel> get copyWith => __$SanctionModelCopyWithImpl<_SanctionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SanctionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SanctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.academicTermId, academicTermId) || other.academicTermId == academicTermId)&&(identical(other.totalAbsences, totalAbsences) || other.totalAbsences == totalAbsences)&&(identical(other.requiredItem, requiredItem) || other.requiredItem == requiredItem)&&(identical(other.status, status) || other.status == status)&&(identical(other.receivedByUserId, receivedByUserId) || other.receivedByUserId == receivedByUserId)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.studentName, studentName) || other.studentName == studentName)&&(identical(other.studentIdNumber, studentIdNumber) || other.studentIdNumber == studentIdNumber)&&(identical(other.programName, programName) || other.programName == programName)&&(identical(other.yearLevel, yearLevel) || other.yearLevel == yearLevel)&&(identical(other.receivedByName, receivedByName) || other.receivedByName == receivedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,scopeType,scopeId,academicTermId,totalAbsences,requiredItem,status,receivedByUserId,receivedAt,updatedAt,studentName,studentIdNumber,programName,yearLevel,receivedByName);

@override
String toString() {
  return 'SanctionModel(id: $id, studentId: $studentId, scopeType: $scopeType, scopeId: $scopeId, academicTermId: $academicTermId, totalAbsences: $totalAbsences, requiredItem: $requiredItem, status: $status, receivedByUserId: $receivedByUserId, receivedAt: $receivedAt, updatedAt: $updatedAt, studentName: $studentName, studentIdNumber: $studentIdNumber, programName: $programName, yearLevel: $yearLevel, receivedByName: $receivedByName)';
}


}

/// @nodoc
abstract mixin class _$SanctionModelCopyWith<$Res> implements $SanctionModelCopyWith<$Res> {
  factory _$SanctionModelCopyWith(_SanctionModel value, $Res Function(_SanctionModel) _then) = __$SanctionModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'student_id') String studentId,@JsonKey(name: 'scope_type') String scopeType,@JsonKey(name: 'scope_id') String scopeId,@JsonKey(name: 'academic_term_id') String academicTermId,@JsonKey(name: 'total_absences') double totalAbsences,@JsonKey(name: 'required_item') String requiredItem, String status,@JsonKey(name: 'received_by_user_id') String? receivedByUserId,@JsonKey(name: 'received_at') DateTime? receivedAt,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'student_name') String? studentName,@JsonKey(name: 'student_id_number') String? studentIdNumber,@JsonKey(name: 'program_name') String? programName,@JsonKey(name: 'year_level') int? yearLevel,@JsonKey(name: 'received_by_name') String? receivedByName
});




}
/// @nodoc
class __$SanctionModelCopyWithImpl<$Res>
    implements _$SanctionModelCopyWith<$Res> {
  __$SanctionModelCopyWithImpl(this._self, this._then);

  final _SanctionModel _self;
  final $Res Function(_SanctionModel) _then;

/// Create a copy of SanctionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? scopeType = null,Object? scopeId = null,Object? academicTermId = null,Object? totalAbsences = null,Object? requiredItem = null,Object? status = null,Object? receivedByUserId = freezed,Object? receivedAt = freezed,Object? updatedAt = freezed,Object? studentName = freezed,Object? studentIdNumber = freezed,Object? programName = freezed,Object? yearLevel = freezed,Object? receivedByName = freezed,}) {
  return _then(_SanctionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as String,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,academicTermId: null == academicTermId ? _self.academicTermId : academicTermId // ignore: cast_nullable_to_non_nullable
as String,totalAbsences: null == totalAbsences ? _self.totalAbsences : totalAbsences // ignore: cast_nullable_to_non_nullable
as double,requiredItem: null == requiredItem ? _self.requiredItem : requiredItem // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,receivedByUserId: freezed == receivedByUserId ? _self.receivedByUserId : receivedByUserId // ignore: cast_nullable_to_non_nullable
as String?,receivedAt: freezed == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,studentName: freezed == studentName ? _self.studentName : studentName // ignore: cast_nullable_to_non_nullable
as String?,studentIdNumber: freezed == studentIdNumber ? _self.studentIdNumber : studentIdNumber // ignore: cast_nullable_to_non_nullable
as String?,programName: freezed == programName ? _self.programName : programName // ignore: cast_nullable_to_non_nullable
as String?,yearLevel: freezed == yearLevel ? _self.yearLevel : yearLevel // ignore: cast_nullable_to_non_nullable
as int?,receivedByName: freezed == receivedByName ? _self.receivedByName : receivedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
