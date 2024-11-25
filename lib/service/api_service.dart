
import '../core/constants.dart';

// class ApiService {
//   static final List<String> _videos = [
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
//     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
//
//   ];
//
//   /// Simulate api call
//   static Future<List<String>> getVideos({int id = 0}) async {
//     // No more videos
//     if ((id >= _videos.length)) {
//       return [];
//     }
//
//     await Future.delayed(const Duration(seconds: kLatency));
//
//     if ((id + kNextLimit >= _videos.length)) {
//       return _videos.sublist(id, _videos.length);
//     }
//
//     return _videos.sublist(id, id + kNextLimit);
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/VideoResponse.dart';

import 'dart:io';
import 'package:http/http.dart' as http;


class ApiService {
  static const String baseUrl = 'http://scancity.in/api/v1Demo/GetSampleApi';

  static Future<VideoResponse> getVideos({required int pageIndex, required int pageSize}) async {
    final String url = '$baseUrl?pageIndex=$pageIndex&pageSize=$pageSize';
       print('Response body: ${url}');

      final response = await http.get(Uri.parse(url));
      print('Response body: ${response.request}');


      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status']) {
          return VideoResponse.fromJson(jsonResponse); // Return the complete VideoResponse
        } else {
          throw Exception('Failed to load videos: ${jsonResponse['message']}');
        }
      } else {
        // Log the response body for debugging
        print('Response body:::: ${response.body}');
        throw Exception('Failed to load videos: HTTP status ${response.statusCode}');
      }
    }

}

