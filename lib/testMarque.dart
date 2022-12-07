import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:text_scroll/text_scroll.dart';

class TesMarque extends StatefulWidget {
  TesMarque({Key? key}) : super(key: key);

  @override
  State<TesMarque> createState() => _TesMarqueState();
}

class _TesMarqueState extends State<TesMarque> {
  String marqueText = 'Tester1 Tester2';
  List listMarque = ['Tester1', 'Tester2'];
  ScrollController _scrollController = ScrollController();
  scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  var gabung;
  void ulang() {
    setState(() {
      gabung = listMarque.join(' ');
    });
    print(gabung);
  }

  @override
  void initState() {
    super.initState();
    ulang();
    print(marqueText);
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    return Scaffold(
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ElevatedButton(onPressed: (){

          }, child: Text("Ganti")),
          SizedBox(
            height: 50,
            child: Marquee(
              // crossAxisAlignment: CrossAxisAlignment.end,

              text: gabung,
            ),
          ),
          // SizedBox(
          //     height: 40,
          //     child: ListView.builder(
          //       //  controller: _scrollController,
          //       shrinkWrap: true,
          //       // reverse: true,
          //       itemCount: 100,

          //       // physics: NeverScrollableScrollPhysics(),
          //       scrollDirection: Axis.horizontal,
          //       itemBuilder: (context, index) {
          //         return Container(
          //           child: Text(
          //             "Text $index",
          //             style: TextStyle(fontSize: 20),
          //           ),
          //         );
          //       },
          //     )),
        ],
      ),
    );
  }
}
