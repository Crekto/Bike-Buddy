import 'package:bike_buddy/screens/bikes/database/entities/documents.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../constants.dart';
import '../documents_shared_methods.dart';
import 'add_id_card_screen.dart';
import 'edit_id_card_screen.dart';

// ignore: must_be_immutable
class IdCardScreen extends StatefulWidget {
  final VoidCallback function;
  Documents? documents;

  IdCardScreen({super.key, required this.documents, required this.function});

  @override
  State<IdCardScreen> createState() => _IdCardScreenState();
}

class _IdCardScreenState extends State<IdCardScreen> {
  List<Widget> imagesWidget = [];

  @override
  void initState() {
    getImagesWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ID Card"),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white),
              cardColor: myGreyColor,
            ),
            child: Visibility(
              visible:
                  widget.documents != null && widget.documents?.idCard != null,
              child: PopupMenuButton<int>(
                onSelected: (item) => handleClick(item),
                offset: Offset(0, AppBar().preferredSize.height),
                itemBuilder: (context) => [
                  const PopupMenuItem<int>(value: 0, child: Text('Edit')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: widget.documents == null || widget.documents?.idCard == null
          ? AddIdCardScreen(
              documents: widget.documents,
              function: refresh,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 14,
                      children: imagesWidget,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 45,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 51, 56, 58),
                              blurRadius: 15,
                              offset: Offset(-4, -4),
                            ),
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 15,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            color: myBackgroundColor,
                            child: Column(
                              children: [
                                Text(
                                  "Expiration date",
                                  style: myTextStyleBold.copyWith(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  DateFormat('dd/M/yyyy').format(
                                      widget.documents!.idCard!.expiration),
                                  style: myTextStyle.copyWith(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 51, 56, 58),
                              blurRadius: 15,
                              offset: Offset(-4, -4),
                            ),
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 15,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            color: myBackgroundColor,
                            child: Column(
                              children: [
                                Text(
                                  "Status: ",
                                  style: myTextStyleBold.copyWith(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                widget.documents!.idCard!.expiration
                                            .compareTo(DateTime.now()) >
                                        0
                                    ? Text("Valid",
                                        style: myTextStyle.copyWith(
                                            fontSize: 20,
                                            color: Colors.lightGreenAccent))
                                    : Text("Expired",
                                        style: myTextStyle.copyWith(
                                            fontSize: 20,
                                            color: Colors.redAccent))
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 45,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 51, 56, 58),
                              blurRadius: 15,
                              offset: Offset(-4, -4),
                            ),
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 15,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                            color: myBackgroundColor,
                            child: Visibility(
                              visible: widget.documents!.idCard!.expiration
                                      .compareTo(DateTime.now()) >
                                  0,
                              child: Column(
                                children: [
                                  Text(
                                    "Expires in:",
                                    style:
                                        myTextStyleBold.copyWith(fontSize: 20),
                                  ),
                                  Text(
                                    calculateDateDifference(DateTime.now(),
                                        widget.documents!.idCard!.expiration),
                                    style: myTextStyle.copyWith(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void getImagesWidget() {
    imagesWidget = [];

    if (widget.documents != null && widget.documents?.idCard != null) {
      for (var image in widget.documents!.idCard!.images) {
        imagesWidget.add(GestureDetector(
          onTap: () {
            showImageViewer(context, Image.network(image).image,
                swipeDismissible: false);
          },
          child: Container(
            height: 160,
            width: 320,
            decoration: BoxDecoration(
                image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.network(image).image,
            )),
          ),
        ));
      }
    }
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditIdCardScreen(
                      documents: widget.documents,
                      function: refresh,
                    )));

        break;
    }
  }

  void refresh(Documents documents) {
    setState(() {
      widget.documents = documents;
      getImagesWidget();
      widget.function();
    });
  }
}
