// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
//
// import '../../enume/models/audio_model.dart';
//
// class ReadAudio extends StatefulWidget {
//   final String courseId;
//
//   const ReadAudio({Key? key, required this.courseId}) : super(key: key);
//
//   @override
//   _ReadAudioState createState() => _ReadAudioState();
// }
//
// class _ReadAudioState extends State<ReadAudio> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   int selectedAudioIndex = -1;
//   double sliderValue = 0.0; // Track the slider value
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//
//   String formatTime(Duration duration) {
//     String minutes =
//     duration.inMinutes.remainder(60).toString().padLeft(2, '0');
//     String seconds =
//     duration.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$minutes:$seconds";
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _audioPlayer.playerStateStream.listen((playerState) {
//       setState(() {
//         isPlaying = playerState.playing;
//         duration = _audioPlayer.duration ?? Duration.zero;
//         position = _audioPlayer.position;
//         if (!isSliderActive()) {
//           // Update the slider value only if it's not being actively dragged
//           sliderValue = position.inSeconds.toDouble();
//         }
//       });
//     });
//   }
//
//   bool isSliderActive() {
//     // Check if the slider is actively being dragged
//     return sliderValue != position.inSeconds.toDouble();
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   Future<void> _playAudio(String url,) async {
//     Uri audioUri;
//     try {
//       audioUri = Uri.parse(url);
//     } catch (e) {
//       print('Invalid audio URL: $url');
//       return;
//     }
//
//     if (audioUri.scheme.isEmpty) {
//       print('Invalid audio URL: $url');
//       return;
//     }
//
//     await _audioPlayer.stop(); // Stop the previously playing audio, if any
//     await _audioPlayer.setUrl(url);
//     await _audioPlayer.play();
//   }
//
//   void _startUpdatingTimes() {
//     // Start a timer that updates the times every second
//     Timer.periodic(Duration(seconds: 1), (timer) {
//       // Get the current position of the audio player
//       final positions = _audioPlayer.position;
//
//       setState(() {
//         // Calculate the starting and ending times
//         duration = position;
//         position = duration - positions;
//       });
//     });
//   }
//
//   Future<void> _pauseAudio() async {
//     await _audioPlayer.pause();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection("courses")
//           .doc(widget.courseId)
//           .collection("course-audios")
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }
//
//         List<AudioModel> audioList = [];
//
//         snapshot.data!.docs.forEach((doc) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           String courseId = data['courseId'];
//           dynamic audioUrls = data['downloadUrl'];
//           String fileName = data['fileName'];
//           List<String> parsedAudioUrls;
//           if (audioUrls is List<dynamic>) {
//             parsedAudioUrls = List<String>.from(audioUrls);
//           } else if (audioUrls is String) {
//             parsedAudioUrls = [audioUrls];
//           } else {
//             print('Invalid audio URL format');
//             return;
//           }
//
//           AudioModel audioModel = AudioModel(
//             courseId: courseId,
//             courseAudioUrls: parsedAudioUrls,
//             fileName: fileName,
//           );
//
//           audioList.add(audioModel);
//         });
//
//         return SizedBox(
//           height: MediaQuery
//               .of(context)
//               .size
//               .height * 0.4,
//           child: ListView.builder(
//             itemCount: audioList.length,
//             itemBuilder: (context, index) {
//               AudioModel audio = audioList[index];
//               return Column(
//                 children: [
//                   Text(audio.fileName.toString()),
//                   Slider(
//                     min: 0.0,
//                     max: duration.inSeconds.toDouble() >= 1.0
//                         ? duration.inSeconds.toDouble()
//                         : 1.0,
//                     value: selectedAudioIndex == index
//                         ? isSliderActive()
//                         ? sliderValue
//                         : position.inSeconds.toDouble()
//                         : 0.0, // Set value to 0 when audio is not selected
//                     onChanged: (value) async {
//                       if (selectedAudioIndex == index) {
//                         setState(() {
//                           sliderValue = value; // Update the slider value
//                         });
//
//                         final position = Duration(seconds: value.toInt());
//                         await _audioPlayer.seek(position);
//                       }
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(formatTime(position)),
//                         CircleAvatar(
//                           backgroundColor: selectedAudioIndex == index
//                               ? Colors.blue
//                               : Colors.grey,
//                           radius: 20,
//                           child: IconButton(
//                             icon: Icon(
//                               isPlaying && selectedAudioIndex == index
//                                   ? Icons.pause
//                                   : Icons.play_arrow,
//                               color: selectedAudioIndex == index
//                                   ? Colors.white
//                                   : Colors.black,
//                             ),
//                             onPressed: () async {
//                               if (isPlaying && selectedAudioIndex == index) {
//                                 _pauseAudio();
//                               } else {
//                                 if (isPlaying) {
//                                   _pauseAudio();
//                                 }
//                                 // setState(() {
//                                 //   selectedAudioIndex =
//                                 //       index; // Update the selected index
//                                 // });
//                                 // print("selected index");
//                                 // print(selectedAudioIndex);
//                                 // List<String> audioUrls = audio.courseAudioUrls;
//                                 // String url = audioUrls.first;
//                                 // String extractedUrl =
//                                 //     url.replaceAll("[", "").replaceAll("]", "");
//                                 // print("Extract url");
//                                 // print(extractedUrl);
//                                 // Uri audioUri = Uri.parse(extractedUrl);
//                                 // String modifiedUrl =
//                                 //     "${audioUri.scheme}://${audioUri.host}${audioUri.path}?alt=media";
//                                 // print("modified url");
//                                 // print(modifiedUrl);
//                                 // print(url);
//
//                                 setState(() {
//                                   selectedAudioIndex = index;
//                                   audioList.forEach((audio) {
//                                     audio.selectedAudioUrl =
//                                     ''; // Reset all other selectedAudioUrl
//                                   });
//                                   audio.selectedAudioUrl =
//                                   audio.courseAudioUrls[
//                                   0]; // Set the selected audio URL
//                                 });
//                                 print(audio.selectedAudioUrl[0]);
//                                 _playAudio(audio.selectedAudioUrl);
//                                 // _playAudio(url, index);
//                               }
//                             },
//                           ),
//                         ),
//                         Text(formatTime(duration - position)),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../enume/models/audio_model.dart';

class ReadAudio extends StatefulWidget {
  final String courseId;

  const ReadAudio({Key? key, required this.courseId}) : super(key: key);

  @override
  _ReadAudioState createState() => _ReadAudioState();
}

class _ReadAudioState extends State<ReadAudio> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? selectedAudioUrl; // Track the selected audio URL
  double sliderValue = 0.0; // Track the slider value
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((playerState) {
      setState(() {
        isPlaying = playerState.playing;
        duration = _audioPlayer.duration ?? Duration.zero;
        position = _audioPlayer.position;
        if (!isSliderActive()) {
          // Update the slider value only if it's not being actively dragged
          sliderValue = position.inSeconds.toDouble();
        }
      });
    });
  }

  bool isSliderActive() {
    // Check if the slider is actively being dragged
    return sliderValue != position.inSeconds.toDouble();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String url) async {
    Uri audioUri;
    try {
      audioUri = Uri.parse(url);
    } catch (e) {
      print('Invalid audio URL: $url');
      return;
    }

    if (audioUri.scheme.isEmpty) {
      print('Invalid audio URL: $url');
      return;
    }
    await _audioPlayer.setUrl(url);
    await _audioPlayer.play();
    //_startUpdatingTimes();
    setState(() {
      selectedAudioUrl = url; // Assign the selected audio URL
    });
  }

  void _startUpdatingTimes() {
    // Start a timer that updates the times every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      // Get the current position of the audio player
      final positions = _audioPlayer.position;

      setState(() {
        // Calculate the starting and ending times
        duration = position;
        position = duration - positions;
      });
    });
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.courseId)
          .collection("course-audios")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<AudioModel> audioList = [];

        snapshot.data!.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String courseId = data['courseId'];
          String audioUrls = data['downloadUrl'];
          String fileName = data['fileName'];

          AudioModel audioModel = AudioModel(
            courseId: courseId,
            courseAudioUrls: audioUrls,
            fileName: fileName,
            selectedAudioUrl: '', // Initialize with an empty selected audio URL
          );

          audioList.add(audioModel);
        });

        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: audioList.length,
            itemBuilder: (context, index) {
              AudioModel audio = audioList[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(audio.courseAudioUrls.toString()),
                    trailing: SizedBox(
                      width: 100,
                      // Specify a fixed width for the trailing widget
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying &&
                                      selectedAudioUrl == audio.courseAudioUrls
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () async {
                              if (isPlaying &&
                                  selectedAudioUrl == audio.courseAudioUrls) {
                                _pauseAudio();
                              } else {
                                if (isPlaying) {
                                  _pauseAudio();
                                }
                                print("udio selected url");
                                print(audio.selectedAudioUrl);
                                _playAudio(audio.selectedAudioUrl);
                              }
                            },
                          ),
                          Text(formatTime(duration - position)),
                        ],
                      ),
                    ),
                  ),
                  Slider(
                    min: 0.0,
                    max: duration.inSeconds.toDouble() >= 1.0
                        ? duration.inSeconds.toDouble()
                        : 1.0,
                    value: selectedAudioUrl == audio.selectedAudioUrl
                        ? isSliderActive()
                            ? sliderValue
                            : position.inSeconds.toDouble()
                        : 0.0,
                    onChanged: (value) async {
                      if (selectedAudioUrl == audio.selectedAudioUrl) {
                        setState(() {
                          sliderValue = value;
                        });

                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
