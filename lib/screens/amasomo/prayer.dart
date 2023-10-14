import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../homepages/notificationtab.dart';

class Prayer extends StatefulWidget {
  const Prayer({Key? key}) : super(key: key);

  @override
  State<Prayer> createState() => _PrayerState();
}

class _PrayerState extends State<Prayer> {
  @override
  Widget build(BuildContext context) {
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
          "Prayer",
          style:
          TextStyle(letterSpacing: 1.25, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const Notifications(),
                ),
              );
            },
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
            child: const Text(

              "Muraho  neza Nitwa Mwarimu Alexis NSHIMIYIMANA Tubahaye ikaze muri iyi ApplicationNje gusaba abanyeshuri biyandikishije nabo nzandikisha bazakorera  Permit ya:- Provisoire- Definitif Categories: A, B, C, D, E, F,...Dusenga IMANA ngo  idufashe twitegure neza tuzakore  ibizamini bya permit Iduhe umusaruro mwiza Izaduhe na minerval (school fees) ibyo dukeneye byose Imana ibyumve ibiduhe Kandi ibiduhere igihe.NDABABWIRA KO HANO KURI IYI APPLICATION DIHURIYEHO TURI ABANTU BAFITE IMYEMERERE ITANDUKANYE ARIKO DUSENGE KUKO (AMASENGESHO NI URUFUNGUZO RWA BYOSE)IMANA niyo dutegereje nitubona ukuboko kw'IMANA TUZATSINDAN.B: umuntu wese uri muri iyi Application n'ushaka kuyizamo ari umwarimu, professor, doctor, abaganga,  umucuruzi, umunyeshuri, umusirikare, umuPolice, abakora mubiro, n'abandi mwese mubyubahiro byanyu MUREKE DUSENGE Imana niyo twiringiye,Uwiteka IMANA yo mu'ijuru turagushimye turaguhimbaje kubw'ineza yawe watugiriye ukaba waturinze uyu munsi n'ahatambutse Kandi ukaba ukomeje kuturinda ataruko umwanzi abishaka tukaba tugihumeka UMWUKA w'abazima Ariko banza utubabarire ibyaha byacu byose twakoze twarakubabaje kugira ngo isengesho ryacu rikugereho rimeze nk'umubavu uhumura neza, Niko tukweretse Ibizamini byacu Ni wowe utanga gutsinda udufashe uduhe twitegure neza  ibyo twiga tubifate ibyo dukeneye  byose ubiduhe (Amafaranga yo kwiga, amainite, MBs, umwanya, n'ibindi,...) Ndetse nitwanatsinda tukabona amapermit uzaduhe akazi keza, ibinyabiziga byacu bwite, n'ibindi,... uzaturinde impanuka twirukanye abazimu n'abadayimoni mubuzima bwacu n'abacu  mu'izina rya YESU niko tubisabye tukwizeye  ko BYOSE urabikora AMEN MURAKOZE Ni Mwarimu NSHIMIYIMANA Alexis0788659575",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,

              ),
            ),
          ),
        ),
      ),
    );
  }
}
