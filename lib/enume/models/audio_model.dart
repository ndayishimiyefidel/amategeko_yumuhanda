class AudioModel {
  String courseId;
  final String courseAudioUrls;
  String fileName;
  bool isSelected;
  String selectedAudioUrl;

  AudioModel(
      {required this.courseId,
      required this.courseAudioUrls,
      required this.fileName,
      this.isSelected = false,
      required this.selectedAudioUrl});
}
