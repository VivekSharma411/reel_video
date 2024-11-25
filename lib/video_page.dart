import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'bloc/preload_bloc.dart';

class VideoPage extends StatelessWidget {
  const VideoPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<PreloadBloc, PreloadState>(
        builder: (context, state) {

          print(state.urls.length);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Video Player'), // AppBar title
              backgroundColor: Colors.redAccent, // Optional: Customize AppBar color
            ),
            body: Container(
              color: Colors.black,
              child: PageView.builder(
                itemCount: state.urls.length,
                scrollDirection: Axis.vertical,
                onPageChanged: (index)  {


                  BlocProvider.of<PreloadBloc>(context, listen: false)
                      .add(PreloadEvent.onVideoIndexChanged(index));
                },
                itemBuilder: (context, index) {
                  // Is at end and isLoading
                  final bool isLoading = (state.isLoading && index == state.urls.length -1);


                  return state.focusedIndex == index
                      ? VideoWidget(
                    isLoading: isLoading,
                    controller: state.controllers[index]!,
                    title: 'Video Title ${index + 1}', // Add title here
                  )
                      : const SizedBox();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  const VideoWidget({
    super.key,
    required this.isLoading,
    required this.controller,
    required this.title,
  });

  final bool isLoading;
  final VideoPlayerController controller;
  final String title;

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  Duration _videoLength = Duration.zero;

  bool _isLiked = false;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_updateVideoLength);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateVideoLength);
    super.dispose();
  }

  void _updateVideoLength() {
    if (_controller.value.isInitialized) {
      setState(() {
        _videoLength = _controller.value.duration;
      });
    }
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: (value * _videoLength.inMilliseconds).toInt());
    _controller.seekTo(position);
  }
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        Positioned.fill(child: AspectRatio(aspectRatio: 9/16,
        child: VideoPlayer(_controller))),

        Positioned(
          left: 15,
          bottom: 50,
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Positioned(
          bottom: 10, // Position the seek bar above the bottom
          left: 0,
          right: 0,
          child: Column(
            children: [
              if (_videoLength != Duration.zero) // Check if video length is initialized
                Slider(
                  value: _controller.value.position.inMilliseconds.toDouble(),
                  min: 0.0,
                  max: _videoLength.inMilliseconds.toDouble(),
                  activeColor: Colors.red, // Set active color to red
                  onChanged: (value) {
                    setState(() {
                      _seekTo(value / _videoLength.inMilliseconds.toDouble());
                    });
                  },
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          right: 15, // Position the icons on the right side
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.thumb_up,
                color: _isFavorited ? Colors.blue : Colors.white,),
                onPressed: () {
                  _toggleFavorite();
                },
              ),
              IconButton(
                icon:  Icon(Icons.favorite, color: _isLiked ? Colors.red:Colors.white),
                onPressed: () {
                  _toggleLike();
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {

                },
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: () {

                },
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: AnimatedCrossFade(
              alignment: Alignment.bottomCenter,
              sizeCurve: Curves.decelerate,
              duration: const Duration(milliseconds: 400),
              firstChild: const Padding(
                padding: EdgeInsets.all(10.0),
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 15,
                ),
              ),
              secondChild: const SizedBox(),
              crossFadeState: widget.isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            ),
          ),
        ),
      ],
    );
  }
}


