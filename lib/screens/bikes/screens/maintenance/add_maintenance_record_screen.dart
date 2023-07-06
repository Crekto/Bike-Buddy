import 'dart:io';
import 'package:bike_buddy/screens/bikes/database/entities/maintenance_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../constants.dart';

class AddMaintenanceRecordScreen extends StatefulWidget {
  final VoidCallback function;
  const AddMaintenanceRecordScreen({super.key, required this.function});

  @override
  State<AddMaintenanceRecordScreen> createState() =>
      _AddMaintenanceRecordScreenState();
}

class _AddMaintenanceRecordScreenState
    extends State<AddMaintenanceRecordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  int _previousImages = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Maintenance"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 55,
                ),
                Text(
                  "Add new maintenance record",
                  style: myTextStyleBold,
                ),
                const SizedBox(
                  height: 45,
                ),
                FormBuilderImagePicker(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'image',
                  displayCustomType: (obj) =>
                      obj is ApiImage ? obj.imageUrl : obj,
                  showDecoration: true,
                  maxImages: 8,
                  previewAutoSizeWidth: true,
                  cameraLabel: const Text(
                    "Camera",
                    style: TextStyle(color: Colors.black),
                  ),
                  galleryLabel: const Text(
                    "Gallery",
                    style: TextStyle(color: Colors.black),
                  ),
                  onChanged: (value) async {
                    int currentImages;
                    value == null
                        ? currentImages = 0
                        : currentImages = value.length;
                    if (currentImages > _previousImages) {
                      XFile? cropped =
                          await _editImage(value![value.length - 1]);
                      setState(() {
                        _formKey.currentState?.fields['image']!
                            .value[value.length - 1] = cropped;
                      });
                    }
                    _previousImages = currentImages;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'type',
                  maxLength: 26,
                  decoration: InputDecoration(
                    counterStyle: const TextStyle(color: Colors.white),
                    labelText: "Maintenance Type",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.required(),
                  textInputAction: TextInputAction.next,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'km',
                  decoration: InputDecoration(
                    labelText: 'KM',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                  ]),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 22,
                ),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'description',
                  minLines: 1,
                  maxLines: 99,
                  decoration: InputDecoration(
                    hintText: "Something you may want to remember later",
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelText: "Note",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: myGreyColor,
                  ),
                  textInputAction: TextInputAction.newline,
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
                      name: 'date',
                      initialEntryMode: DatePickerEntryMode.calendar,
                      inputType: InputType.date,
                      initialValue: DateTime.now(),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            _formKey.currentState!.fields['date']
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
                        if (selectedDate.isAfter(DateTime.now())) {
                          return "You cannot select a date from the future.";
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
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ));
                            List<String> images = [];
                            var uploadedImages = await _formKey
                                .currentState?.fields['image']!.value;
                            if (uploadedImages != null) {
                              for (var image in uploadedImages) {
                                String fileName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                Reference reference = FirebaseStorage.instance
                                    .ref()
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .child("documents")
                                    .child("maintenanceRecords")
                                    .child(fileName);

                                await reference.putFile(File(image.path));
                                String imageUrl =
                                    await reference.getDownloadURL();
                                images.add(imageUrl);
                              }
                            }

                            final userDoc = FirebaseFirestore.instance
                                .collection("users")
                                .doc(FirebaseAuth.instance.currentUser?.uid);

                            List<MaintenanceRecord>? maintenanceHistory =
                                await readMaintenanceHistory();

                            DateTime date =
                                _formKey.currentState?.fields['date']!.value;
                            date = DateTime(date.year, date.month, date.day);

                            if (maintenanceHistory == null) {
                              maintenanceHistory = [
                                MaintenanceRecord(
                                    images,
                                    _formKey
                                        .currentState?.fields['type']!.value,
                                    int.parse(_formKey
                                        .currentState?.fields['km']!.value),
                                    _formKey.currentState?.fields['description']
                                        ?.value,
                                    date)
                              ];
                            } else {
                              maintenanceHistory.insert(
                                  0,
                                  MaintenanceRecord(
                                      images,
                                      _formKey
                                          .currentState?.fields['type']!.value,
                                      int.parse(_formKey
                                          .currentState?.fields['km']!.value),
                                      _formKey.currentState
                                          ?.fields['description']?.value,
                                      date));
                            }

                            userDoc.update({
                              "maintenanceRecords": maintenanceHistory
                                  .map((record) => record.toJson())
                                  .toList()
                            });

                            widget.function();
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

Future<XFile?> _editImage(XFile image) async {
  CroppedFile? editedImage =
      await ImageCropper().cropImage(sourcePath: image.path, uiSettings: []);
  if (editedImage == null) return null;
  return XFile(editedImage.path);
}

Future<List<MaintenanceRecord>?> readMaintenanceHistory() async {
  final docUser = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid);
  final snapshot = await docUser.get();
  if (snapshot.exists) {
    List<MaintenanceRecord> tempRecords = [];
    if (snapshot.data()!['maintenanceRecords'] != null) {
      snapshot.data()!['maintenanceRecords'].forEach((record) {
        tempRecords.add(MaintenanceRecord.fromJson(record));
      });
    }
    return tempRecords;
  }
  return null;
}
