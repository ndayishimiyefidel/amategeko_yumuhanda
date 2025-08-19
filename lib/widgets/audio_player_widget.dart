import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/constants.dart';
import '../services/audio_manager.dart';

class ModernAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String audioTitle;
  final String lessonId;
  final String userId;
  final VoidCallback? onAudioStarted;
  final VoidCallback? onAudioStopped;

  const ModernAudioPlayer({
    Key? key,
    required this.audioUrl,
    required this.audioTitle,
    required this.lessonId,
    required this.userId,
    this.onAudioStarted,
    this.onAudioStopped,
  }) : super(key: key);

  @override
  State<ModernAudioPlayer> createState() => _ModernAudioPlayerState();
}

class _ModernAudioPlayerState extends State<ModernAudioPlayer> {
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<String?>? _audioStateSubscription;
  bool _isLoading = false;
  String _errorMessage = '';
  final AudioManager _audioManager = AudioManager();
  late String _audioId;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    try {
      _audioId =
          '${DateTime.now().millisecondsSinceEpoch}_${widget.audioUrl.hashCode}';
      _initializeAudioPlayer();
      _listenToAudioState();
    } catch (e) {
      print('Error in initState: $e');
      _errorMessage = 'Failed to initialize audio player';
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      if (_isDisposed) return;

      _audioPlayer = AudioPlayer();

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Set up the audio source
      await _audioPlayer?.setUrl(widget.audioUrl);

      // Listen to player state changes
      _playerStateSubscription =
          _audioPlayer?.playerStateStream.listen((state) {
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      });

      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing audio player: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load audio: $e';
        });
      }
    }
  }

  void _listenToAudioState() {
    try {
      _audioStateSubscription =
          _audioManager.audioStateStream.listen((playingAudioId) {
        if (mounted && !_isDisposed) {
          setState(() {});
        }
      });
    } catch (e) {
      print('Error listening to audio state: $e');
    }
  }

  Future<void> _playAudio() async {
    try {
      if (_isDisposed || !mounted || _audioPlayer == null) return;

      // Use the global audio manager to ensure only one audio plays at a time
      await _audioManager.playAudio(_audioId, _audioPlayer!);

      // Check if widget is still mounted before calling callback
      if (mounted && !_isDisposed) {
        widget.onAudioStarted?.call();
      }
    } catch (e) {
      print('Error playing audio: $e');
      // Only show error if widget is still mounted
      if (mounted && !_isDisposed) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e')),
          );
        } catch (snackError) {
          print('Error showing snackbar: $snackError');
        }
      }
    }
  }

  Future<void> _pauseAudio() async {
    try {
      if (_audioPlayer == null) return;
      await _audioPlayer!.pause();
    } catch (e) {
      print('Error pausing audio: $e');
      if (mounted && !_isDisposed) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error pausing audio: $e')),
          );
        } catch (snackError) {
          print('Error showing snackbar: $snackError');
        }
      }
    }
  }

  Future<void> _stopAudio() async {
    try {
      if (_audioPlayer == null) return;

      await _audioPlayer!.stop();
      if (_audioManager.currentAudioId == _audioId) {
        _audioManager.stopCurrentAudio();
      }
      if (mounted && !_isDisposed) {
        widget.onAudioStopped?.call();
      }
    } catch (e) {
      print('Error stopping audio: $e');
      if (mounted && !_isDisposed) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error stopping audio: $e')),
          );
        } catch (snackError) {
          print('Error showing snackbar: $snackError');
        }
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      if (_audioPlayer == null) return;
      await _audioPlayer!.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
      if (mounted && !_isDisposed) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error seeking audio: $e')),
          );
        } catch (snackError) {
          print('Error showing snackbar: $snackError');
        }
      }
    }
  }

  String _formatDuration(Duration? duration) {
    try {
      if (duration == null) return '--:--';
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error formatting duration: $e');
      return '--:--';
    }
  }

  bool get _isCurrentlyPlaying {
    try {
      return _audioManager.isAudioPlaying(_audioId);
    } catch (e) {
      print('Error checking if audio is playing: $e');
      return false;
    }
  }

  @override
  void dispose() {
    try {
      _isDisposed = true;

      // Cancel all subscriptions first
      _playerStateSubscription?.cancel();
      _audioStateSubscription?.cancel();

      // Stop this audio if it's currently playing
      if (_audioManager.currentAudioId == _audioId) {
        _audioManager.stopCurrentAudio();
      }

      // Dispose the audio player
      _audioPlayer?.dispose();
      _audioPlayer = null;

      super.dispose();
    } catch (e) {
      print('Error in dispose: $e');
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_isDisposed) {
        return const SizedBox.shrink();
      }

      if (_isLoading) {
        return _buildLoadingCard();
      }

      if (_errorMessage.isNotEmpty) {
        return _buildErrorCard();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withValues(alpha: 0.1),
              kPrimaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: kPrimaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and controls
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.audiotrack,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.audioTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Audio File',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Control buttons
                  _buildControlButtons(),
                ],
              ),
              const SizedBox(height: 20),

              // Progress bar
              _buildProgressBar(),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error in build method: $e');
      return _buildErrorCard();
    }
  }

  Widget _buildProgressBar() {
    try {
      if (_audioPlayer == null) {
        return const SizedBox.shrink();
      }

      return StreamBuilder<Duration?>(
        stream: _audioPlayer!.durationStream,
        builder: (context, snapshot) {
          try {
            final duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: _audioPlayer!.positionStream,
              builder: (context, snapshot) {
                try {
                  final position = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: duration.inMilliseconds > 0
                            ? (position.inMilliseconds /
                                    duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                        onChanged: (value) {
                          try {
                            final newPosition = Duration(
                              milliseconds:
                                  (value * duration.inMilliseconds).round(),
                            );
                            _seekTo(newPosition);
                          } catch (e) {
                            print('Error in slider onChanged: $e');
                          }
                        },
                        activeColor: kPrimaryColor,
                        inactiveColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } catch (e) {
                  print('Error in position stream builder: $e');
                  return const SizedBox.shrink();
                }
              },
            );
          } catch (e) {
            print('Error in duration stream builder: $e');
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e) {
      print('Error building progress bar: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildControlButtons() {
    try {
      final isPlaying = _isCurrentlyPlaying;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          Container(
            decoration: BoxDecoration(
              color: kPrimaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                try {
                  if (isPlaying) {
                    _pauseAudio();
                  } else {
                    _playAudio();
                  }
                } catch (e) {
                  print('Error in play/pause button: $e');
                }
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
              iconSize: 24,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 12),

          // Stop button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                try {
                  _stopAudio();
                } catch (e) {
                  print('Error in stop button: $e');
                }
              },
              icon: Icon(
                Icons.stop,
                color: Colors.grey[700],
                size: 20,
              ),
              iconSize: 20,
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      );
    } catch (e) {
      print('Error building control buttons: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildLoadingCard() {
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.audiotrack,
                color: Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.audioTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building loading card: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildErrorCard() {
    try {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.audioTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                try {
                  _initializeAudioPlayer();
                } catch (e) {
                  print('Error retrying audio initialization: $e');
                }
              },
              icon: Icon(
                Icons.refresh,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building error card: $e');
      return const SizedBox.shrink();
    }
  }
}
