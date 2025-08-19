import 'dart:async';
import 'package:just_audio/just_audio.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  AudioPlayer? _currentPlayer;
  String? _currentAudioId;
  StreamController<String?>? _audioStateController;
  bool _isDisposed = false;

  Stream<String?> get audioStateStream {
    try {
      _audioStateController ??= StreamController<String?>.broadcast();
      return _audioStateController!.stream;
    } catch (e) {
      print('Error getting audio state stream: $e');
      return Stream.value(null);
    }
  }

  /// Play audio and stop any currently playing audio
  Future<void> playAudio(String audioId, AudioPlayer player) async {
    try {
      if (_isDisposed) return;

      // Stop current audio if different
      if (_currentAudioId != null && _currentAudioId != audioId) {
        await stopCurrentAudio();
      }

      // Set new current audio
      _currentPlayer = player;
      _currentAudioId = audioId;

      if (_audioStateController != null && !_audioStateController!.isClosed) {
        _audioStateController!.add(audioId);
      }

      await player.play();
    } catch (e) {
      print('Error playing audio: $e');
      // Reset state on error
      _currentPlayer = null;
      _currentAudioId = null;
      if (_audioStateController != null && !_audioStateController!.isClosed) {
        _audioStateController!.add(null);
      }
    }
  }

  /// Stop current audio
  Future<void> stopCurrentAudio() async {
    try {
      if (_currentPlayer != null) {
        try {
          await _currentPlayer!.stop();
        } catch (e) {
          print('Error stopping audio: $e');
        }
        _currentPlayer = null;
        _currentAudioId = null;
        if (_audioStateController != null && !_audioStateController!.isClosed) {
          _audioStateController!.add(null);
        }
      }
    } catch (e) {
      print('Error in stopCurrentAudio: $e');
    }
  }

  /// Pause current audio
  Future<void> pauseCurrentAudio() async {
    try {
      if (_currentPlayer != null) {
        try {
          await _currentPlayer!.pause();
        } catch (e) {
          print('Error pausing audio: $e');
        }
      }
    } catch (e) {
      print('Error in pauseCurrentAudio: $e');
    }
  }

  /// Check if specific audio is currently playing
  bool isAudioPlaying(String audioId) {
    try {
      return _currentAudioId == audioId && _currentPlayer?.playing == true;
    } catch (e) {
      print('Error checking if audio is playing: $e');
      return false;
    }
  }

  /// Get current playing audio ID
  String? get currentAudioId {
    try {
      return _currentAudioId;
    } catch (e) {
      print('Error getting current audio ID: $e');
      return null;
    }
  }

  /// Get current player
  AudioPlayer? get currentPlayer {
    try {
      return _currentPlayer;
    } catch (e) {
      print('Error getting current player: $e');
      return null;
    }
  }

  /// Check if audio manager has any active player
  bool get hasActivePlayer {
    try {
      return _currentPlayer != null;
    } catch (e) {
      print('Error checking if has active player: $e');
      return false;
    }
  }

  /// Dispose the manager
  void dispose() {
    try {
      _isDisposed = true;
      stopCurrentAudio();
      _audioStateController?.close();
      _audioStateController = null;
    } catch (e) {
      print('Error in dispose: $e');
    }
  }
}
