import 'package:amategeko/backend/apis/db_connection.dart';
import 'package:amategeko/utils/generate_code.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
  AudioPlayer? _audioPlayer;
  Duration _duration = Duration();
  Duration _position = Duration();
  int _currentlyPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    getCurrUser();
    _audioPlayer = AudioPlayer();
    if (_audioPlayer != null) {
      _initAudioPlayer();
    }
  }

  void _initAudioPlayer() {
    _audioPlayer!.durationStream.listen((event) {
      setState(() {
        _duration = event!;
      });
    });

    _audioPlayer!.positionStream.listen((event) {
      setState(() {
        _position = event;
      });
    });
  }

  void _playAudio(String audioUrl, int index) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        _initAudioPlayer();
      }

      if (_currentlyPlayingIndex != -1) {
        // Pause the previous audio if there is one playing
        _audioPlayer?.pause();
      }

      // Check if _audioPlayer is still not null before attempting to setUrl
      if (_audioPlayer != null) {
        await _audioPlayer!.setUrl(audioUrl);

        // Check if _audioPlayer is still not null before attempting to play
        if (_audioPlayer != null) {
          await _audioPlayer!.play();
          setState(() {
            _currentlyPlayingIndex = index;
          });
        }
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
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
                            ElevatedButton(
                              onPressed: () {
                                _playAudio(
                                    '${apiUrl}/${entry.value}', entry.key);
                              },
                              child: Text('Play Audio'),
                            ),
                            if (_currentlyPlayingIndex == entry.key)
                              Slider(
                                value: _position.inMilliseconds.toDouble(),
                                min: 0,
                                max: _duration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  final newPosition =
                                      Duration(milliseconds: value.toInt());
                                  _audioPlayer!.seek(newPosition);
                                },
                              ),
                          ],
                        ),
                      )
                      .toList(),
                ),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              color: Colors.red,
              onPressed: () async {
                final url = API.deleteIremboUser;
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
                size: 30,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
