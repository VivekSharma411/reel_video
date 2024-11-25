import 'dart:convert';
/// statusCode : 200
/// status : true
/// message : "success"
/// responseTime : "1 ms"
/// pageIndex : 1
/// pageSize : 10
/// data : [{"id":1,"title":"Video Title 1","description":"Video Description 1","videoUrl":"http://scancity.in/uploads/1b89c607-a76c-4887-a087-fd9e19bdd13c.mp4"},{"id":2,"title":"Video Title 2","description":"Video Description 2","videoUrl":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"},{"id":3,"title":"Video Title 3","description":"Video Description 3","videoUrl":"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"},{"id":4,"title":"Video Title 4","description":"Video Description 4","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-mother-with-her-little-daughter-eating-a-marshmallow-in-nature-39764-large.mp4"},{"id":5,"title":"Video Title 5","description":"Video Description 5","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-taking-photos-from-different-angles-of-a-model-34421-large.mp4"},{"id":6,"title":"Video Title 6","description":"Video Description 6","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-girl-in-neon-sign-1232-large.mp4"},{"id":7,"title":"Video Title 7","description":"Video Description 7","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-winter-fashion-cold-looking-woman-concept-video-39874-large.mp4"},{"id":8,"title":"Video Title 8","description":"Video Description 8","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-womans-feet-splashing-in-the-pool-1261-large.mp4"},{"id":9,"title":"Video Title 9","description":"Video Description 9","videoUrl":"https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"},{"id":10,"title":"Video Title 10","description":"Video Description 10","videoUrl":"https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4"}]

VideoResponse videoResponseFromJson(String str) => VideoResponse.fromJson(json.decode(str));
String videoResponseToJson(VideoResponse data) => json.encode(data.toJson());
class VideoResponse {
  VideoResponse({
      num? statusCode, 
      bool? status, 
      String? message, 
      String? responseTime, 
      num? pageIndex, 
      num? pageSize, 
      List<Data>? data,}){
    _statusCode = statusCode;
    _status = status;
    _message = message;
    _responseTime = responseTime;
    _pageIndex = pageIndex;
    _pageSize = pageSize;
    _data = data;
}

  VideoResponse.fromJson(dynamic json) {
    _statusCode = json['statusCode'];
    _status = json['status'];
    _message = json['message'];
    _responseTime = json['responseTime'];
    _pageIndex = json['pageIndex'];
    _pageSize = json['pageSize'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  num? _statusCode;
  bool? _status;
  String? _message;
  String? _responseTime;
  num? _pageIndex;
  num? _pageSize;
  List<Data>? _data;
VideoResponse copyWith({  num? statusCode,
  bool? status,
  String? message,
  String? responseTime,
  num? pageIndex,
  num? pageSize,
  List<Data>? data,
}) => VideoResponse(  statusCode: statusCode ?? _statusCode,
  status: status ?? _status,
  message: message ?? _message,
  responseTime: responseTime ?? _responseTime,
  pageIndex: pageIndex ?? _pageIndex,
  pageSize: pageSize ?? _pageSize,
  data: data ?? _data,
);
  num? get statusCode => _statusCode;
  bool? get status => _status;
  String? get message => _message;
  String? get responseTime => _responseTime;
  num? get pageIndex => _pageIndex;
  num? get pageSize => _pageSize;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['statusCode'] = _statusCode;
    map['status'] = _status;
    map['message'] = _message;
    map['responseTime'] = _responseTime;
    map['pageIndex'] = _pageIndex;
    map['pageSize'] = _pageSize;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 1
/// title : "Video Title 1"
/// description : "Video Description 1"
/// videoUrl : "http://scancity.in/uploads/1b89c607-a76c-4887-a087-fd9e19bdd13c.mp4"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      num? id, 
      String? title, 
      String? description, 
      String? videoUrl,}){
    _id = id;
    _title = title;
    _description = description;
    _videoUrl = videoUrl;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _videoUrl = json['videoUrl'];
  }
  num? _id;
  String? _title;
  String? _description;
  String? _videoUrl;
Data copyWith({  num? id,
  String? title,
  String? description,
  String? videoUrl,
}) => Data(  id: id ?? _id,
  title: title ?? _title,
  description: description ?? _description,
  videoUrl: videoUrl ?? _videoUrl,
);
  num? get id => _id;
  String? get title => _title;
  String? get description => _description;
  String? get videoUrl => _videoUrl;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['videoUrl'] = _videoUrl;
    return map;
  }

}