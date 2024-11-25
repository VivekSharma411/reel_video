import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

import '../core/constants.dart';
import '../main.dart';
import '../model/VideoResponse.dart';
import '../service/api_service.dart';

part 'preload_bloc.freezed.dart';
part 'preload_event.dart';
part 'preload_state.dart';

@injectable
@prod
class PreloadBloc extends Bloc<PreloadEvent, PreloadState> {
  int _pageIndex = 1; // Start from page 1

  PreloadBloc() : super(PreloadState.initial()) {
    on(_mapEventToState);
  }

  void _mapEventToState(PreloadEvent event, Emitter<PreloadState> emit) async {
    await event.map(
      setLoading: (e) {
        emit(state.copyWith(isLoading: true));
      },
      getVideosFromApi: (e) async {
        // Fetch videos
        final VideoResponse videoResponse =
        await ApiService.getVideos(pageIndex: _pageIndex, pageSize: 10);
        print("PageIndex $_pageIndex");

        // Handle null data
        if (videoResponse.data?.length == null ) {
          emit(state.copyWith(isLoading: true)); // Stop loading if no data
          return;
        }

        // Extract and filter URLs
        final List<String> urls = videoResponse.data
            ?.map((video) => video.videoUrl)
            .where((url) => url != null)
            .cast<String>()
            .toList() ?? [];

        state.urls.addAll(urls);
        _pageIndex++; // Increment page index

        // Initialize and play videos
        await _initializeControllerAtIndex(0);
        _playControllerAtIndex(0);
        if (state.urls.length > 1) {
          await _initializeControllerAtIndex(1);
        }

        emit(state.copyWith(
          reloadCounter: state.reloadCounter + 1,
          isLoading: false,
        ));
      },
      onVideoIndexChanged: (e) {
        // Check if we need to fetch new videos
        if ((e.index + 1) % 10 == 0 && state.urls.length == e.index + 1) {
          emit(state.copyWith(isLoading: true));
          createIsolate(e.index); // Create isolate to fetch new videos
        }

        // Play the next or previous video
        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        emit(state.copyWith(focusedIndex: e.index));
      },
      updateUrls: (e) {
        state.urls.addAll(e.urls);
        _initializeControllerAtIndex(state.focusedIndex + 1);
        emit(state.copyWith(
          reloadCounter: state.reloadCounter + 1,
          isLoading: false,
        ));
        log('🚀🚀🚀 NEW VIDEOS ADDED');
      },
    );
  }

  void _playNext(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);

    /// Dispose [index - 2] controller
    _disposeControllerAtIndex(index - 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    _playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
  }

  Future _initializeControllerAtIndex(int index) async {
    if (state.urls.length > index && index >= 0) {
      /// Create new controller
      final VideoPlayerController _controller =
          VideoPlayerController.network(state.urls[index]);

      /// Add to [controllers] list
      state.controllers[index] = _controller;

      /// Initialize
      await _controller.initialize();

      log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController _controller = state.controllers[index]!;

      /// Play controller
      _controller.play();

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController _controller = state.controllers[index]!;

      /// Pause
      _controller.pause();

      /// Reset postiton to beginning
      _controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      /// Get controller at [index]
      final VideoPlayerController? _controller = state.controllers[index];

      /// Dispose controller
      _controller?.dispose();

      if (_controller != null) {
        state.controllers.remove(_controller);
      }

      log('🚀🚀🚀 DISPOSED $index');
    }
  }
}
