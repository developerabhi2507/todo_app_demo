import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class Todo {
  int? columnId;
  String? columnText;
  String? columnAudio;
  String? columnVideo;
  String? columnImage;
  String? columnPdf;
  String? columnDoc;
  String? columnGeolocation;
  String? columnTime;

  Todo({
    this.columnId,
    this.columnText,
    this.columnAudio,
    this.columnVideo,
    this.columnImage,
    this.columnPdf,
    this.columnDoc,
    this.columnGeolocation,
    this.columnTime,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'text': columnText,
      'audio': columnAudio,
      'video': columnVideo,
      'image': columnImage,
      'pdf': columnPdf,
      'doc': columnDoc,
      'geolocation': columnGeolocation,
      'time': columnTime.toString(),
    };
    if (columnId != null) {
      map['_id'] = columnId;
    }
    return map;
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      columnId: map['id'],
      columnText: map['text'],
      columnAudio: map['audio'],
      columnVideo: map['video'],
      columnImage: map['image'],
      columnPdf: map['pdf'],
      columnDoc: map['doc'],
      columnGeolocation: map['geolocation'],
      columnTime: map[DateFormat.yMMMEd().format(DateTime.parse('time'))],
      // DateFormat.yMMMEd().format(DateTime.parse('time')))
    );
  }

  // void setDateTime() {
  //   time = DateTime.now();
  // }
}
