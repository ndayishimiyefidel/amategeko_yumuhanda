import 'package:amategeko/backend/apis/db_connection.dart';
import 'package:amategeko/utils/generate_code.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void dispose() {
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
                            StreamBuilder<PositionData>(
                                stream: _positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return ProgressBar(
                                    barHeight: 5,
                                    baseBarColor: Colors.grey[600],
                                    bufferedBarColor: Colors.grey,
                                    progressBarColor: Colors.red,
                                    thumbColor: Colors.blueAccent,
                                    timeLabelTextStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    progress:
                                        positionData?.position ?? Duration.zero,
                                    total:
                                        positionData?.duration ?? Duration.zero,
                                    buffered: positionData?.bufferedPosition ??
                                        Duration.zero,
                                    onSeek: (value) {
                                      final newPosition = Duration(
                                          milliseconds:
                                              value.inMilliseconds.round());
                                      _audioPlayers[entry.key]
                                          .seek(newPosition);
                                    },
                                  );
                                }),
                            SizedBox(
                              height: 10,
                            ),
                            Controls(
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
