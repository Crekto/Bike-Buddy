import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../constants.dart';
import '../../../database/entities/documents.dart';
import '../../../database/entities/my_document.dart';
import '../documents_shared_methods.dart';

class EditDrivingLicenseScreen extends StatefulWidget {
  final Documents? documents;
  final Function function;
  const EditDrivingLicenseScreen(
      {super.key, required this.documents, required this.function});

  @override
  State<EditDrivingLicenseScreen> createState() =>
      _EditDrivingLicenseScreenState();
}

class _EditDrivingLicenseScreenState extends State<EditDrivingLicenseScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _previousImages = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driving License"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 55,
              ),
              Text(
                "Edit your Driving License.",
                style: myTextStyleBold,
              ),
              const SizedBox(
                height: 100,
              ),
              FormBuilderImagePicker(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                name: 'image',
                displayCustomType: (obj) =>
                    obj is ApiImage ? obj.imageUrl : obj,
                showDecoration: true,
                maxImages: 2,
                previewAutoSizeWidth: true,
                initialValue: widget.documents?.drivingLicense?.images,
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
                  int currentImages;
                  value == null
                      ? currentImages = 0
                      : currentImages = value.length;
                  if (currentImages > _previousImages) {
                    XFile? cropped = await editImage(value![value.length - 1]);

                    final textRecognizer =
                        TextRecognizer(script: TextRecognitionScript.latin);
                    final InputImage inputImage =
                        InputImage.fromFile(File(cropped!.path));
                    final RecognizedText recognizedText =
                        await textRecognizer.processImage(inputImage);
                    DateTime? expirationDate =
                        extractExpirationDate(recognizedText.text);
                    setState(() {
                      _formKey.currentState?.fields['image']!
                          .value[value.length - 1] = cropped;
                      if (expirationDate != null &&
                          expirationDate.isAfter(DateTime.now())) {
                        _formKey.currentState?.fields['expiration']!
                            .didChange(expirationDate);
                      }
                    });
                  }
                  _previousImages = currentImages;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                      onPrimary: Colors.black,
                      onSurface: myBlueColor,
                      primary: myBlueColor),
                  dialogBackgroundColor: myBackgroundColor,
                ),
                child: FormBuilderDateTimePicker(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    name: 'expiration',
                    initialEntryMode: DatePickerEntryMode.calendar,
                    inputType: InputType.date,
                    initialValue: widget.documents?.drivingLicense?.expiration,
                    format: DateFormat('dd.MM.yyyy'),
                    decoration: InputDecoration(
                      labelText: 'Expiration Date',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _formKey.currentState!.fields['expiration']
                              ?.didChange(null);
                        },
                      ),
                      filled: true,
                      fillColor: myGreyColor,
                    ),
                    validator: (selectedDate) {
                      if (selectedDate == null) {
                        return "This field cannot be empty.";
                      }
                      if (selectedDate.isBefore(DateTime.now())) {
                        return "You must select a date from the future.";
                      }
                      return null;
                    }),
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ));

                          List<String> images = [];
                          var uploadedImages = await _formKey
                              .currentState?.fields['image']!.value;

                          for (var image in uploadedImages) {
                            if (image is XFile) {
                              String fileName = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              Reference reference = FirebaseStorage.instance
                                  .ref()
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .child("documents")
                                  .child("driving_license")
                                  .child(fileName);

                              await reference.putFile(File(image.path));
                              String imageUrl =
                                  await reference.getDownloadURL();
                              images.add(imageUrl);
                            } else {
                              images.add(image);
                            }
                          }

                          final userDoc = FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser?.uid);

                          Documents? documents = widget.documents;

                          documents!.drivingLicense = MyDocument(
                              images,
                              _formKey
                                  .currentState?.fields['expiration']!.value);

                          userDoc.update({"documents": documents.toJson()});

                          scheduleNotifications(
                              200,
                              _formKey
                                  .currentState?.fields['expiration']!.value,
                              "Driving License");

                          widget.function(documents);
                          if (context.mounted) {
                            Navigator.pop(
                              context,
                            );
                            Navigator.pop(
                              context,
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    OutlinedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime? extractExpirationDate(String text) {
    final RegExp datePattern = RegExp(r'4b\.\s*(\d{2}\.\d{2}\.\d{4})');
    final Match? match = datePattern.firstMatch(text);

    if (match != null) {
      String? expirationDate = match[0]?.replaceAll(RegExp(r'4b\.|\s*'), '');
      DateTime? expirationDateTime;
      if (expirationDate != null) {
        expirationDateTime = DateFormat('dd.MM.yyyy').parse(expirationDate);
      }
      return expirationDateTime;
    }

    return null;
  }
}
