import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:rwanda_traffic_rules/utils/generate_code.dart';
import 'package:rwanda_traffic_rules/backend/apis/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class CourseContentList extends StatefulWidget {
  final String id;
  final List<String> audios;
  final List<String> images;
  final String description;

  const CourseContentList({
    required this.id,
    required this.audios,
    required this.images,
    required this.description,
  });

  @override
  State createState() => _CourseContentListState();
}

class _CourseContentListState extends State<CourseContentList> {
  late String currentuserid;
  late String currentusername;
  late String currentuserphoto;
  late String currentUserPhone;
  String? userRole;
  late String phoneNumber;
  late SharedPreferences preferences;
  bool isLoading = false;
  List<AudioPlayer> _audioPlayers = [];
  late int _currentlyPlayingIndex;
  Map<int, Duration> _audioProgress = {};
  Map<int, Duration> _audioDurations = {};

  Stream<PositionData> get _positionDataStream {
    final List<Stream<PositionData>> individualStreams =
        _audioPlayers.map((audioPlayer) {
      return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );
    }).toList();

    return Rx.merge<PositionData>(individualStreams);
  }

  @override
  void initState() {
    super.initState();
    getCurrUser();
    _audioPlayers = widget.audios.map((audioUrl) => AudioPlayer()).toList();
    _currentlyPlayingIndex = -1;
    _initializeAudioPlayers();
  }

  final apiUrl = API.hostUser;

  getCurrUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid")!;
      currentusername = preferences.getString("name")!;
      currentUserPhone = preferences.getString("phone")!;
      userRole = preferences.getString("role")!;
    });
  }

  void _initializeAudioPlayers() {
    for (int i = 0; i < _audioPlayers.length; i++) {
      final audioPlayer = _audioPlayers[i];
      final audioUrl = widget.audios[i];

      // Load saved progress
      _loadAudioProgress(i, audioUrl);

      // Listen to position changes for progress tracking
      audioPlayer.positionStream.listen((position) {
        _audioProgress[i] = position;
        _saveAudioProgress(i, audioUrl, position);
      });

      // Listen to duration changes
      audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          _audioDurations[i] = duration;
        }
      });

      // Listen to player state changes for tracking
      audioPlayer.playerStateStream.listen((state) {
        if (state.playing) {
          _trackAudioPlay(i, audioUrl);
        }
      });
    }
  }

  Future<void> _loadAudioProgress(int index, String audioUrl) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${API.getAudioProgress}?userId=$currentuserid&lessonId=${widget.id}&audioUrl=$audioUrl'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data']['currentPosition'] > 0) {
          final position =
              Duration(milliseconds: data['data']['currentPosition']);
          _audioProgress[index] = position;

          // Set the audio player to the saved position
          await _audioPlayers[index].seek(position);
        }
      }
    } catch (e) {
      print('Error loading audio progress: $e');
    }
  }

  Future<void> _saveAudioProgress(
      int index, String audioUrl, Duration position) async {
    try {
      final duration = _audioDurations[index] ?? Duration.zero;

      await http.post(
        Uri.parse(API.saveAudioProgress),
        body: {
          'userId': currentuserid,
          'lessonId': widget.id,
          'audioUrl': audioUrl,
          'currentPosition': position.inMilliseconds.toString(),
          'totalDuration': duration.inMilliseconds.toString(),
        },
      );
    } catch (e) {
      print('Error saving audio progress: $e');
    }
  }

  Future<void> _trackAudioPlay(int index, String audioUrl) async {
    try {
      final duration = _audioDurations[index] ?? Duration.zero;
      final position = _audioProgress[index] ?? Duration.zero;

      await http.post(
        Uri.parse(API.trackAudioPlay),
        body: {
          'userId': currentuserid,
          'lessonId': widget.id,
          'audioUrl': audioUrl,
          'playDuration': position.inMilliseconds.toString(),
          'totalDuration': duration.inMilliseconds.toString(),
        },
      );
    } catch (e) {
      print('Error tracking audio play: $e');
    }
  }

  @override
  void dispose() {
    // Save progress before disposing
    for (int i = 0; i < _audioPlayers.length; i++) {
      final position = _audioProgress[i];
      if (position != null) {
        _saveAudioProgress(i, widget.audios[i], position);
      }
    }

    // Dispose audio players
    for (var player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.description != "" ? Text("${widget.description}") : SizedBox(),
          widget.images.isNotEmpty
              ? Column(
                  children: widget.images
                      .map(
                        (image) => Image.network(
                          '${apiUrl}/$image',
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      .toList(),
                )
              : SizedBox(),
          widget.audios.length.toInt() == 0
              ? Text('')
              : Column(
                  children: widget.audios
                      .asMap()
                      .entries
                      .map(
                        (entry) => Column(
                          children: [
                            // Audio Progress Bar
                            StreamBuilder<PositionData>(
                                stream: _positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ProgressBar(
                                      barHeight: 6,
                                      baseBarColor: Colors.grey[300],
                                      bufferedBarColor: Colors.grey[400],
                                      progressBarColor: Colors.blue,
                                      thumbColor: Colors.blue,
                                      timeLabelTextStyle: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      progress: positionData?.position ??
                                          Duration.zero,
                                      total: positionData?.duration ??
                                          Duration.zero,
                                      buffered:
                                          positionData?.bufferedPosition ??
                                              Duration.zero,
                                      onSeek: (value) {
                                        final newPosition = Duration(
                                            milliseconds:
                                                value.inMilliseconds.round());
                                        _audioPlayers[entry.key]
                                            .seek(newPosition);
                                      },
                                    ),
                                  );
                                }),

                            // Audio Controls
                            EnhancedControls(
                              audioPlayer: _audioPlayers[entry.key],
                              index: entry.key,
                              apiUrl: apiUrl,
                              audios: widget.audios,
                              currentlyPlayingIndex: _currentlyPlayingIndex,
                              onIndexChanged: (newIndex) {
                                setState(() {
                                  _currentlyPlayingIndex = newIndex;
                                });
                              },
                              audioProgress: _audioProgress[entry.key],
                              audioDuration: _audioDurations[entry.key],
                            )
                          ],
                        ),
                      )
                      .toList(),
                ),
          const Divider(),
          userRole == "Admin"
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    color: Colors.red,
                    iconSize: 20,
                    onPressed: () async {
                      final url = API.deleteContent;
                      GenerateUser.deleteUserCode(
                        context,
                        widget.id.toString(),
                        "0",
                        url,
                        "course deletion",
                        "deleted successfully!",
                      );
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class EnhancedControls extends StatelessWidget {
  const EnhancedControls({
    super.key,
    required this.audioPlayer,
    required this.index,
    required this.apiUrl,
    required this.audios,
    required this.currentlyPlayingIndex,
    required this.onIndexChanged,
    this.audioProgress,
    this.audioDuration,
  });

  final AudioPlayer audioPlayer;
  final int index;
  final String apiUrl;
  final List<String> audios;
  final int currentlyPlayingIndex;
  final Function(int) onIndexChanged;
  final Duration? audioProgress;
  final Duration? audioDuration;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing;
        final processingState = playerState?.processingState;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Play/Pause Button
              IconButton(
                onPressed: () {
                  if (currentlyPlayingIndex == index) {
                    // If the same track is pressed again, toggle play/pause
                    if (playing ?? false) {
                      audioPlayer.pause();
                    } else {
                      audioPlayer.play();
                    }
                  } else {
                    // Pause the previous track and play the new one
                    audioPlayer.pause();
                    audioPlayer.setUrl('$apiUrl/${audios[index]}');
                    audioPlayer.play();
                    onIndexChanged(index);
                  }
                },
                color: Colors.blue,
                iconSize: 40,
                icon: Icon(
                  currentlyPlayingIndex == index && playing == true
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
              ),

              const SizedBox(width: 12),

              // Audio Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      audios[index].split('/').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(audioProgress ?? Duration.zero) +
                          ' / ' +
                          _formatDuration(audioDuration ?? Duration.zero),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Loading indicator
              if (processingState == ProcessingState.loading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class Controls extends StatelessWidget {
  const Controls(
      {super.key,
      required this.audioPlayer,
      required this.index,
      required this.apiUrl,
      required this.audios,
      required this.currentlyPlayingIndex,
      required this.onIndexChanged});
  final AudioPlayer audioPlayer;
  final int index;
  final String apiUrl;
  final List<String> audios;
  final int currentlyPlayingIndex;
  final Function(int) onIndexChanged;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        // final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        return IconButton(
          onPressed: () {
            if (currentlyPlayingIndex == index) {
              // If the same track is pressed again, toggle play/pause
              if (playing ?? false) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            } else {
              // Pause the previous track and play the new one
              audioPlayer.pause();
              audioPlayer.setUrl('$apiUrl/${audios[index]}');
              audioPlayer.play();
              onIndexChanged(index); // Update the currentlyPlayingIndex
            }
          },
          color: Colors.black,
          iconSize: 50,
          icon: Icon(
            currentlyPlayingIndex == index && playing == true
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
          ),
        );
      },
    );
  }
}

class PositionData {
  const PositionData(
    this.position,
    this.bufferedPosition,
    this.duration,
  );
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}
