import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ReadAudio extends StatefulWidget {
  final String courseId,userRole;


  const ReadAudio({Key? key, required this.courseId, required this.userRole}) : super(key: key);

  @override
 State createState() => _ReadAudioState();
}

class _ReadAudioState extends State<ReadAudio> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<double> sliderValues = [];
  List<bool> isPlayingList = [];
  List<Duration> durations = [];
  List<Duration> positions = [];
  Duration? pausedPosition;

  int selectedIndex = -1;

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
        for (int index = 0; index < isPlayingList.length; index++) {
          if (isPlayingList[index]) {
            durations[index] = _audioPlayer.duration ?? Duration.zero;
            positions[index] = _audioPlayer.position;
          }
        }
      });
    });
  }

  bool isSliderActive(int index) {
    return sliderValues[index] != positions[index].inSeconds.toDouble();
  }

  Future<void> _playAudio(String url, int index) async {
    if (index != selectedIndex) {
      // Play the audio only if it's not already playing
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      setState(() {
        selectedIndex = index;
        // Set all audio tracks to be paused except for the selected one
        for (int i = 0; i < isPlayingList.length; i++) {
          isPlayingList[i] = false;
        }
        isPlayingList[index] = true; // Update play state for the selected audio
      });
      // Add position monitoring to check if audio has reached the end
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          positions[index] = position;
          if (positions[index] >= durations[index]) {
            // Audio has reached the end, pause it
            _pauseAudio();
              sliderValues.add(0.0);
              isPlayingList.add(false);
              durations.add(Duration.zero);
              positions.add(Duration.zero);
          }
        });
      });
    } else {
      // Toggle play/pause for the same audio
      if (isPlayingList[selectedIndex]) {
        _pauseAudio();
        setState(() {
          isPlayingList[selectedIndex] = false;
          pausedPosition =
              positions[selectedIndex]; // Store the paused position
        });
      } else {
        if (pausedPosition != null) {
          // Seek to the paused position
          await _audioPlayer.seek(pausedPosition!);
          pausedPosition = null; // Clear the stored paused position
        }
        await _audioPlayer.play();
        setState(() {
          isPlayingList[selectedIndex] =
              true; // Update play state for the selected audio
        });
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      isPlayingList[selectedIndex] = false;
      pausedPosition = positions[selectedIndex];
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
          return const CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
    

        return Column(
          children: documents.asMap().entries.map((entry) {
            int index = entry.key;
            QueryDocumentSnapshot document = entry.value;
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String audioUrl = data['downloadUrl'];
            String fileName = data['fileName'];
            String docId=document.id;
            if (kDebugMode) {
              print("docs id");
              print(docId);
            }

            while (sliderValues.length <= index) {
              sliderValues.add(0.0);
              isPlayingList.add(false);
              durations.add(Duration.zero);
              positions.add(Duration.zero);
            }

            return Column(
              children: [
                ListTile(
                  title: Text(fileName.toString()),
                  trailing: SizedBox(
                    width: MediaQuery.of(context).size.width*0.32,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            (isPlayingList[index] && selectedIndex == index)
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () async {
                            _playAudio(audioUrl, index);
                          },
                        ),
                        StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration>(
                              stream: _audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                final position = snapshot.data ?? Duration.zero;
                                return Text(
                                  (selectedIndex == index &&
                                          isPlayingList[index] &&
                                          duration != null)
                                      ? formatTime(positions[index])
                                      : formatTime(durations[index]),
                                );
                              },
                            );
                          },
                        ),
                        
                       widget.userRole=="Admin" ? IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 25,
                          ),
                          onPressed: () async {
                            _deleteAudio(docId,context);
                          },
                        ):const SizedBox(),
                      ],
                    ),
                  ),
                ),
                // Inside your build method, wrap your Slider with a StreamBuilder
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return Slider(
                      min: 0.0,
                      max: durations[index].inSeconds.toDouble() >= 1.0
                          ? durations[index].inSeconds.toDouble()
                          : 1.0,
                      value: (isPlayingList[index] && selectedIndex == index)
                          ? isSliderActive(index)
                              ? sliderValues[index]
                              : position.inSeconds.toDouble()
                          : 0.0,
                      onChanged: (value) async {
                        if (isPlayingList[index] && selectedIndex == index) {
                          setState(() {
                            sliderValues[index] = value;
                          });

                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                        }
                      },
                    );
                  },
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> _deleteAudio(String documentId, BuildContext context) async {
    // Show a confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Do you want to delete this audio ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        // Delete the document from Firestore
        await firestore.collection("courses")
        .doc(widget.courseId)
        .collection("course-audios").doc(documentId).delete().then((value) =>{
          setState(() {
             if (kDebugMode) {
               print("course deleted");
             }

          // Show a snackbar to indicate successful deletion
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio deleted successfully.'),
          ),
        );
          }),
         
        });
      
      } catch (e) {
        setState(() {
          // Handle errors if the document couldn't be deleted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting document: $e'),
          ),
        );
        });
      }
    }
  }


}
