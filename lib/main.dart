import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:untitled/pages/profile_screen.dart';
import 'package:untitled/pages/search_screen.dart';
import 'package:untitled/pages/setting_screen.dart';
import 'package:untitled/service/navigation_service.dart';
import 'package:untitled/video_page.dart';

import 'core/constants.dart';
import 'http/MyHttpOverrides.dart';
import 'model/VideoResponse.dart';
import 'service/api_service.dart';
import 'bloc/preload_bloc.dart';
import 'core/build_context.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides(); // Set the global HTTP overrides

  configureInjection(Environment.prod);
  runApp(MyApp());
}

/// Isolate to fetch videos in the background so that the video experience is not disturbed.
/// Without isolate, the video will be paused whenever there is an API call
/// because the main thread will be busy fetching new video URLs.
///
/// https://blog.codemagic.io/understanding-flutter-isolates/
Future createIsolate(int index) async {
  // Set loading to true
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.setLoading());

  ReceivePort mainReceivePort = ReceivePort();

  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final _urls = isolateResponse;

  // Update new urls
  BlocProvider.of<PreloadBloc>(context, listen: false)
      .add(PreloadEvent.updateUrls(_urls));
}

void getVideosTask(SendPort mySendPort) async {
  final receivePort = ReceivePort();

  // Send the port to the main isolate
  mySendPort.send(receivePort.sendPort);

  await for (var message in receivePort) {
    if (message is List) {
      final int index = message[0]; // Get the index from the message
      final SendPort isolateResponseSendPort = message[1]; // Get the SendPort for responses

      try {
        // Calculate page index
        final int pageIndex = (index ~/ 10) + 1;

        // Fetch videos with the correct parameters
        final VideoResponse videoResponse = await ApiService.getVideos(pageIndex: pageIndex, pageSize: 10);

        print("PageIndex ${pageIndex}");

        // Extract URLs and ensure they're non-null
        final List<String> urls = videoResponse.data
            ?.map((video) => video.videoUrl)
            .where((url) => url != null)
            .cast<String>()
            .toList() ?? [];

        // Send the URLs back to the main isolate
        isolateResponseSendPort.send(urls);
      } catch (e) {
        // Handle any exceptions
        isolateResponseSendPort.send([]);
      }
    }
  }
}


class MyApp extends StatelessWidget {
  final NavigationService _navigationService = getIt<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PreloadBloc>()..add(PreloadEvent.getVideosFromApi()),
      child: MaterialApp(
        key: _navigationService.navigationKey,
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    VideoPage(),
    SearchScreen(),
    ProfileScreen(),
    SettingScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(canvasColor: Colors.black),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.grey[100],
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}


// class ReelsPagination extends StatefulWidget {
//   const ReelsPagination({super.key});
//
//   @override
//   _ReelsPaginationState createState() => _ReelsPaginationState();
// }
//
// class _ReelsPaginationState extends State<ReelsPagination> {
//   List<String> videos = List.generate(999, (index) => 'https://example.com/video$index.mp4');
//   List<VideoPlayerController> controllers = [];
//   int currentPage = 0;
//   final int pageSize = 10;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadVideos();
//   }
//
//   Future<void> _loadVideos() async {
//     if (isLoading) return;
//     isLoading = true;
//
//     // Create an isolate to load videos
//     await FlutterIsolate.spawn(_videoLoader, videos.skip(currentPage * pageSize).take(pageSize).toList());
//   }
//
//   static Future<void> _videoLoader(List<String> videoUrls) async {
//     for (var url in videoUrls) {
//       final controller = VideoPlayerController.network(url);
//       await controller.initialize();
//       // Optionally cache the controller if needed
//     }
//   }
//
//   void _onScroll() {
//     if (currentPage < (videos.length / pageSize).ceil() - 1) {
//       currentPage++;
//       _loadVideos();
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Reels'),
//       ),
//       body: NotificationListener<ScrollNotification>(
//         onNotification: (ScrollNotification scrollInfo) {
//           if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//             _onScroll();
//           }
//           return true;
//         },
//         child: ListView.builder(
//           itemCount: (currentPage + 1) * pageSize > videos.length ? videos.length : (currentPage + 1) * pageSize,
//           itemBuilder: (context, index) {
//             final videoUrl = videos[index];
//             final controller = VideoPlayerController.network(videoUrl);
//             controllers.add(controller);
//             controller.initialize();
//             controller.setLooping(true);
//             controller.play();
//
//             return Container(
//               margin: EdgeInsets.all(8),
//               child: AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: VideoPlayer(controller),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     for (var controller in controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
// }
