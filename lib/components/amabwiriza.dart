import 'package:amategeko/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/insttruction.dart';

class AmabwirizaList extends StatelessWidget {
  void shareApp() {
    const String playStoreLink =
        "https://play.google.com/store/apps/details?id=com.amategeko.amategeko";

    final String message =
        "Iyi application  yitwa RWANDA TRAFFIC RULE ni nziza iri kuri play store igizwe n'ibibazo n'ibisubizo babaza muri examin ya provisoire iga examin zose zirimo kuko bazakubaza imwe muri zo cyangwa baterure ibibazo 20 muri application Ni karibu kuri mwe mwese mushaka Provisoire mukoresheje uburyo bworoshye kandi bwizewe yangiriye akamaro Nawe yakugirira umumaro cyane kanda hano  $playStoreLink";

    // Share the message containing the link (with or without referral code)
    Share.share(
      message,
      subject: "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AMABWIRIZA'),
        backgroundColor: kPrimaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ikaze kuri RWANDA TRAFFIC RULE:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              InstructionItem(
                title: '1. UBUSOBANURO BWA APPLICATION',
                description:
                    "Iyi application yitwa ``RWANDA TRAFFIC RULE`` ni application yigisha amategeko y'umuhanda,igizwe n'ibibazo babaza mu kizamini  cya provisoire (uruhushya rw'agatenyo)",
              ),
              InstructionItem(
                title: '2. UKO APPLICATION IKORA',
                description:
                    '1.Kugirango ukoreshe iyi application ugomba kubanza kwiyandikisha kuri application mugihe ukoze download bwa mbere aho usabwa kwandika amazina yawe, nimero yawe telephone inshuro ebyiri.\n 2.Mugihe usanzwe wariyandikishe ntabwo wongera  kwiyandisha ahubwo ukanda ahanditse "Injira" ubundi ugashyiramo nimero ya telephone  ubundi ugakanda "Emeza" ugahita ugera ahitwa dashboard usanga ibikubyemo muri application.\n 3. Gutangira kwiga ukanda ahanditse "Exam" iyo uhafunguye hagizwe na exam 21 buri exam igizwe nibibazo 20, ariko exam yambere ni ubuntu(free) izindi zisigaye bisaba kwishyura.\n 4.Iyo uri kwitoza muri iyi application ukanda mu gisubizo (mu mugambo) iyo ugikoze gihinduka icyatsi naho iyo ucyishe gihinduka umutuku kuko ari ukwitoza uhita ubona igisubizo cyukuri warangiza ugakanda "next" ukajya kukindi kibazo iyo ugeze kucyanyuma ukanda "soza exam" ugahita ubona namanota ugize ugahita ukanda ahanditse "home" ukajya guhitamo indi exam wiga',
              ),
              InstructionItem(
                title: '3. UKO UZASANGA MURI EXAM KURI MACHINE BIMEZE',
                description:
                    "1.Nugera muri exam ya provisoire kuri machine uzasanga ibi bibazo biri muri iyi application ari nako bimeze muri exam nta kibazo bazakubaza muri exam ya provisoire kitari muri iyi application, Muguhitamo igisubizo  uzakanda MUKAVI ugakomeza kukindi kibazo  ukanze ahanditse next ukomeze n'ibindi bibazo iyo ubirangije uzakanda ahanditse ``SOZA EXAM`` uzahita umenya amanota ugize Ako kanya  ndetse ushatse wanagenzura ibyo wishe ndetse nibyo wakoze.\n2. Aho bitaniye no muri exam ya provoire kuri machine nuko hano iyo ucyishe bakwereka igisubizo cy'ukuri hasi kandi ahandi utakibona",
              ),
              InstructionItem(
                title: '4.KWISHYURA KUGIRA NGO IBIZAMINI BYOSE BIFUNGUKE',
                description:
                    '1. Nkuko nabisobanuye bwa mbere exam yambere ni ubuntu izindi 20 bisaba kwishyura 1500 RWF kuri 0788659575/0728877442 cg kuri MOMO PAY:329494 ibaruye kuri ALEXIS.\n 2.Iyo umaze kwishyura uhite ureba niba ufite connection (internet) ugahita ufungura exam ugakanda ahanditse saba code  ya application mwibara ryuburu ubundi ugakanda ahanditse saba code mwibara rya umuhondo ugahita usubira inyuma ugategereza iminota itanu ugatangira ukiga usanga byafungutse.',
              ),
              InstructionItems(
                title: '4. IBINDI BISABANURO BIRAMBUYE',
                phoneNumbers: ['0788659575', '0728877442'],
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: shareApp, // Call the shareApp function
                leading: IconButton(
                  onPressed: shareApp, // Call the shareApp function
                  icon: const Icon(
                    Icons.share,
                    size: 30,
                    color: Colors.blueAccent,
                  ),
                ),
                contentPadding: const EdgeInsets.only(
                  left: 60,
                  top: 5,
                  bottom: 5,
                ),
                title: const Text(
                  "Sangiza application",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String title;
  final String description;

  InstructionItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          description,
          style: TextStyle(fontSize: 14),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
