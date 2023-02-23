import 'dart:io';

import 'package:amategeko/components/text_field_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../quizzes/create_quiz.dart';

class AddQuestion extends StatefulWidget {
  final String quizId, quizTitle;
  final bool isNew;

  const AddQuestion(
      {required this.quizId, required this.quizTitle, required this.isNew});

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  final _formkey = GlobalKey<FormState>();
  String question = "", option1 = "", option2 = "";
  String option3 = "", option4 = "";
  String questionUrl = "";

  //adding controller
  final TextEditingController questionController = TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();
  final TextEditingController option3Controller = TextEditingController();
  final TextEditingController option4Controller = TextEditingController();
  bool _isLoading = false;

  final picker = ImagePicker();
  UploadTask? uploadTask;
  File? pickedFile;

  Future selectsFile() async {
    final pickedFiles = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFiles != null) {
        pickedFile = File(pickedFiles.path);
        _isLoading = false;
      }
    });
  }

  //database service
  DatabaseService databaseService = DatabaseService();

  ///saving quiz data inside quiz
  ///creating map data

  @override
  void initState() {
    super.initState();
    Map<String, String> questionMap1 = {
      "quizId": widget.quizId,
      "question":
          "Inyamaswa zigenda mu muhanda zigomba uko bishobotse kwose, gukomeza ku gendera:ing12",
      "option1": "Ku nkombe y’iburyo",
      "option2": ".Ku nkombe y’ibumoso",
      "option3": "Mu kayira kabanyamaguru",
      "option4": "d.Byose n’ibisubizo by’ukuri",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap2 = {
      "quizId": widget.quizId,
      "question":
          "Keretse hari amategeko yihariye iyo inzira nyabagendwa igabanyijemo imihanda ibiri cyangwa itatu itandukanyijwe kuburyo bugaragazwa nakarondorondo kubutaka umwanya utanyurwamo nibinyabiziga ubusumbane bwumuhanda cyangwa utandukanyijwe numurongo wumweru urombereje abayobozi babujijwe kunyura. Ing12,2",
      "option1": "Nti bashobora kunyura mumuhanda ubangikanye nuwo bagendamo",
      "option2": "Mu bisate bibiri byibumoso",
      "option3": "Nta gisubizo cy’ukuri kirimo",
      "option4": "Kunyura mu gisate cyerekeye inkombe y’ibumoso ",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap3 = {
      "quizId": widget.quizId,
      "question":
          "Iyo umuhanda ugabanyijemo ibisate bine kandi ukaba ugenderwamo mubyerekezo byombi umuyobozi wese abujijwe kunyura :ing12,3",
      "option1": "Mu bisate bibiri byibumoso",
      "option2": "Kunyura mubisate bibiri byiburyo",
      "option3": "Kunyura mugisate kiri ibumuso",
      "option4": "Kugenda Abangikanye nundi mu yobozi",
      "quizPhotoUrl": "",
    };
    Map<String, String> questionMap4 = {
      "quizId": widget.quizId,
      "question": "Kugenda kumirongo ibangikanye byemewe nanone:ing12,3",
      "option1": "Kumuhanda wicyerekezo kimwe ufite nibura ibisate bibiri",
      "option2": "Iyo ubugari bwumuhanda buhagije",
      "option3": "Kumihanda yibyerekezo bibiri ifite nibura ibisate bibiri",
      "option4": "Iyo ntabinyabiziga byinshi birimo kugenda",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap5 = {
      "quizId": widget.quizId,
      "question":
          "Iyo kubera ubucucike bw’ibigenda mu muhanda hiremye imirongo ibangikanye kandi irombereje aboyobozi bagomba gukomeza ku gendesha ibinyabiziga:ing12,3",
      "option1": "Ku murongo umwe",
      "option2": "Ku mirongo ibangikanye",
      "option3": "Uko bashaka bipfa kudateza impanuka",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap6 = {
      "quizId": widget.quizId,
      "question":
          "Iyo kugenda kumirongo ibangikanye byemewe kandi ibisate byumuhanda bikaba bigaragazwa n’imirongo irombereje cyangwa iciyemo uduce abayobozi babujijwe:ing12,3 ",
      "option1": "Kunyura hejuru yiyo mirongo",
      "option2": "Kunyura hejuru yumurongo udacagaguye",
      "option3": "Kunyura hejuru yumurongo ucagaguye",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap7 = {
      "quizId": widget.quizId,
      "question":
          "Bitabangamiye ibiteganywa n’amategeko ahana,umugenzi wese uguweho n’impanuka agomba:ing4",
      "option1": "Byose n’ibisubizo byukuri",
      "option2": "Guhita ahagarara igihe bimushobokeye",
      "option3":
          "Gukora uko ashoboye kwose kugirango uburyo bwo kugenda mu muhanda bw’aho impanuka yabereyebwoye guhungabana",
      "option4":
          "Kwakiriza icyarimwe amatara yose ndangacyerekezo y’ikinyabiziga,",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap8 = {
      "quizId": widget.quizId,
      "question":
          "Iyo umuntu yapfiriye muri iyo mpanuka cyangwa yakomerekeyemo bikabije, ariko akabona nta byagobishobora ku mutera, umuyobozi agomba kuguma aho impanuka yabereye cyangwa kuhagarukakugez’igihe abubahiriza amahoro bahagereye, cyeretse: ing 4,5 ",
      "option1": "Byose n’ibisubizo byukuri",
      "option2": "Iyo agomba gutabara abakomeretse",
      "option3": "Iyo agomba kujya kwivuza ubwe",
      "option4": "Iyo bamwereye kuhava",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap9 = {
      "quizId": widget.quizId,
      "question":
          "Ibitegekwa nabakozi babifitiye ububasha ukuboko kuzamuye gutegeka ibi bikurikira:ing5,a",
      "option1":
          "Abagenzi bose guhagarara keretse abageze mwisangano bagomba guhita bahava",
      "option2": "Gutegeka abagendera kuri velomoteriguhagarara",
      "option3": "Gbagenzi bose guhagarara nabageze mwisangano",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap10 = {
      "quizId": widget.quizId,
      "question":
          "Ibitegekwa n’abakozi babifitiye ububasha kuzunguza intambike itara ritukura bitegeka:ing5,c",
      "option1": "Guhagarara abo iryo tara riganishaho",
      "option2": "Abaturuka inyuma yaryo bagomba gutambuka ",
      "option3": "Abagenzi bose bagomba guhagarara",
      "option4": "Abagendera kuri Velomoteri nibo bagomba gutambuka",
      "quizPhotoUrl": "",
    };
    Map<String, String> questionMap11 = {
      "quizId": widget.quizId,
      "question":
          "Ibitegekwa n’abakozi babifitiye ububasha birusha agaciro :ing5 .6",
      "option1": "Ibindi bimenyetso",
      "option2": " Ibyapa byo kumihanda",
      "option3": "Imirongo yomumuhanda",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap12 = {
      "quizId": widget.quizId,
      "question":
          "Ntawe ushobora gutwara ikinyabiziga kigendeshwa na moteri muzira nyabagendwa adafite kandi atitwaje uruhushya rwo gutwara ibinyabiziga rwatanzwe: ing6,1",
      "option1": "Polisi y’igihugu",
      "option2": "Minisiteriishinzwe gutwara abantu n’ibintu",
      "option3": "Polisi ihinzwe umtekano wo mu muhanda",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap13 = {
      "quizId": widget.quizId,
      "question":
          "Uko uruhushya rwo gutwara ikinyabiziga ruteye n’uko rutangwa bigenwa n’iteka rya Minisitiri ushinzwe gutwara abantu n’ibintu abisabwe na:ing6,1",
      "option1": "Komite y’igihugu ishinzwe umutekano mu muhanda",
      "option2": "Minisiteri ishinzwe gutwara abantu n’ibintu",
      "option3": "Polisi y’igihugu",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap14 = {
      "quizId": widget.quizId,
      "question":
          "Uruhushya rwo gutwara ibinyabiziga rutangwa burundu abarusaba bamaze gutsinda ibizamini bikurikira: ing 6,4",
      "option1": "A na B n’ibisubizo by’ukuri",
      "option2":
          ".Ikizamini kumasomo cy’erekana ko ubazwa azi bihagije amategeko y’umuhanda",
      "option3":
          "Ikizamini ku masomo cy’erekana ko ubazwa azi gutwara ikinyabiziga cyo mu rwego asabira uruhushya rwo gutwara",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap15 = {
      "quizId": widget.quizId,
      "question":
          "ibizamini byerekeye amasomo no gutwara ibinyabiziga ku girango hatangwe uburenganzira bwo gutwara ibinyabiziga bukorwa mu buryo bwashyizweho na: ing 6,4",
      "option1": "Minisitiri ushinzwe gutwara abantu n’ibintu",
      "option2": "Minisitiri ushinzwe ubutegetsi bw’igihugu",
      "option3": "Polisi y’igihugu",
      "option4": "Minisitiri ushinzwe imirimo ya leta",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap16 = {
      "quizId": widget.quizId,
      "question":
          ". Uruhushya rw’agateganyo rwo gutwara ibinyabiziga rufite agaciro :ing6,5c",
      "option1": "kunzego zose z’ibinyabiziga",
      "option2": "Kuri velomoteri",
      "option3": "Kunzego A na B z’ibinyabiziga",
      "option4": "Nta gisubizo cy’ukuri kirimo",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap17 = {
      "quizId": widget.quizId,
      "question":
          "Ufite uruhushya rwa gategeanyo rwo gutwara ibinyabiziga ntiyemerewe gutwara imodoka keretse:ing6,5d",
      "option1":
          "Ari kumwe n’umwigisha ufite uburenganzira bwo rwego rw’imodoka atwaye",
      "option2": "Ari kumwe n’umuyobozi wiyo modoka",
      "option3": "Ari mu muhanda w’ibitaka",
      "option4": "Azi imodoka bihagije",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap18 = {
      "quizId": widget.quizId,
      "question":
          "Icyemezo cyo kwambura burundu uruhushya rwo gurwara ikinyabiziga kimenyeshwa:ing6,8g",
      "option1": "Ubutegetsi bwa butanze",
      "option2": "Nta gisubizo cy’ukuri kirimo",
      "option3": "Ibiro bishinzwe imisoro",
      "option4": "Polisi ishinzwe umutekano wo mu muhanda",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap19 = {
      "quizId": widget.quizId,
      "question":
          "Inzego z’ibinyabiziga urwego C n’imodoka zagenewe gutwara Ibintu bifite uburemere ntarengwa bwemewe burenga ibiro:ing6,2",
      "option1": "Ibiro5000= Toni5",
      "option2": "Nta gisubizo cy’ukuri kirimo",
      "option3": "Ibiro 500",
      "option4": "Ibiro3500",
      "quizPhotoUrl": "",
    };

    Map<String, String> questionMap20 = {
      "quizId": widget.quizId,
      "question":
          "Ninde ufite ububasha bwo gutanga uruhushya mpuzamahanga rwo gutwara ikinyabiziga:ing7,1",
      "option1": "Polisi y’igihugu",
      "option2": "Nta gisubizo cy’ukuri kirimo",
      "option3": "Minisiteri ishinzwe gutwara abantu n’ibintu",
      "option4": "Ikigo gishinzwe abinjira n’abasohoka mu gihugu",
      "quizPhotoUrl": "",
    };
    // Map<String, String> questionMap21 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Ikinyabiziga cyose cyangwa ibinyabiziga bikururana, iyo bigenda bigomba kugira:ing10,1",
    //   "option1": "Ubiyobora",
    //   "option2": "Umuherekeza",
    //   "option3": "Akarebanyuma",
    //   "option4": "Igihagarika-muyaga",
    //   "quizPhotoUrl": "",
    // };
    //
    // Map<String, String> questionMap22 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Icyemezo cyo kwambura burundu uruhushya rwo gutwara ikinyabiziga kimenyeshwa: ing6,8g",
    //   "option1": "Ubutegetsi bwabutanze",
    //   "option2": "Nta gisubizo cy’ukuri kirimo",
    //   "option3": "Polisi y’igihugu",
    //   "option4": "Umukuru w’intara",
    //   "quizPhotoUrl": "",
    // };
    // Map<String, String> questionMap23 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Birabujijwe ku bangamira uburyo bwo ku genda mu muhanda cyangwa gutuma watera ibyago kubera kujugunya, kurunda, gusiga cyangwa kugusha mu nzira nyabagendwa ibintu ibyo aribyo byose, nkibisate by’irahuri, mazutu, lisansi, gazi na mavuta, kuhuka umwotsi cyangwa ibyuka, ariko ibyo ntibibujijwe:ing8,1",
    //   "option1":
    //   "Ku bakozi b’imirimo ya leta, igihe bari mu kazi kabo bakoresha ibyuma bivubura imyotsi, ibyuka cyangwa ibifu",
    //   "option2": "Ku binyabiziga ndakumirwa",
    //   "option3": "Ku binyabiziga bya gisirikare",
    //   "option4": "Byose n’ibisubizo by’ukuri",
    //   "quizPhotoUrl": "",
    // };
    //
    // Map<String, String> questionMap24 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Inyamaswa zigenda mumuhanda zigomba kugabanywamo amatsinda uretse mugihe:ing11bis",
    //   "option1": "Hatanzwe amabwiriza yihariye yo kwimuka",
    //   "option2": "Ari kumanywa hameze neza",
    //   "option3": "Hari abaherekeza bahagije",
    //   "option4": "Atari mu nzira nyabagendwa",
    //   "quizPhotoUrl": "",
    // };
    // Map<String, String> questionMap25 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Iyo umuhanda ugabanyijemo ibisate bitatu kandi ukaba ugenderwamo mubyerekezo byombiumuyobozi wese abujijwi kunyura :ing12,4",
    //   "option1": "Mu gisate cy,erekeye inkombe yibumoso bw’umuhanda",
    //   "option2": "Mu gisate cyerekeye inkombe yeburyo bwumuhanda",
    //   "option3": "Mu bisate bibiri byibumoso",
    //   "option4": "Mu bisate bibiri byiburyo",
    //   "quizPhotoUrl": "",
    // };
    //
    // Map<String, String> questionMap26 = {
    //   "quizId": widget.quizId,
    //   "question":
    //   "Iyo umuhanda ugabanijwemo ibisate bibiri kandi ukaba ugenderwamo mu byerekezo byombi umuyobozi wese abujijwe kunyura:ing12,5",
    //   "option1": "Mu gisate kiri ibumoso bw’umuhanda",
    //   "option2": "Mu gisate cy’erekeye inkombe y’ibumoso",
    //   "option3": "Mu bisate bibiri biri ibumoso",
    //   "option4": "Mu gisate kiri iburyo bw’umuhanda",
    //   "quizPhotoUrl": "",
    // };

    ///end at 34 questions

    /// call map from 1 to 25
    // databaseService.addQuestionData(questionMap1, widget.quizId);
    // databaseService.addQuestionData(questionMap2, widget.quizId);
    // databaseService.addQuestionData(questionMap3, widget.quizId);
    // databaseService.addQuestionData(questionMap4, widget.quizId);
    // databaseService.addQuestionData(questionMap5, widget.quizId);
    // databaseService.addQuestionData(questionMap6, widget.quizId);
    // databaseService.addQuestionData(questionMap7, widget.quizId);
    // databaseService.addQuestionData(questionMap8, widget.quizId);
    // databaseService.addQuestionData(questionMap9, widget.quizId);
    // databaseService.addQuestionData(questionMap10, widget.quizId);
    // databaseService.addQuestionData(questionMap11, widget.quizId);
    // databaseService.addQuestionData(questionMap12, widget.quizId);
    // databaseService.addQuestionData(questionMap13, widget.quizId);
    // databaseService.addQuestionData(questionMap14, widget.quizId);
    // databaseService.addQuestionData(questionMap15, widget.quizId);
    // databaseService.addQuestionData(questionMap16, widget.quizId);
    // databaseService.addQuestionData(questionMap17, widget.quizId);
    // databaseService.addQuestionData(questionMap18, widget.quizId);
    // databaseService.addQuestionData(questionMap19, widget.quizId);
    // databaseService.addQuestionData(questionMap20, widget.quizId);
    // databaseService.addQuestionData(questionMap21, widget.quizId);
    // databaseService.addQuestionData(questionMap22, widget.quizId);
    // databaseService.addQuestionData(questionMap23, widget.quizId);
    // databaseService.addQuestionData(questionMap24, widget.quizId);
    // databaseService.addQuestionData(questionMap25, widget.quizId);
  }

  uploadQuizData() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      int totQuestion = 0;
      String refId = randomAlphaNumeric(16);
      String filepath = 'images/$refId';

      if (pickedFile == null) {
        questionUrl = "";
      } else {
        final refs = FirebaseStorage.instance.ref().child(filepath);
        uploadTask = refs.putFile(pickedFile!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final downloadlink = await snapshot.ref.getDownloadURL();
        print("download link $downloadlink");
        questionUrl = downloadlink.toString();
      }
      Map<String, String> questionMap = {
        "quizId": widget.quizId,
        "question": question,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4,
        "quizPhotoUrl": questionUrl,
      };

      ///check whether if the quiz is not filled
      ///using collection group
      await FirebaseFirestore.instance
          .collectionGroup("QNA")
          .where("quizId", isEqualTo: widget.quizId)
          .get()
          .then((querySnapshot) async {
        print("Total question in single Quiz:  ${querySnapshot.size}");
        totQuestion = querySnapshot.size;

        ///19<20
        if (totQuestion < 20) {
          await databaseService
              .addQuestionData(questionMap, widget.quizId)
              .then((value) {
            setState(() {
              _isLoading = false;
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text("Question saved successfully"),
                      actions: [
                        TextButton(
                            onPressed: () {
                              _formkey.currentState!.reset();
                              questionController.clear();
                              option1Controller.clear();
                              option2Controller.clear();
                              option3Controller.clear();
                              option4Controller.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text("ok"))
                      ],
                    );
                  });
            });
          });
        } else {
          ///please create new quiz or exam
          setState(() {
            _isLoading = false;

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Quiz Filled"),
                    content: const Text(
                      "Every quiz must have 20 question,simply create new quiz",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            _formkey.currentState!.reset();
                            questionController.clear();
                            option1Controller.clear();
                            option2Controller.clear();
                            option3Controller.clear();
                            option4Controller.clear();
                            Route route = MaterialPageRoute(
                                builder: (c) => const CreateQuiz());
                            Navigator.of(context).push(route);
                          },
                          child: const Text(
                            "Create new",
                            style: TextStyle(color: Colors.blueAccent),
                          ))
                    ],
                  );
                });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final questionField = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: questionController,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          questionController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          icon: Icon(
            Icons.question_answer_outlined,
            color: kPrimaryColor,
          ),
          hintText: "Type Question...",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          question = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter question' : null,
      ),
    );
    //quiz title field
    final option1Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option1Controller,
        onSaved: (value) {
          option1Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 1 correct",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option1 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 1' : null,
      ),
    );
    //quiz desc
    final option2Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option2Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option2Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 2",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option2 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 2' : null,
      ),
    );
    final option3Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option3Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option3Controller.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          hintText: "Option 3",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option3 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 3' : null,
      ),
    );
    final option4Field = TextFieldContainer(
      child: TextFormField(
        autofocus: false,
        controller: option4Controller,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          option4Controller.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: "Option 4",
          border: InputBorder.none,
        ),
        onChanged: (val) {
          option4 = val;
        },
        autovalidateMode: AutovalidateMode.disabled,
        validator: (input) => input!.isEmpty ? 'Enter option 4' : null,
      ),
    );
    final addquestionBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            uploadQuizData();
          },
          child: const Text(
            "SAVE QUESTION",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    final addsubmitBtn = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      height: size.height * 0.07,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryLightColor),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            "SUBMIT",
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add Questions",
          style: TextStyle(
            letterSpacing: 1.25,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {},
          )
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "QUIZ TITLE : ${widget.quizTitle}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  questionField,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(0.0),
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          (pickedFile == null)
                              ? Container()
                              : Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Material(
                                          // display new updated image
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(125.0)),
                                          clipBehavior: Clip.hardEdge,
                                          // display new updated image
                                          child: Image.file(
                                            pickedFile!,
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          )),
                                    ],
                                  ),
                                ),
                          GestureDetector(
                            onTap: selectsFile,
                            child: Padding(
                                padding: (pickedFile == null)
                                    ? const EdgeInsets.only(
                                        top: 0.0, right: 170.0)
                                    : const EdgeInsets.only(
                                        top: 150.0, right: 120.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 25.0,
                                      child: Icon(
                                        Icons.photo,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option1Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option2Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option3Field,
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  option4Field,
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                          child: null,
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          addquestionBtn,
                          addsubmitBtn,
                        ],
                      ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
