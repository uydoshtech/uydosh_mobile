import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class _StationLabel {
  const _StationLabel({
    required this.stationId,
    required this.label,
    required this.x,
    required this.y,
  });

  final int stationId;
  final String label;
  final double x;
  final double y;
}

class AdminSubwayMapScreen extends StatefulWidget {
  const AdminSubwayMapScreen({super.key});

  @override
  State<AdminSubwayMapScreen> createState() => _AdminSubwayMapScreenState();
}

class _AdminSubwayMapScreenState extends State<AdminSubwayMapScreen> {
  Key _mapKey = UniqueKey();

  static const double _svgWidth = 640;
  static const double _svgHeight = 1200;
  static const double _viewBoxMinX = -80;
  static const Offset _mapOffset = Offset(40, 80);
  static const double _tapTargetWidth = 140;
  static const double _tapTargetHeight = 26;
  static const double _initialMapShiftX = -20;
  static const double _initialMapShiftY = -50;

  static final List<_StationLabel> _stationLabels =
      _extractStationLabels(_rawMapSvg);

  static const String _rawMapSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="520" height="1200" viewBox="-80 0 640 1200" xml:space="default">
  <title>Tashkent metropoliten map</title>
  <defs>
    <style type="text/css">
text {font-family:Arimo,Liberation Sans,Arial,sans-serif}
.title {font-weight:bold;font-family:Tinos,Liberation Serif,Times New Roman,Nimbus Roman No9 L,serif}
.st {font-size:17px}
.mid {text-anchor:middle}
.end {text-anchor:end}
.ic {font-weight:bold}
.small {font-size:10px}
.legendtext {font-size:15px}
.legendst {font-size:12px}
.legendnum {font-weight:bold;font-size:15px}
.mebg {fill:none;stroke:#fff;stroke-width:7}
.me {fill:none;stroke-width:5}
.r1,.f1 {fill:#D60000}
.p1 {stroke:#D60000}
.r2,.f2 {fill:#0300EE}
.p2 {stroke:#0300EE}
.r3,.f3 {fill:#009900}
.p3 {stroke:#009900}
.r4,.f4 {fill:#FFED00}
.p4 {stroke:#FFED00}
.plcr {stroke-linecap:round}
.intb {fill:none;stroke:#000;stroke-width:9;stroke-linecap:round;stroke-linejoin:round}
.intf {fill:none;stroke:#fff;stroke-width:7;stroke-linecap:round;stroke-linejoin:round}
    </style>
    <g id="ele-int"><circle cx="0" cy="0" r="9" style="fill:#fff;stroke:#000;stroke-width:1"/></g>
    <g id="int2">
      <path class="intb" d="M 0,0 L 28,0"/>
      <use xlink:href="#ele-int" x="0" y="0"/>
      <use xlink:href="#ele-int" x="28" y="0"/>
      <path class="intf" d="M 0,0 L 28,0"/>
    </g>
    <g id="int2s">
      <path class="intb" d="M 0,0 L 20,20"/>
      <use xlink:href="#ele-int" x="0" y="0"/>
      <use xlink:href="#ele-int" x="20" y="20"/>
      <path class="intf" d="M 0,0 L 20,20"/>
    </g>
    <g id="intst" style="stroke:none;">
      <circle style="stroke:#000;stroke-width:1.5" cx="0" cy="0" r="6"/>
      <path fill="#000" d="M 0,0 V -2 H 5 L 9.5,0 5,2 H 0"/>
      <circle cx="0" cy="0" r="6"/>
    </g>
    <g id="term"><path style="fill:none;stroke-width:5;" d="M -8,0 L 8,0"/></g>
    <g id="st"><path style="fill:none;stroke-width:5" d="M 8,0 L 0,0"/></g>
    <g id="intst1"><use xlink:href="#intst" class="f1"/></g>
    <g id="term1"><use xlink:href="#term" class="p1"/></g>
    <g id="st1"><use xlink:href="#st" class="p1"/></g>
    <g id="intst2"><use xlink:href="#intst" class="f2"/></g>
    <g id="term2"><use xlink:href="#term" class="p2"/></g>
    <g id="st2"><use xlink:href="#st" class="p2"/></g>
    <g id="intst3"><use xlink:href="#intst" class="f3"/></g>
    <g id="term3"><use xlink:href="#term" class="p3"/></g>
    <g id="st3"><use xlink:href="#st" class="p3"/></g>
    <g id="intst4"><use xlink:href="#intst" class="f4"/></g>
    <g id="st4"><use xlink:href="#st" class="p4"/></g>
  </defs>
  <rect id="background_color_rectangle" x="0" y="0" width="520" height="1200" style="fill:white" stroke="black" stroke-width="3"/>
  <g transform="translate(40,80)">
    <g id="metro_route_group" style="fill:none;cursor:help;opacity:1">
      <g id="metro_route1">
        <title>#1 Чиланзарская линия</title>
        <use id="u_route1" xlink:href="#route1" class="mebg"/>
        <g id="m_route1" class="me p1">
          <path id="route1" d="M 350,200 L 250,300 H 0 V 830"/>
        </g>
      </g>
      <g id="metro_route2">
        <title>#2 Узбекистанская линия</title>
        <use id="u_route2" xlink:href="#route2" class="mebg"/>
        <g id="m_route2" class="me p2">
          <path id="route2" d="M 0,150 L 150,300 V 400 H 350 V 500"/>
        </g>
      </g>
      <g id="metro_route3">
        <title>#3 Юнусабадская линия</title>
        <use id="u_route3" xlink:href="#route3" class="mebg"/>
        <g id="m_route3" class="me p3">
          <path id="route3" d="M 250,0 V 370"/>
        </g>
      </g>
      <g id="metro_route4">
        <title>#4 Линия имени 30-летия независимости Узбекистана</title>
        <use id="u_route4" xlink:href="#route4" class="mebg"/>
        <g id="m_route4" class="me p4">
          <path id="route4" d="M 350,530 V 850 H 20"/>
        </g>
      </g>
    </g>
    <g id="interchange_group" style="opacity:1">
      <use xlink:href="#int2" transform="translate(122,272)rotate(90)" id="Alisher-Navoi-Pakhtakor"/>
      <use xlink:href="#int2s" transform="translate(230,300)" id="Amir-Temur-khiyoboni-Yunus-Radzhabi"/>
      <use xlink:href="#int2" transform="translate(250,372)rotate(90)" id="Mingurik-Oybek"/>
      <use xlink:href="#int2" transform="translate(350,500)rotate(90)" id="Dustlik-Tekhnopark"/>
      <use xlink:href="#int2s" transform="translate(0,830)" id="Chinor-Kipchok"/>
    </g>
    <g id="station_nodes_group" style="opacity:1">
      <g id="station_nodes_route1">
        <use xlink:href="#term1" transform="translate(350,200)rotate(-135)" id="Buyuk-Ipak-Yuli"/>
        <use xlink:href="#st1" transform="translate(320,230)rotate(45)" id="Pushkin"/>
        <use xlink:href="#st1" transform="translate(290,260)rotate(45)" id="Khamid-Olimzhon"/>
        <use xlink:href="#intst1" transform="translate(230,300)" id="Amir-Temur-khiyoboni"/>
        <use xlink:href="#st1" transform="translate(195,300)rotate(-90)" id="Ploshchad-Mustakillik"/>
        <use xlink:href="#intst1" transform="translate(122,300)rotate(-150)" id="Pakhtakor"/>
        <use xlink:href="#st1" transform="translate(0,330) scale(-1,1)" id="Khalklar-dustligi"/>
        <use xlink:href="#st1" transform="translate(0,380) scale(-1,1)" id="Milliy-Bog"/>
        <use xlink:href="#st1" transform="translate(0,430) scale(-1,1)" id="Novza"/>
        <use xlink:href="#st1" transform="translate(0,480) scale(-1,1)" id="Mirzo-Ulugbek"/>
        <use xlink:href="#st1" transform="translate(0,530) scale(-1,1)" id="Chilonzor"/>
        <use xlink:href="#st1" transform="translate(0,580) scale(-1,1)" id="Olmazor"/>
        <use xlink:href="#st1" transform="translate(0,630) scale(-1,1)" id="Choshtepa"/>
        <use xlink:href="#st1" transform="translate(0,680) scale(-1,1)" id="Uzgarish"/>
        <use xlink:href="#st1" transform="translate(0,730) scale(-1,1)" id="Sergeli"/>
        <use xlink:href="#st1" transform="translate(0,780) scale(-1,1)" id="Yangikhayot"/>
        <use xlink:href="#intst1" transform="translate(0,830)" id="Chinor"/>
      </g>
      <g id="station_nodes_route2">
        <use xlink:href="#term2" transform="translate(0,150)rotate(135)" id="Beruni"/>
        <use xlink:href="#st2" transform="translate(30,180)rotate(-45)" id="Tinchlik"/>
        <use xlink:href="#st2" transform="translate(60,210)rotate(-45)" id="Chorsu"/>
        <use xlink:href="#st2" transform="translate(90,240)rotate(-45)" id="Gafur-Gulyam"/>
        <use xlink:href="#intst2" transform="translate(122,272)rotate(-180)" id="Alisher-Navoi"/>
        <use xlink:href="#st2" transform="translate(150,350)rotate(180)" id="Uzbekiston"/>
        <use xlink:href="#st2" transform="translate(200,400)rotate(90)" id="Kosmonavtlar"/>
        <use xlink:href="#intst2" transform="translate(250,400)rotate(90)" id="Oybek"/>
        <use xlink:href="#st2" transform="translate(330,400)rotate(-90)" id="Toshkent"/>
        <use xlink:href="#st2" transform="translate(350,450)" id="Mashinasozlar"/>
        <use xlink:href="#intst2" transform="translate(350,500)" id="Dustlik"/>
      </g>
      <g id="station_nodes_route3">
        <use xlink:href="#term3" transform="translate(250,0)rotate(180)" id="Turkiston"/>
        <use xlink:href="#st3" transform="translate(250,50)" id="Yunusobod"/>
        <use xlink:href="#st3" transform="translate(250,100)" id="Shakhriston"/>
        <use xlink:href="#st3" transform="translate(250,150)" id="Bodomzor"/>
        <use xlink:href="#st3" transform="translate(250,200)" id="Minor"/>
        <use xlink:href="#st3" transform="translate(250,250)rotate(180)" id="Abdulla-Kadyri"/>
        <use xlink:href="#intst3" transform="translate(250,320)" id="Yunus-Radzhabi"/>
        <use xlink:href="#intst3" transform="translate(250,372)rotate(-45)" id="Mingurik"/>
      </g>
      <g id="station_nodes_route4">
        <use xlink:href="#intst4" transform="translate(350,528)" id="Tekhnopark"/>
        <use xlink:href="#st4" transform="translate(350,580)" id="Yashnobod"/>
        <use xlink:href="#st4" transform="translate(350,630)" id="Tuzel"/>
        <use xlink:href="#st4" transform="translate(350,680)" id="Olmos"/>
        <use xlink:href="#st4" transform="translate(350,730)" id="Rokhat"/>
        <use xlink:href="#st4" transform="translate(350,780)" id="Yangiobod"/>
        <use xlink:href="#st4" transform="translate(350,830)" id="Kuylyuk"/>
        <use xlink:href="#st4" transform="translate(320,850)rotate(90)" id="Matonat"/>
        <use xlink:href="#st4" transform="translate(270,850)rotate(-90)" id="Kiyot"/>
        <use xlink:href="#st4" transform="translate(220,850)rotate(90)" id="Tolaryk"/>
        <use xlink:href="#st4" transform="translate(170,850)rotate(-90)" id="Khonobod"/>
        <use xlink:href="#st4" transform="translate(120,850)rotate(90)" id="Kurivchilar"/>
        <use xlink:href="#st4" transform="translate(70,850)rotate(-90)" id="Turon"/>
        <use xlink:href="#intst4" transform="translate(20,850)rotate(90)" id="Kipchok"/>
      </g>
    </g>
    <g id="route_terminus_num_group" class="ic mid" style="font-size:12px">
      <g class="r1">
        <switch transform="translate(355,195)"><text id="trsvg1149-ru" systemLanguage="ru"><tspan id="trsvg1078-ru">1</tspan></text><text id="trsvg1149-en" systemLanguage="en"><tspan id="trsvg1078-en">1</tspan></text><text id="trsvg1149-uz" systemLanguage="uz"><tspan id="trsvg1078-uz">1</tspan></text><text id="trsvg1149"><tspan id="trsvg1078">1</tspan></text></switch>
      </g>
      <g class="r2">
        <switch transform="translate(-5,145)"><text id="trsvg1150-ru" systemLanguage="ru"><tspan id="trsvg1079-ru">2</tspan></text><text id="trsvg1150-en" systemLanguage="en"><tspan id="trsvg1079-en">2</tspan></text><text id="trsvg1150-uz" systemLanguage="uz"><tspan id="trsvg1079-uz">2</tspan></text><text id="trsvg1150"><tspan id="trsvg1079">2</tspan></text></switch>
      </g>
      <g class="r3">
        <switch transform="translate(235,5)"><text id="trsvg1151-ru" systemLanguage="ru"><tspan id="trsvg1080-ru">3</tspan></text><text id="trsvg1151-en" systemLanguage="en"><tspan id="trsvg1080-en">3</tspan></text><text id="trsvg1151-uz" systemLanguage="uz"><tspan id="trsvg1080-uz">3</tspan></text><text id="trsvg1151"><tspan id="trsvg1080">3</tspan></text></switch>
      </g>
    </g>
    <g id="ic_num_group">
      <g id="ic_num_white_big" class="ic mid" transform="translate(0,4)" style="font-size:10px;fill:#fff">
        <g id="route1_ic_num_white_big">
          <switch transform="translate(230,300)"><text id="Amir-Temur-khiyoboni-ic1-ru" systemLanguage="ru"><tspan id="trsvg1081-ru">1</tspan></text><text id="Amir-Temur-khiyoboni-ic1-en" systemLanguage="en"><tspan id="trsvg1081-en">1</tspan></text><text id="Amir-Temur-khiyoboni-ic1-uz" systemLanguage="uz"><tspan id="trsvg1081-uz">1</tspan></text><text id="Amir-Temur-khiyoboni-ic1"><tspan id="trsvg1081">1</tspan></text></switch>
          <switch transform="translate(122,300)"><text id="Pakhtakor-ic1-ru" systemLanguage="ru"><tspan id="trsvg1082-ru">1</tspan></text><text id="Pakhtakor-ic1-en" systemLanguage="en"><tspan id="trsvg1082-en">1</tspan></text><text id="Pakhtakor-ic1-uz" systemLanguage="uz"><tspan id="trsvg1082-uz">1</tspan></text><text id="Pakhtakor-ic1"><tspan id="trsvg1082">1</tspan></text></switch>
          <switch transform="translate(0,830)"><text id="Chinor-ic1-ru" systemLanguage="ru"><tspan id="trsvg1083-ru">1</tspan></text><text id="Chinor-ic1-en" systemLanguage="en"><tspan id="trsvg1083-en">1</tspan></text><text id="Chinor-ic1-uz" systemLanguage="uz"><tspan id="trsvg1083-uz">1</tspan></text><text id="Chinor-ic1"><tspan id="trsvg1083">1</tspan></text></switch>
        </g>
        <g id="route2_ic_num_white_big">
          <switch transform="translate(122,272)"><text id="Alisher-Navoi-ic2-ru" systemLanguage="ru"><tspan id="trsvg1084-ru">2</tspan></text><text id="Alisher-Navoi-ic2-en" systemLanguage="en"><tspan id="trsvg1084-en">2</tspan></text><text id="Alisher-Navoi-ic2-uz" systemLanguage="uz"><tspan id="trsvg1084-uz">2</tspan></text><text id="Alisher-Navoi-ic2"><tspan id="trsvg1084">2</tspan></text></switch>
          <switch transform="translate(250,400)"><text id="Oybek-ic2-ru" systemLanguage="ru"><tspan id="trsvg1085-ru">2</tspan></text><text id="Oybek-ic2-en" systemLanguage="en"><tspan id="trsvg1085-en">2</tspan></text><text id="Oybek-ic2-uz" systemLanguage="uz"><tspan id="trsvg1085-uz">2</tspan></text><text id="Oybek-ic2"><tspan id="trsvg1085">2</tspan></text></switch>
          <switch transform="translate(350,500)"><text id="Dustlik-ic2-ru" systemLanguage="ru"><tspan id="trsvg1086-ru">2</tspan></text><text id="Dustlik-ic2-en" systemLanguage="en"><tspan id="trsvg1086-en">2</tspan></text><text id="Dustlik-ic2-uz" systemLanguage="uz"><tspan id="trsvg1086-uz">2</tspan></text><text id="Dustlik-ic2"><tspan id="trsvg1086">2</tspan></text></switch>
        </g>
        <g id="route3_ic_num_white_big">
          <switch transform="translate(250,320)"><text id="Yunus-Radzhabi-ic3-ru" systemLanguage="ru"><tspan id="trsvg1087-ru">3</tspan></text><text id="Yunus-Radzhabi-ic3-en" systemLanguage="en"><tspan id="trsvg1087-en">3</tspan></text><text id="Yunus-Radzhabi-ic3-uz" systemLanguage="uz"><tspan id="trsvg1087-uz">3</tspan></text><text id="Yunus-Radzhabi-ic3"><tspan id="trsvg1087">3</tspan></text></switch>
          <switch transform="translate(250,372)"><text id="Mingurik-ic3-ru" systemLanguage="ru"><tspan id="trsvg1088-ru">3</tspan></text><text id="Mingurik-ic3-en" systemLanguage="en"><tspan id="trsvg1088-en">3</tspan></text><text id="Mingurik-ic3-uz" systemLanguage="uz"><tspan id="trsvg1088-uz">3</tspan></text><text id="Mingurik-ic3"><tspan id="trsvg1088">3</tspan></text></switch>
        </g>
      </g>
      <g id="ic_num_black_big" class="ic mid" transform="translate(0,4)" style="font-size:10px;fill:#000">
        <g id="route4_ic_num_white_big">
          <switch transform="translate(350,528)"><text id="Tekhnopark-ic4-ru" systemLanguage="ru"><tspan id="trsvg1089-ru">4</tspan></text><text id="Tekhnopark-ic4-en" systemLanguage="en"><tspan id="trsvg1089-en">4</tspan></text><text id="Tekhnopark-ic4-uz" systemLanguage="uz"><tspan id="trsvg1089-uz">4</tspan></text><text id="Tekhnopark-ic4"><tspan id="trsvg1089">4</tspan></text></switch>
          <switch transform="translate(20,850)"><text id="Kipchok-ic4-ru" systemLanguage="ru"><tspan id="trsvg1090-ru">4</tspan></text><text id="Kipchok-ic4-en" systemLanguage="en"><tspan id="trsvg1090-en">4</tspan></text><text id="Kipchok-ic4-uz" systemLanguage="uz"><tspan id="trsvg1090-uz">4</tspan></text><text id="Kipchok-ic4"><tspan id="trsvg1090">4</tspan></text></switch>
        </g>
      </g>
    </g>
    <g id="stname_group" transform="translate(0,4)">
      <use id="u_stname" xlink:href="#stname" class="st" style="stroke:#fff;stroke-width:3;stroke-linejoin:round"/>
      <g id="stname" class="st">
        <g id="route1_stname">
          <switch transform="translate(350,217)"><text id="trsvg1152-ru" systemLanguage="ru"><tspan id="trsvg1091-ru">Буюк Ипак Йули</tspan></text><text id="trsvg1152-en" systemLanguage="en"><tspan id="trsvg1091-en">Buyuk ipak yuli</tspan></text><text id="trsvg1152-uz" systemLanguage="uz"><tspan id="trsvg1091-uz">Buyuk ipak yoʻli</tspan></text><text id="trsvg1152"><tspan id="trsvg1091">Buyuk ipak yoʻli</tspan></text></switch>
          <switch transform="translate(328,240)"><text id="trsvg1153-ru" systemLanguage="ru"><tspan id="trsvg1092-ru"> Пушкин</tspan></text><text id="trsvg1153-en" systemLanguage="en"><tspan id="trsvg1092-en">Pushkin</tspan></text><text id="trsvg1153-uz" systemLanguage="uz"><tspan id="trsvg1092-uz">Pushkin</tspan></text><text id="trsvg1153"><tspan id="trsvg1092">Pushkin</tspan></text></switch>
          <switch transform="translate(299,268)"><text id="trsvg1154-ru" systemLanguage="ru"><tspan id="trsvg1093-ru">Х. Олимжон</tspan></text><text id="trsvg1154-en" systemLanguage="en"><tspan id="trsvg1093-en">Hamid Olimjon</tspan></text><text id="trsvg1154-uz" systemLanguage="uz"><tspan id="trsvg1093-uz">Hamid Olimjon</tspan></text><text id="trsvg1154"><tspan id="trsvg1093">Hamid Olimjon</tspan></text></switch>
          <g class="ic r1">
            <switch transform="translate(260,300)"><text id="trsvg1155-ru" systemLanguage="ru"><tspan id="trsvg1094-ru">Амир Темур</tspan></text><text id="trsvg1155-en" systemLanguage="en"><tspan id="trsvg1094-en">Amir Temur Avenue</tspan></text><text id="trsvg1155-uz" systemLanguage="uz"><tspan id="trsvg1094-uz">Amir Temur xiyoboni</tspan></text><text id="trsvg1155"><tspan id="trsvg1094">Amir Temur xiyoboni</tspan></text></switch>
          </g>
          <switch transform="translate(142,282)"><text id="trsvg1156-ru" systemLanguage="ru"><tspan id="trsvg1095-ru">Мустакиллик</tspan></text><text id="trsvg1156-en" systemLanguage="en"><tspan id="trsvg1095-en">Mustaqilliq Square</tspan></text><text id="trsvg1156-uz" systemLanguage="uz"><tspan id="trsvg1095-uz">Mustaqillik maydoni</tspan></text><text id="trsvg1156"><tspan id="trsvg1095">Mustaqillik maydoni</tspan></text></switch>
          <g class="ic r1">
            <g class="end">
              <switch transform="translate(112,288)"><text id="trsvg1157-ru" systemLanguage="ru"><tspan id="trsvg1096-ru">Пахтакор</tspan></text><text id="trsvg1157-en" systemLanguage="en"><tspan id="trsvg1096-en">Parhtakor</tspan></text><text id="trsvg1157-uz" systemLanguage="uz"><tspan id="trsvg1096-uz">Paxtakor</tspan></text><text id="trsvg1157"><tspan id="trsvg1096">Paxtakor</tspan></text></switch>
            </g>
          </g>
          <g class="end">
            <switch transform="translate(-12,330)"><text id="trsvg1158-ru" systemLanguage="ru"><tspan id="trsvg1097-ru">X. Дустлиги</tspan></text><text id="trsvg1158-en" systemLanguage="en"><tspan id="trsvg1097-en">Halklar dustligi</tspan></text><text id="trsvg1158-uz" systemLanguage="uz"><tspan id="trsvg1097-uz">Xalqlar doʻstligi</tspan></text><text id="trsvg1158"><tspan id="trsvg1097">Xalqlar doʻstligi</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,380)"><text id="trsvg1159-ru" systemLanguage="ru"><tspan id="trsvg1098-ru">Миллий Бог</tspan></text><text id="trsvg1159-en" systemLanguage="en"><tspan id="trsvg1098-en">Milliy bogh</tspan></text><text id="trsvg1159-uz" systemLanguage="uz"><tspan id="trsvg1098-uz">Milliy bogʻ</tspan></text><text id="trsvg1159"><tspan id="trsvg1098">Milliy bogʻ</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,430)"><text id="trsvg1160-ru" systemLanguage="ru"><tspan id="trsvg1099-ru">Новза</tspan></text><text id="trsvg1160-en" systemLanguage="en"><tspan id="trsvg1099-en">Nowza</tspan></text><text id="trsvg1160-uz" systemLanguage="uz"><tspan id="trsvg1099-uz">Novza</tspan></text><text id="trsvg1160"><tspan id="trsvg1099">Novza</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,480)"><text id="trsvg1161-ru" systemLanguage="ru"><tspan id="trsvg1100-ru">М. Улугбек</tspan></text><text id="trsvg1161-en" systemLanguage="en"><tspan id="trsvg1100-en">Mirzo Ulugbek</tspan></text><text id="trsvg1161-uz" systemLanguage="uz"><tspan id="trsvg1100-uz">Mirzo Ulugʻbek</tspan></text><text id="trsvg1161"><tspan id="trsvg1100">Mirzo Ulugʻbek</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,530)"><text id="trsvg1162-ru" systemLanguage="ru"><tspan id="trsvg1101-ru">Чилонзор</tspan></text><text id="trsvg1162-en" systemLanguage="en"><tspan id="trsvg1101-en">Chilonzor</tspan></text><text id="trsvg1162-uz" systemLanguage="uz"><tspan id="trsvg1101-uz">Chilonzor</tspan></text><text id="trsvg1162"><tspan id="trsvg1101">Chilonzor</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,580)"><text id="trsvg1163-ru" systemLanguage="ru"><tspan id="trsvg1102-ru">Олмазор</tspan></text><text id="trsvg1163-en" systemLanguage="en"><tspan id="trsvg1102-en">Olmazor</tspan></text><text id="trsvg1163-uz" systemLanguage="uz"><tspan id="trsvg1102-uz">Olmazor</tspan></text><text id="trsvg1163"><tspan id="trsvg1102">Olmazor</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,630)"><text id="trsvg1164-ru" systemLanguage="ru"><tspan id="trsvg1103-ru">Чоштепа</tspan></text><text id="trsvg1164-en" systemLanguage="en"><tspan id="trsvg1103-en">Choshtepa</tspan></text><text id="trsvg1164-uz" systemLanguage="uz"><tspan id="trsvg1103-uz">Choshtepa</tspan></text><text id="trsvg1164"><tspan id="trsvg1103">Choshtepa</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,680)"><text id="trsvg1165-ru" systemLanguage="ru"><tspan id="trsvg1104-ru">Узгариш</tspan></text><text id="trsvg1165-en" systemLanguage="en"><tspan id="trsvg1104-en">Uzgarish</tspan></text><text id="trsvg1165-uz" systemLanguage="uz"><tspan id="trsvg1104-uz">Oʻzgarish</tspan></text><text id="trsvg1165"><tspan id="trsvg1104">Oʻzgarish</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,730)"><text id="trsvg1166-ru" systemLanguage="ru"><tspan id="trsvg1105-ru">Сергели</tspan></text><text id="trsvg1166-en" systemLanguage="en"><tspan id="trsvg1105-en">Sergeli</tspan></text><text id="trsvg1166-uz" systemLanguage="uz"><tspan id="trsvg1105-uz">Sergeli</tspan></text><text id="trsvg1166"><tspan id="trsvg1105">Sergeli</tspan></text></switch>
          </g>
          <g class="end">
            <switch transform="translate(-12,780)"><text id="trsvg1167-ru" systemLanguage="ru"><tspan id="trsvg1106-ru">Янгихаёт</tspan></text><text id="trsvg1167-en" systemLanguage="en"><tspan id="trsvg1106-en">Yangihaet</tspan></text><text id="trsvg1167-uz" systemLanguage="uz"><tspan id="trsvg1106-uz">Yangihayot</tspan></text><text id="trsvg1167"><tspan id="trsvg1106">Yangihayot</tspan></text></switch>
          </g>
          <g class="ic r1">
            <g class="end">
              <switch transform="translate(-12,828)"><text id="trsvg1168-ru" systemLanguage="ru"><tspan id="trsvg1107-ru">Чинор</tspan></text><text id="trsvg1168-en" systemLanguage="en"><tspan id="trsvg1107-en">Chinor</tspan></text><text id="trsvg1168-uz" systemLanguage="uz"><tspan id="trsvg1107-uz">Chinor</tspan></text><text id="trsvg1168"><tspan id="trsvg1107">Chinor</tspan></text></switch>
            </g>
          </g>
        </g>
        <g id="route2_stname">
          <switch transform="translate(12,145)"><text id="trsvg1169-ru" systemLanguage="ru"><tspan id="trsvg1108-ru">Беруни</tspan></text><text id="trsvg1169-en" systemLanguage="en"><tspan id="trsvg1108-en">Beruniy</tspan></text><text id="trsvg1169-uz" systemLanguage="uz"><tspan id="trsvg1108-uz">Beruniy</tspan></text><text id="trsvg1169"><tspan id="trsvg1108">Beruniy</tspan></text></switch>
          <switch transform="translate(40,175)"><text id="trsvg1170-ru" systemLanguage="ru"><tspan id="trsvg1109-ru">Тинчлик</tspan></text><text id="trsvg1170-en" systemLanguage="en"><tspan id="trsvg1109-en">Tinchlik</tspan></text><text id="trsvg1170-uz" systemLanguage="uz"><tspan id="trsvg1109-uz">Tinchlik</tspan></text><text id="trsvg1170"><tspan id="trsvg1109">Tinchlik</tspan></text></switch>
          <switch transform="translate(70,205)"><text id="trsvg1171-ru" systemLanguage="ru"><tspan id="trsvg1110-ru">Чорсу</tspan></text><text id="trsvg1171-en" systemLanguage="en"><tspan id="trsvg1110-en">Chorsu</tspan></text><text id="trsvg1171-uz" systemLanguage="uz"><tspan id="trsvg1110-uz">Chorsu</tspan></text><text id="trsvg1171"><tspan id="trsvg1110">Chorsu</tspan></text></switch>
          <switch transform="translate(100,235)"><text id="trsvg1172-ru" systemLanguage="ru"><tspan id="trsvg1111-ru">Г. Гулям</tspan></text><text id="trsvg1172-en" systemLanguage="en"><tspan id="trsvg1111-en">Gafur Ghulyam</tspan></text><text id="trsvg1172-uz" systemLanguage="uz"><tspan id="trsvg1111-uz">Gʻafur Gʻulom</tspan></text><text id="trsvg1172"><tspan id="trsvg1111">Gʻafur Gʻulom</tspan></text></switch>
          <g class="end">
            <g class="ic r2">
              <switch transform="translate(108,272)"><text id="trsvg1173-ru" systemLanguage="ru"><tspan id="trsvg1112-ru">А. Навои</tspan></text><text id="trsvg1173-en" systemLanguage="en"><tspan id="trsvg1112-en">Alisher Navoi</tspan></text><text id="trsvg1173-uz" systemLanguage="uz"><tspan id="trsvg1112-uz">Alisher Navoiy</tspan></text><text id="trsvg1173"><tspan id="trsvg1112">Alisher Navoiy</tspan></text></switch>
            </g>
            <switch transform="translate(140,350)"><text id="trsvg1174-ru" systemLanguage="ru"><tspan id="trsvg1113-ru">Узбекистон</tspan></text><text id="trsvg1174-en" systemLanguage="en"><tspan id="trsvg1113-en">Uzbekistan</tspan></text><text id="trsvg1174-uz" systemLanguage="uz"><tspan id="trsvg1113-uz">Oʻzbekiston</tspan></text><text id="trsvg1174"><tspan id="trsvg1113">Oʻzbekiston</tspan></text></switch>
            <switch transform="translate(205,415)"><text id="trsvg1175-ru" systemLanguage="ru"><tspan id="trsvg1114-ru">Космонавтлар</tspan></text><text id="trsvg1175-en" systemLanguage="en"><tspan id="trsvg1114-en">Kosmonavtlar</tspan></text><text id="trsvg1175-uz" systemLanguage="uz"><tspan id="trsvg1114-uz">Kosmonavtlar</tspan></text><text id="trsvg1175"><tspan id="trsvg1114">Kosmonavtlar</tspan></text></switch>
          </g>
          <g class="ic r2">
            <switch transform="translate(240,418)"><text id="trsvg1176-ru" systemLanguage="ru"><tspan id="trsvg1115-ru">Ойбек</tspan></text><text id="trsvg1176-en" systemLanguage="en"><tspan id="trsvg1115-en">Oybek</tspan></text><text id="trsvg1176-uz" systemLanguage="uz"><tspan id="trsvg1115-uz">Oybek</tspan></text><text id="trsvg1176"><tspan id="trsvg1115">Oybek</tspan></text></switch>
          </g>
          <g class="mid">
            <switch transform="translate(330,385)"><text id="trsvg1177-ru" systemLanguage="ru"><tspan id="trsvg1116-ru">Тошкент</tspan></text><text id="trsvg1177-en" systemLanguage="en"><tspan id="trsvg1116-en">Tashkent</tspan></text><text id="trsvg1177-uz" systemLanguage="uz"><tspan id="trsvg1116-uz">Toshkent</tspan></text><text id="trsvg1177"><tspan id="trsvg1116">Toshkent</tspan></text></switch>
          </g>
          <switch transform="translate(362,450)"><text id="trsvg1178-ru" systemLanguage="ru"><tspan id="trsvg1117-ru">Машинасозлар</tspan></text><text id="trsvg1178-en" systemLanguage="en"><tspan id="trsvg1117-en">Mashinasozlar</tspan></text><text id="trsvg1178-uz" systemLanguage="uz"><tspan id="trsvg1117-uz">Mashinasozlar</tspan></text><text id="trsvg1178"><tspan id="trsvg1117">Mashinasozlar</tspan></text></switch>
          <g class="ic r2">
            <switch transform="translate(362,500)"><text id="trsvg1179-ru" systemLanguage="ru"><tspan id="trsvg1118-ru">Дустлик</tspan></text><text id="trsvg1179-en" systemLanguage="en"><tspan id="trsvg1118-en">Dustlik</tspan></text><text id="trsvg1179-uz" systemLanguage="uz"><tspan id="trsvg1118-uz">Doʻstlik</tspan></text><text id="trsvg1179"><tspan id="trsvg1118">Doʻstlik</tspan></text></switch>
          </g>
        </g>
        <g id="route3_stname">
          <switch transform="translate(260,0)"><text id="trsvg1180-ru" systemLanguage="ru"><tspan id="trsvg1119-ru">Туркистон</tspan></text><text id="trsvg1180-en" systemLanguage="en"><tspan id="trsvg1119-en">Turkiston</tspan></text><text id="trsvg1180-uz" systemLanguage="uz"><tspan id="trsvg1119-uz">Turkiston</tspan></text><text id="trsvg1180"><tspan id="trsvg1119">Turkiston</tspan></text></switch>
          <switch transform="translate(260,50)"><text id="trsvg1181-ru" systemLanguage="ru"><tspan id="trsvg1120-ru">Юнусобод</tspan></text><text id="trsvg1181-en" systemLanguage="en"><tspan id="trsvg1120-en">Yunusobod</tspan></text><text id="trsvg1181-uz" systemLanguage="uz"><tspan id="trsvg1120-uz">Yunusobod</tspan></text><text id="trsvg1181"><tspan id="trsvg1120">Yunusobod</tspan></text></switch>
          <switch transform="translate(260,100)"><text id="trsvg1182-ru" systemLanguage="ru"><tspan id="trsvg1121-ru">Шахристон</tspan></text><text id="trsvg1182-en" systemLanguage="en"><tspan id="trsvg1121-en">Shahristan</tspan></text><text id="trsvg1182-uz" systemLanguage="uz"><tspan id="trsvg1121-uz">Shahriston</tspan></text><text id="trsvg1182"><tspan id="trsvg1121">Shahriston</tspan></text></switch>
          <switch transform="translate(260,150)"><text id="trsvg1183-ru" systemLanguage="ru"><tspan id="trsvg1122-ru">Бодомзор</tspan></text><text id="trsvg1183-en" systemLanguage="en"><tspan id="trsvg1122-en">Bodomzor</tspan></text><text id="trsvg1183-uz" systemLanguage="uz"><tspan id="trsvg1122-uz">Bodomzor</tspan></text><text id="trsvg1183"><tspan id="trsvg1122">Bodomzor</tspan></text></switch>
          <switch transform="translate(260,200)"><text id="trsvg1184-ru" systemLanguage="ru"><tspan id="trsvg1123-ru">Минор</tspan></text><text id="trsvg1184-en" systemLanguage="en"><tspan id="trsvg1123-en">Minor</tspan></text><text id="trsvg1184-uz" systemLanguage="uz"><tspan id="trsvg1123-uz">Minor</tspan></text><text id="trsvg1184"><tspan id="trsvg1123">Minor</tspan></text></switch>
          <g class="end">
            <switch transform="translate(238,250)"><text id="trsvg1185-ru" systemLanguage="ru"><tspan id="trsvg1124-ru">А. Кадыри</tspan></text><text id="trsvg1185-en" systemLanguage="en"><tspan id="trsvg1124-en">Abdulla Kadiri</tspan></text><text id="trsvg1185-uz" systemLanguage="uz"><tspan id="trsvg1124-uz">Abdulla Qodiriy</tspan></text><text id="trsvg1185"><tspan id="trsvg1124">Abdulla Qodiriy</tspan></text></switch>
          </g>
          <g class="ic r3">
            <switch transform="translate(262,320)"><text id="trsvg1186-ru" systemLanguage="ru"><tspan id="trsvg1125-ru">Ю. Раджаби</tspan></text><text id="trsvg1186-en" systemLanguage="en"><tspan id="trsvg1125-en">Yunus Rajabi</tspan></text><text id="trsvg1186-uz" systemLanguage="uz"><tspan id="trsvg1125-uz">Yunus Rajabiy</tspan></text><text id="trsvg1186"><tspan id="trsvg1125">Yunus Rajabiy</tspan></text></switch>
            <switch transform="translate(262,365)"><text id="trsvg1187-ru" systemLanguage="ru"><tspan id="trsvg1126-ru">Мингурик</tspan></text><text id="trsvg1187-en" systemLanguage="en"><tspan id="trsvg1126-en">Mingurik</tspan></text><text id="trsvg1187-uz" systemLanguage="uz"><tspan id="trsvg1126-uz">Mingoʻrik</tspan></text><text id="trsvg1187"><tspan id="trsvg1126">Mingoʻrik</tspan></text></switch>
          </g>
        </g>
        <g id="route4_stname">
          <g class="ic r4">
            <switch transform="translate(362,528)"><text id="trsvg1188-ru" systemLanguage="ru"><tspan id="trsvg1127-ru">Технопарк</tspan></text><text id="trsvg1188-en" systemLanguage="en"><tspan id="trsvg1127-en">Technopark</tspan></text><text id="trsvg1188-uz" systemLanguage="uz"><tspan id="trsvg1127-uz">Texnopark</tspan></text><text id="trsvg1188"><tspan id="trsvg1127">Texnopark</tspan></text></switch>
          </g>
          <switch transform="translate(362,580)"><text id="trsvg1189-ru" systemLanguage="ru"><tspan id="trsvg1128-ru">Яшнобод</tspan></text><text id="trsvg1189-en" systemLanguage="en"><tspan id="trsvg1128-en">Yashnobod</tspan></text><text id="trsvg1189-uz" systemLanguage="uz"><tspan id="trsvg1128-uz">Yashnobod</tspan></text><text id="trsvg1189"><tspan id="trsvg1128">Yashnobod</tspan></text></switch>
          <switch transform="translate(362,630)"><text id="trsvg1190-ru" systemLanguage="ru"><tspan id="trsvg1129-ru">Тузель</tspan></text><text id="trsvg1190-en" systemLanguage="en"><tspan id="trsvg1129-en">Tuzel</tspan></text><text id="trsvg1190-uz" systemLanguage="uz"><tspan id="trsvg1129-uz">Tuzel</tspan></text><text id="trsvg1190"><tspan id="trsvg1129">Tuzel</tspan></text></switch>
          <switch transform="translate(362,680)"><text id="trsvg1191-ru" systemLanguage="ru"><tspan id="trsvg1130-ru">Олмос</tspan></text><text id="trsvg1191-en" systemLanguage="en"><tspan id="trsvg1130-en">Olmos</tspan></text><text id="trsvg1191-uz" systemLanguage="uz"><tspan id="trsvg1130-uz">Olmos</tspan></text><text id="trsvg1191"><tspan id="trsvg1130">Olmos</tspan></text></switch>
          <switch transform="translate(362,730)"><text id="trsvg1192-ru" systemLanguage="ru"><tspan id="trsvg1131-ru">Рохат</tspan></text><text id="trsvg1192-en" systemLanguage="en"><tspan id="trsvg1131-en">Rohat</tspan></text><text id="trsvg1192-uz" systemLanguage="uz"><tspan id="trsvg1131-uz">Rohat</tspan></text><text id="trsvg1192"><tspan id="trsvg1131">Rohat</tspan></text></switch>
          <switch transform="translate(362,780)"><text id="trsvg1193-ru" systemLanguage="ru"><tspan id="trsvg1132-ru">Янгиобод</tspan></text><text id="trsvg1193-en" systemLanguage="en"><tspan id="trsvg1132-en">Yangiabad</tspan></text><text id="trsvg1193-uz" systemLanguage="uz"><tspan id="trsvg1132-uz">Yangiobod</tspan></text><text id="trsvg1193"><tspan id="trsvg1132">Yangiobod</tspan></text></switch>
          <switch transform="translate(362,830)"><text id="trsvg1194-ru" systemLanguage="ru"><tspan id="trsvg1133-ru">Куйлюк</tspan></text><text id="trsvg1194-en" systemLanguage="en"><tspan id="trsvg1133-en">Kuyuluk</tspan></text><text id="trsvg1194-uz" systemLanguage="uz"><tspan id="trsvg1133-uz">Qoʻyliq</tspan></text><text id="trsvg1194"><tspan id="trsvg1133">Qoʻyliq</tspan></text></switch>
          <g class="mid">
            <switch transform="translate(320,870)"><text id="trsvg1195-ru" systemLanguage="ru"><tspan id="trsvg1134-ru">Матонат</tspan></text><text id="trsvg1195-en" systemLanguage="en"><tspan id="trsvg1134-en">Matonat</tspan></text><text id="trsvg1195-uz" systemLanguage="uz"><tspan id="trsvg1134-uz">Matonat</tspan></text><text id="trsvg1195"><tspan id="trsvg1134">Matonat</tspan></text></switch>
            <switch transform="translate(270,830)"><text id="trsvg1196-ru" systemLanguage="ru"><tspan id="trsvg1135-ru">Киёт</tspan></text><text id="trsvg1196-en" systemLanguage="en"><tspan id="trsvg1135-en">Kiyot</tspan></text><text id="trsvg1196-uz" systemLanguage="uz"><tspan id="trsvg1135-uz">Qiyot</tspan></text><text id="trsvg1196"><tspan id="trsvg1135">Qiyot</tspan></text></switch>
            <switch transform="translate(220,870)"><text id="trsvg1197-ru" systemLanguage="ru"><tspan id="trsvg1136-ru">Толарык</tspan></text><text id="trsvg1197-en" systemLanguage="en"><tspan id="trsvg1136-en">Tolarik</tspan></text><text id="trsvg1197-uz" systemLanguage="uz"><tspan id="trsvg1136-uz">Tolariq</tspan></text><text id="trsvg1197"><tspan id="trsvg1136">Tolariq</tspan></text></switch>
            <switch transform="translate(170,830)"><text id="trsvg1198-ru" systemLanguage="ru"><tspan id="trsvg1137-ru">Хонобод</tspan></text><text id="trsvg1198-en" systemLanguage="en"><tspan id="trsvg1137-en">Honobod</tspan></text><text id="trsvg1198-uz" systemLanguage="uz"><tspan id="trsvg1137-uz">Xonobod</tspan></text><text id="trsvg1198"><tspan id="trsvg1137">Xonobod</tspan></text></switch>
            <switch transform="translate(120,870)"><text id="trsvg1199-ru" systemLanguage="ru"><tspan id="trsvg1138-ru">Курувчилар</tspan></text><text id="trsvg1199-en" systemLanguage="en"><tspan id="trsvg1138-en">Kuruvchilar</tspan></text><text id="trsvg1199-uz" systemLanguage="uz"><tspan id="trsvg1138-uz">Quruvchilar</tspan></text><text id="trsvg1199"><tspan id="trsvg1138">Quruvchilar</tspan></text></switch>
          </g>
          <switch transform="translate(70,830)"><text id="trsvg1200-ru" systemLanguage="ru"><tspan id="trsvg1139-ru">Турон</tspan></text><text id="trsvg1200-en" systemLanguage="en"><tspan id="trsvg1139-en">Turon</tspan></text><text id="trsvg1200-uz" systemLanguage="uz"><tspan id="trsvg1139-uz">Turon</tspan></text><text id="trsvg1200"><tspan id="trsvg1139">Turon</tspan></text></switch>
          <g class="ic r4">
            <switch transform="translate(0,870)"><text id="trsvg1201-ru" systemLanguage="ru"><tspan id="trsvg1140-ru">Кипчок</tspan></text><text id="trsvg1201-en" systemLanguage="en"><tspan id="trsvg1140-en">Kichpok</tspan></text><text id="trsvg1201-uz" systemLanguage="uz"><tspan id="trsvg1140-uz">Qipchoq</tspan></text><text id="trsvg1201"><tspan id="trsvg1140">Qipchoq</tspan></text></switch>
          </g>
        </g>
      </g>
    </g>
  </g>
  <g id="title_group" transform="translate(0,0)">
    <path id="title_area" style="fill:#000;stroke:#000;stroke-width:2" d="M -20,60 H 380 a 68,68 0 0,0 48,-20 l 22,-22 a 68,68 0 0,1 48,-20 H -20"/>
    <g id="title_text">
      <g style="fill:#fff">
        <switch transform="translate(10,25)" style="font-size:21px"><text class="title" id="trsvg1202-ru" systemLanguage="ru"><tspan id="trsvg1141-ru">Схема линий Ташкентского метрополитена</tspan></text><text class="title" id="trsvg1202-en" systemLanguage="en"><tspan id="trsvg1141-en">Tashkent Metro map</tspan></text><text class="title" id="trsvg1202-uz" systemLanguage="uz"><tspan id="trsvg1141-uz">Toshkent metro xaritasi</tspan></text><text class="title" id="trsvg1202"><tspan id="trsvg1141">Toshkent metro xaritasi</tspan></text></switch>
        <switch transform="translate(10,45)" style="font-size:18px"><text class="title" id="trsvg1203-ru" systemLanguage="ru"><tspan id="trsvg1142-ru">(по состоянию на март 2025)</tspan></text><text class="title" id="trsvg1203-en" systemLanguage="en"><tspan id="trsvg1142-en">(as of March 2025)</tspan></text><text class="title" id="trsvg1203-uz" systemLanguage="uz"><tspan id="trsvg1142-uz">(2025-yil mart holatiga ko'ra)</tspan></text><text class="title" id="trsvg1203"><tspan id="trsvg1142">(2025-yil mart holatiga ko'ra)</tspan></text></switch>
      </g>
    </g>
  </g>
  <g id="linebox_group" transform="translate(30,970)">
    <path id="baseline" style="stroke-width:2;stroke:#000;fill:#000" d="M 0,0 H 470"/>
    <path id="otherline" style="stroke-width:2;stroke:#000;fill:#000" d="M 0,115 H 470"/>
    <g id="legendg" transform="translate(0,0)">
      <g id="legendg1">
        <g id="legendg1_routecolors" class="me plcr">
          <path id="route1color" d="M 15,17.5 h 42.5" class="p1"/>
          <path id="route2color" d="M 15,37.5 h 42.5" class="p2"/>
          <path id="route3color" d="M 15,57.5 h 42.5" class="p3"/>
          <path id="route4color" d="M 15,82.5 h 42.5" class="p4"/>
        </g>
        <use id="u_route1color" xlink:href="#st1" transform="translate(36.25,17.5)rotate(-90)"/>
        <use id="u_route2color" xlink:href="#st2" transform="translate(36.25,37.5)rotate(-90)"/>
        <use id="u_route3color" xlink:href="#st3" transform="translate(36.25,57.5)rotate(-90)"/>
        <use id="u_route4color" xlink:href="#st4" transform="translate(36.25,82.5)rotate(-90)"/>
        <g id="legendnum1" class="legendnum">
          <g class="r1">
            <switch transform="translate(65,20)"><text id="trsvg1012-ru" systemLanguage="ru"><tspan id="trsvg541-ru">1</tspan></text><text id="trsvg1012-en" systemLanguage="en"><tspan id="trsvg541-en">1</tspan></text><text id="trsvg1012-uz" systemLanguage="uz"><tspan id="trsvg541-uz">1</tspan></text><text id="trsvg1012"><tspan id="trsvg541">1</tspan></text></switch>
          </g>
          <g class="r2">
            <switch transform="translate(65,40)"><text id="trsvg1013-ru" systemLanguage="ru"><tspan id="trsvg542-ru">2</tspan></text><text id="trsvg1013-en" systemLanguage="en"><tspan id="trsvg542-en">2</tspan></text><text id="trsvg1013-uz" systemLanguage="uz"><tspan id="trsvg542-uz">2</tspan></text><text id="trsvg1013"><tspan id="trsvg542">2</tspan></text></switch>
          </g>
          <g class="r3">
            <switch transform="translate(65,60)"><text id="trsvg1014-ru" systemLanguage="ru"><tspan id="trsvg543-ru">3</tspan></text><text id="trsvg1014-en" systemLanguage="en"><tspan id="trsvg543-en">3</tspan></text><text id="trsvg1014-uz" systemLanguage="uz"><tspan id="trsvg543-uz">3</tspan></text><text id="trsvg1014"><tspan id="trsvg543">3</tspan></text></switch>
          </g>
          <g class="r4">
            <switch transform="translate(65,85)"><text id="trsvg1015-ru" systemLanguage="ru"><tspan id="trsvg544-ru">4</tspan></text><text id="trsvg1015-en" systemLanguage="en"><tspan id="trsvg544-en">4</tspan></text><text id="trsvg1015-uz" systemLanguage="uz"><tspan id="trsvg544-uz">4</tspan></text><text id="trsvg1015"><tspan id="trsvg544">4</tspan></text></switch>
          </g>
        </g>
        <g id="legendtext1" class="legendtext">
          <switch transform="translate(80,20)"><text id="trsvg1204-ru" systemLanguage="ru"><tspan id="trsvg1143-ru">Чиланзарская линия</tspan></text><text id="trsvg1204-en" systemLanguage="en"><tspan id="trsvg1143-en">Chilanzar Line</tspan></text><text id="trsvg1204-uz" systemLanguage="uz"><tspan id="trsvg1143-uz">Chilonzor yoʻli</tspan></text><text id="trsvg1204"><tspan id="trsvg1143">Chilonzor yoʻli</tspan></text></switch>
          <switch transform="translate(80,40)"><text id="trsvg1205-ru" systemLanguage="ru"><tspan id="trsvg1144-ru">Узбекистанская линия</tspan></text><text id="trsvg1205-en" systemLanguage="en"><tspan id="trsvg1144-en">Uzbekistan Line</tspan></text><text id="trsvg1205-uz" systemLanguage="uz"><tspan id="trsvg1144-uz">Oʻzbekiston yoʻli</tspan></text><text id="trsvg1205"><tspan id="trsvg1144">Oʻzbekiston yoʻli</tspan></text></switch>
          <switch transform="translate(80,60)"><text id="trsvg1206-ru" systemLanguage="ru"><tspan id="trsvg1145-ru">Юнусабадская линия</tspan></text><text id="trsvg1206-en" systemLanguage="en"><tspan id="trsvg1145-en">Yunusabad Line</tspan></text><text id="trsvg1206-uz" systemLanguage="uz"><tspan id="trsvg1145-uz">Yunusobod yoʻli</tspan></text><text id="trsvg1206"><tspan id="trsvg1145">Yunusobod yoʻli</tspan></text></switch>
          <switch transform="translate(80,80)"><text id="trsvg1207-ru" systemLanguage="ru"><tspan id="trsvg1146-ru">Надземная кольцевая линия</tspan></text><text id="trsvg1207-en" systemLanguage="en"><tspan id="trsvg1146-en">Aboverground ring line</tspan></text><text id="trsvg1207-uz" systemLanguage="uz"><tspan id="trsvg1146-uz">Oʻzbekiston mustaqilligining</tspan></text><text id="trsvg1207"><tspan id="trsvg1146">Oʻzbekiston mustaqilligining</tspan></text></switch>
          <switch transform="translate(80,95)"><text id="trsvg1208-ru" systemLanguage="ru"><tspan id="trsvg1147-ru">30-летие Независимости Узбекистана</tspan></text><text id="trsvg1208-en" systemLanguage="en"><tspan id="trsvg1147-en">30th anniversary of Independence of Uzbekistan</tspan></text><text id="trsvg1208-uz" systemLanguage="uz"><tspan id="trsvg1147-uz">30 yilligi yer usti halqa yoʻli</tspan></text><text id="trsvg1208"><tspan id="trsvg1147">30 yilligi yer usti halqa yoʻli</tspan></text></switch>
        </g>
      </g>
    </g>
    <g id="legendbox_group" class="legendst mid" transform="translate(0,115)" style="opacity:1">
      <use id="u_baselabel" xlink:href="#baselabel"/>
      <g id="line_legendbox_group" transform="translate(0,40)">
        <g id="term_legendbox_group" transform="translate(40,0)">
          <path class="me p1" d="M 0,0 H 310"/>
          <use xlink:href="#term1" transform="translate(0,0)rotate(90)"/>
          <g class="ic r1 mid" style="font-size:12px">
            <switch transform="translate(0,-15)"><text id="trsvg1069-ru" systemLanguage="ru"><tspan id="trsvg599-ru">1</tspan></text><text id="trsvg1069-en" systemLanguage="en"><tspan id="trsvg599-en">1</tspan></text><text id="trsvg1069-uz" systemLanguage="uz"><tspan id="trsvg599-uz">1</tspan></text><text id="trsvg1069"><tspan id="trsvg599">1</tspan></text></switch>
          </g>
          <switch transform="translate(0,25)"><text id="trsvg1070-ru" systemLanguage="ru"><tspan id="trsvg600-ru">Конечная </tspan></text><text id="trsvg1070-en" systemLanguage="en"><tspan id="trsvg600-en">Metro line </tspan></text><text id="trsvg1070-uz" systemLanguage="uz"><tspan id="trsvg600-uz">Oxirgi bekat</tspan></text><text id="trsvg1070"><tspan id="trsvg600">Oxirgi bekat</tspan></text></switch>
          <switch transform="translate(0,40)"><text id="trsvg1071-ru" systemLanguage="ru"><tspan id="trsvg601-ru">станция</tspan></text><text id="trsvg1071-en" systemLanguage="en"><tspan id="trsvg601-en">terminus</tspan></text><text id="trsvg1071-uz" systemLanguage="uz"><tspan id="trsvg601-uz"> </tspan></text><text id="trsvg1071"><tspan id="trsvg601"> </tspan></text></switch>
        </g>
        <g id="st_legendbox_group" transform="translate(150,0)">
          <use xlink:href="#st1" transform="translate(0,0)rotate(90)"/>
          <switch transform="translate(0,25)"><text id="trsvg1072-ru" systemLanguage="ru"><tspan id="trsvg602-ru">Станция </tspan></text><text id="trsvg1072-en" systemLanguage="en"><tspan id="trsvg602-en">Metro line </tspan></text><text id="trsvg1072-uz" systemLanguage="uz"><tspan id="trsvg602-uz">Metro bekati</tspan></text><text id="trsvg1072"><tspan id="trsvg602">Metro bekati</tspan></text></switch>
          <switch transform="translate(0,40)"><text id="trsvg1073-ru" systemLanguage="ru"><tspan id="trsvg603-ru">метро</tspan></text><text id="trsvg1073-en" systemLanguage="en"><tspan id="trsvg603-en">station</tspan></text><text id="trsvg1073-uz" systemLanguage="uz"><tspan id="trsvg603-uz"> </tspan></text><text id="trsvg1073"><tspan id="trsvg603"> </tspan></text></switch>
        </g>
        <g id="int_legendbox_group" transform="translate(280,0)">
          <path class="me plcr p2" d="M -50,-20 H 100 "/>
          <use xlink:href="#int2s" transform="translate(0,0)rotate(-90)"/>
          <use xlink:href="#intst1" transform="translate(0,0)rotate(90)"/>
          <use xlink:href="#intst2" transform="translate(20,-20)rotate(90)"/>
          <g transform="translate(0,3)">
            <g class="ic" style="font-size:10px;fill:#fff">
              <switch transform="translate(0,0)"><text id="trsvg1074-ru" systemLanguage="ru"><tspan id="trsvg604-ru">1</tspan></text><text id="trsvg1074-en" systemLanguage="en"><tspan id="trsvg604-en">1</tspan></text><text id="trsvg1074-uz" systemLanguage="uz"><tspan id="trsvg604-uz">1</tspan></text><text id="trsvg1074"><tspan id="trsvg604">1</tspan></text></switch>
              <switch transform="translate(20,-20)"><text id="trsvg1075-ru" systemLanguage="ru"><tspan id="trsvg605-ru">2</tspan></text><text id="trsvg1075-en" systemLanguage="en"><tspan id="trsvg605-en">2</tspan></text><text id="trsvg1075-uz" systemLanguage="uz"><tspan id="trsvg605-uz">2</tspan></text><text id="trsvg1075"><tspan id="trsvg605">2</tspan></text></switch>
            </g>
          </g>
          <g class="ic">
            <switch transform="translate(0,25)"><text id="trsvg1076-ru" systemLanguage="ru"><tspan id="trsvg606-ru">Станции </tspan></text><text id="trsvg1076-en" systemLanguage="en"><tspan id="trsvg606-en">Interchanges</tspan></text><text id="trsvg1076-uz" systemLanguage="uz"><tspan id="trsvg606-uz">O'tish bekati</tspan></text><text id="trsvg1076"><tspan id="trsvg606">O'tish bekati</tspan></text></switch>
            <switch transform="translate(0,40)"><text id="trsvg1077-ru" systemLanguage="ru"><tspan id="trsvg607-ru">пересадок</tspan></text><text id="trsvg1077-en" systemLanguage="en"><tspan id="trsvg607-en"> </tspan></text><text id="trsvg1077-uz" systemLanguage="uz"><tspan id="trsvg607-uz"> </tspan></text><text id="trsvg1077"><tspan id="trsvg607"> </tspan></text></switch>
          </g>
        </g>
      </g>
    </g>
  </g>
  <g class="small" style="display:none">
    <switch transform="translate(20,1190)"><text id="license_text-ru-ru" systemLanguage="ru"><tspan id="trsvg1148-ru">Image originally created and licensed under the Creative Commons Attribution-Share Alike 4.0</tspan></text><text id="license_text-ru-en" systemLanguage="en"><tspan id="trsvg1148-en">Image originally created and licensed under the Creative Commons Attribution-Share Alike 4.0</tspan></text><text id="license_text-ru-uz" systemLanguage="uz"><tspan id="trsvg1148-uz">Image originally created and licensed under the Creative Commons Attribution-Share Alike 4.0</tspan></text><text id="license_text-ru"><tspan id="trsvg1148">Image originally created and licensed under the Creative Commons Attribution-Share Alike 4.0</tspan></text></switch>
  </g>
</svg>
''';

  static final String _mapSvg = _processSvg(_rawMapSvg);

  static List<_StationLabel> _extractStationLabels(String svg) {
    final labels = <_StationLabel>[];
    final usedStationIds = <int>{};
    final switchRegExp = RegExp(
      r'<switch[^>]*transform="translate\(([-\d.]+),([-\d.]+)\)"[^>]*>([\s\S]*?)</switch>',
    );
    final tspanRegExp = RegExp(r"<tspan[^>]*>([^<]+)</tspan>");

    for (final match in switchRegExp.allMatches(svg)) {
      final x = double.tryParse(match.group(1) ?? "");
      final y = double.tryParse(match.group(2) ?? "");
      final content = match.group(3) ?? "";
      if (x == null || y == null) continue;

      final tspanMatch = tspanRegExp.firstMatch(content);
      final label = tspanMatch?.group(1)?.trim();
      if (label == null || label.isEmpty) continue;

      final station = _findStationByLabel(label);
      if (station == null) continue;
      if (!usedStationIds.add(station.id)) continue;

      labels.add(
        _StationLabel(
          stationId: station.id,
          label: label,
          x: x,
          y: y,
        ),
      );
    }

    return labels;
  }

  static SubwayStation? _findStationByLabel(String label) {
    final matches = MetroCache.getStationsByName(label);
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;

    final normalizedLabel = _normalizeStationLabel(label);
    for (final station in matches) {
      for (final name in _stationNames(station)) {
        if (_normalizeStationLabel(name) == normalizedLabel) {
          return station;
        }
      }
    }

    return matches.first;
  }

  static Iterable<String> _stationNames(SubwayStation station) sync* {
    if (station.nameUz != null) yield station.nameUz!;
    if (station.nameRu != null) yield station.nameRu!;
    if (station.nameEn != null) yield station.nameEn!;
  }

  static String _normalizeStationLabel(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r"[’ʻ'`.]"), "")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  void _openStationListings(BuildContext context, int stationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider(
              create: (context) => ListingsBloc(getIt<IListingService>()),
              child: HomeScreen(
                subwayStationId: stationId,
                isSearchMode: true,
              ),
            ),
      ),
    );
  }

  static const double _bazaarChorsuMapX = 0;
  static const double _bazaarChorsuMapY = 210;
  static const double _bazaarChorsuWidth = 60;
  static const double _bazaarChorsuHeight = 18;

  static const double _tvTowerMapX = 240;
  static const double _tvTowerMapY = 120;
  static const double _tvTowerWidth = 56;
  static const double _tvTowerHeight = 60;

  static const double _monumentMapX = 170;
  static const double _monumentMapY = 330;
  static const double _monumentWidth = 20;
  static const double _monumentHeight = 20;

  static const double _airportMapX = 300;
  static const double _airportMapY = 625;
  static const double _airportWidth = 50;
  static const double _airportHeight = 27;

  List<Widget> _buildMapOverlays(
    double scale,
    double offsetX,
    double offsetY, {
    required bool isBlueTheme,
  }) {
    final bazaarX =
        offsetX + (_mapOffset.dx + _bazaarChorsuMapX - _viewBoxMinX) * scale;
    final bazaarY =
        offsetY + (_mapOffset.dy + _bazaarChorsuMapY) * scale;
    final tvTowerX =
        offsetX + (_mapOffset.dx + _tvTowerMapX - _viewBoxMinX) * scale;
    final tvTowerY =
        offsetY + (_mapOffset.dy + _tvTowerMapY) * scale;
    final monumentX =
        offsetX + (_mapOffset.dx + _monumentMapX - _viewBoxMinX) * scale;
    final monumentY =
        offsetY + (_mapOffset.dy + _monumentMapY) * scale;
    final airportX =
        offsetX + (_mapOffset.dx + _airportMapX - _viewBoxMinX) * scale;
    final airportY =
        offsetY + (_mapOffset.dy + _airportMapY) * scale;
    return [
      Positioned(
        left: bazaarX - _bazaarChorsuWidth / 2,
        top: bazaarY - _bazaarChorsuHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/bazaar_chorsu.svg",
          width: _bazaarChorsuWidth * 2,
          height: _bazaarChorsuHeight * 2,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: tvTowerX - _tvTowerWidth / 2,
        top: tvTowerY - _tvTowerHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/tv_tower.svg",
          width: _tvTowerWidth,
          height: _tvTowerHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
      Positioned(
        left: monumentX - _monumentWidth / 2,
        top: monumentY - _monumentHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/monument.svg",
          width: _monumentWidth * 2,
          height: _monumentHeight * 2,
          fit: BoxFit.contain,
        ),
      ),
      Positioned(
        left: airportX - _airportWidth / 2,
        top: airportY - _airportHeight / 2,
        child: SvgPicture.asset(
          "assets/map_elements/airport.svg",
          width: _airportWidth,
          height: _airportHeight,
          fit: BoxFit.contain,
          colorFilter: isBlueTheme
              ? const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                )
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildStationTapTargets(
    BuildContext context,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    return _stationLabels.map((label) {
      final posX = offsetX + (_mapOffset.dx + label.x - _viewBoxMinX) * scale;
      final posY = offsetY + (_mapOffset.dy + label.y) * scale;
      return Positioned(
        left: posX - _tapTargetWidth / 2,
        top: posY - _tapTargetHeight / 2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openStationListings(context, label.stationId),
          child: const SizedBox(
            width: _tapTargetWidth,
            height: _tapTargetHeight,
          ),
        ),
      );
    }).toList();
  }

  static String _processSvg(String svg) {
    final withoutStyle = svg.replaceAll(
      RegExp(r"<style[\s\S]*?</style>"),
      "",
    );
    final withoutTitleGroup = withoutStyle
        .replaceAll(
          '<g id="title_group"',
          '<g id="title_group" style="display:none"',
        )
        .replaceAll(
          '<g id="linebox_group"',
          '<g id="linebox_group" style="display:none"',
        )
        .replaceAll(
          '<g id="route_terminus_num_group"',
          '<g id="route_terminus_num_group" style="display:none"',
        )
        .replaceAll(
          '<g id="ic_num_group"',
          '<g id="ic_num_group" style="display:none"',
        )
        .replaceAll(
          '<rect id="background_color_rectangle"',
          '<rect id="background_color_rectangle" style="display:none"',
        );
    final flattenedSwitches = withoutTitleGroup.replaceAllMapped(
      RegExp(r"<switch([^>]*)>([\s\S]*?)</switch>"),
      (match) {
        final attributes = match.group(1) ?? "";
        final content = match.group(2) ?? "";
        final firstText = RegExp(r"<text[\s\S]*?</text>").firstMatch(content);
        final textValue = firstText?.group(0);
        if (textValue == null) return "";

        final transformMatch =
            RegExp(r'transform="[^"]+"').firstMatch(attributes);
        if (transformMatch == null) return textValue;

        return '<g ${transformMatch.group(0)}>$textValue</g>';
      },
    );
    return flattenedSwitches
        .replaceAll(
          'class="st"',
          'style="font-family:Arial,sans-serif;font-size:13px"',
        )
        .replaceAll('class="mid"', 'style="text-anchor:middle"')
        .replaceAll('class="end"', 'style="text-anchor:end"')
        .replaceAll('class="ic"', 'style="font-weight:bold"')
        .replaceAll(
          '<g id="route1_stname">',
          '<g id="route1_stname" style="fill:#D60000">',
        )
        .replaceAll(
          '<g id="route2_stname">',
          '<g id="route2_stname" style="fill:#0300EE">',
        )
        .replaceAll(
          '<g id="route3_stname">',
          '<g id="route3_stname" style="fill:#009900">',
        )
        .replaceAll(
          '<g id="route4_stname">',
          '<g id="route4_stname" style="fill:#F59E0B">',
        )
        .replaceAll('class="mebg"', 'style="fill:none;stroke:#fff;stroke-width:7"')
        .replaceAll(
          'class="me p1"',
          'style="fill:none;stroke:#D60000;stroke-width:5"',
        )
        .replaceAll(
          'class="me p2"',
          'style="fill:none;stroke:#0300EE;stroke-width:5"',
        )
        .replaceAll(
          'class="me p3"',
          'style="fill:none;stroke:#009900;stroke-width:5"',
        )
        .replaceAll(
          'class="me p4"',
          'style="fill:none;stroke:#F59E0B;stroke-width:5"',
        )
        .replaceAll('class="p1"', 'style="stroke:#D60000"')
        .replaceAll('class="p2"', 'style="stroke:#0300EE"')
        .replaceAll('class="p3"', 'style="stroke:#009900"')
        .replaceAll('class="p4"', 'style="stroke:#F59E0B"')
        .replaceAll('class="f1"', 'style="fill:#D60000"')
        .replaceAll('class="f2"', 'style="fill:#0300EE"')
        .replaceAll('class="f3"', 'style="fill:#009900"')
        .replaceAll('class="f4"', 'style="fill:#F59E0B"')
        .replaceAll('class="r1"', 'style="fill:#D60000"')
        .replaceAll('class="r2"', 'style="fill:#0300EE"')
        .replaceAll('class="r3"', 'style="fill:#009900"')
        .replaceAll('class="r4"', 'style="fill:#F59E0B"')
        .replaceAll(
          'class="intb"',
          'style="fill:none;stroke:#000;stroke-width:9;stroke-linecap:round;stroke-linejoin:round"',
        )
        .replaceAll(
          'class="intf"',
          'style="fill:none;stroke:#fff;stroke-width:7;stroke-linecap:round;stroke-linejoin:round"',
        );
  }

  static String _getMapSvgForTheme(bool isBlueTheme) {
    return _mapSvg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "admin_subway_map_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _mapKey = UniqueKey();
              });
            },
            tooltip: "Refresh map icons",
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([LanguageState(), ThemeState()]),
        builder: (context, child) {
          final mapSvg = _getMapSvgForTheme(ThemeState().isBlueTheme);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = constraints.maxHeight;
                        final scale = math.min(
                          mapWidth / _svgWidth,
                          mapHeight / _svgHeight,
                        );
                        final contentWidth = _svgWidth * scale;
                        final contentHeight = _svgHeight * scale;
                        final offsetX = (mapWidth - contentWidth) / 2;
                        final offsetY = (mapHeight - contentHeight) / 2;
                        final transformationController =
                            TransformationController(
                              Matrix4.identity()
                                ..translate(_initialMapShiftX, _initialMapShiftY)
                                ..scale(1.3),
                            );
                        return InteractiveViewer(
                          constrained: false,
                          minScale: 0.6,
                          maxScale: 8.0,
                          boundaryMargin: const EdgeInsets.all(40),
                          transformationController: transformationController,
                          child: SizedBox(
                            key: _mapKey,
                            width: mapWidth,
                            height: mapHeight,
                            child: Stack(
                              children: [
                                SvgPicture.string(
                                  mapSvg,
                                  width: mapWidth,
                                  height: mapHeight,
                                  fit: BoxFit.contain,
                                  semanticsLabel: "Tashkent subway map",
                                ),
                                ..._buildMapOverlays(
                                  scale,
                                  offsetX,
                                  offsetY,
                                  isBlueTheme: ThemeState().isBlueTheme,
                                ),
                                ..._buildStationTapTargets(
                                  context,
                                  scale,
                                  offsetX,
                                  offsetY,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
