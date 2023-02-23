class QuestionModel {
  String question;
  String option1, option2, option3, option4, correctOption;
  bool answered;
  String questionImgUrl;

  QuestionModel(
    this.question,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.correctOption,
    this.answered,
    this.questionImgUrl,
  );
}
