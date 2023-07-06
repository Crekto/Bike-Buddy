import 'dart:io';
import 'package:bike_buddy/constants.dart';
import 'package:bike_buddy/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'database/entities/bike.dart';

class EditBikeScreen extends StatefulWidget {
  final VoidCallback function;
  final Bike? bike;
  const EditBikeScreen({super.key, required this.function, required this.bike});

  @override
  State<EditBikeScreen> createState() => _AddBikeScreenState();
}

class _AddBikeScreenState extends State<EditBikeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Edit bike"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                FormBuilderImagePicker(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'image',
                  displayCustomType: (obj) =>
                      obj is ApiImage ? obj.imageUrl : obj,
                  showDecoration: true,
                  maxImages: 1,
                  previewAutoSizeWidth: true,
                  initialValue: [widget.bike!.image],
                  cameraLabel: const Text(
                    "Camera",
                    style: TextStyle(color: Colors.black),
                  ),
                  galleryLabel: const Text(
                    "Gallery",
                    style: TextStyle(color: Colors.black),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: "You must upload a picture."),
                  ]),
                  onChanged: (value) async {
                    XFile? cropped = await _cropImage(value![0]);
                    setState(() {
                      _formKey.currentState?.fields['image']!.value[0] =
                          cropped;
                    });
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'nickname',
                  decoration: InputDecoration(
                    labelText: "Nickname",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onChanged: (val) {
                    debugPrint(
                        val); // debugPrint the text value write into TextField
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  initialValue: widget.bike!.nickname,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'manufacturer',
                  decoration: InputDecoration(
                    labelText: "Manufacturer",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onChanged: (val) {
                    debugPrint(
                        val); // debugPrint the text value write into TextField
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  initialValue: widget.bike!.manufacturer,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'model',
                  decoration: InputDecoration(
                    labelText: "Model",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onChanged: (val) {
                    debugPrint(
                        val); // debugPrint the text value write into TextField
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                  initialValue: widget.bike!.model,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'power',
                  decoration: InputDecoration(
                    labelText: 'Power(KW)',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onChanged: (val) {
                    debugPrint(val);
                  },
                  // valueTransformer: (text) => num.tryParse(text),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  initialValue: widget.bike!.power.toString(),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'year',
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  onChanged: (val) {
                    debugPrint(val);
                  },
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.max(DateTime.now().year,
                        errorText: "Your bike can't be from the future."),
                  ]),
                  initialValue: widget.bike!.year.toString(),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.send,
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ));

                            String imageUrl = widget.bike!.image;
                            if (_formKey.currentState?.fields['image']!.value[0]
                                is XFile) {
                              Reference imageRef = FirebaseStorage.instance
                                  .refFromURL(widget.bike!.image);
                              await imageRef.delete().then(
                                  (value) =>
                                      debugPrint('Image deleted successfully'),
                                  onError: (e) => debugPrint(e.message));

                              String fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();

                              Reference reference = FirebaseStorage.instance
                                  .ref()
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .child("bike")
                                  .child(fileName);

                              await reference.putFile(File(_formKey.currentState
                                  ?.fields['image']!.value[0].path));
                              imageUrl = await reference.getDownloadURL();
                            }

                            final userDoc = FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser?.uid);

                            userDoc.update({
                              "bike": Bike(
                                imageUrl,
                                _formKey
                                    .currentState?.fields['nickname']!.value,
                                _formKey.currentState?.fields['manufacturer']!
                                    .value,
                                _formKey.currentState?.fields['model']!.value,
                                int.parse(_formKey
                                    .currentState?.fields['year']!.value),
                                int.parse(_formKey
                                    .currentState?.fields['power']!.value),
                              ).toJson(),
                            });

                            widget.function();
                            navigatorKey.currentState!
                                .popUntil((route) => route.isFirst);
                          } else {
                            debugPrint(_formKey.currentState?.value.toString());
                            debugPrint('validation failed');
                          }
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApiImage {
  final String imageUrl;
  final String id;
  ApiImage({
    required this.imageUrl,
    required this.id,
  });
}

Future<XFile?> _cropImage(XFile image) async {
  CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      uiSettings: [
        AndroidUiSettings(
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
      ]);
  if (croppedImage == null) return null;
  return XFile(croppedImage.path);
}
