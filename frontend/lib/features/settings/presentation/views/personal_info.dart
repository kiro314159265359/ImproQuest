import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/validate_input.dart';
import 'package:flutter_application_2/core/widget/custom_text_form_field.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';

import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  // File? imageFile;
  // final imagePicker = ImagePicker();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.navyColor,
        centerTitle: true,
        title: Text(
          'Personal Info',
          style: TextStyles.styleExtraBold(context,
              fontSize: 38, color: ColorManager.whiteColor),
        ),
      ),
      body: BackgroundTheme(
          child: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 85,
                          backgroundImage:
                              const AssetImage(AppImages.profilePhoto),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: ColorManager.primaryColor,
                              radius: 20.0,
                              child: IconButton(
                                onPressed: () {
                                  // showPictureDialog();
                                },
                                icon: const Icon(Icons.camera_alt_outlined),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        LabelBox(
                            leadingIcon: Icons.person_outline,
                            labelText: "Username",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: userNameController,
                                validator: ValidateInput.username)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.alternate_email,
                            labelText: "Email",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: emailController,
                                validator: ValidateInput.email)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.lock_outline,
                            labelText: "Password",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: passController,
                                validator: ValidateInput.password)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.calendar_today_outlined,
                            labelText: "Birthday",
                            child: CustomTextFormField(
                                showCalendarIcon: true,
                                hintText: "",
                                controller: birthDayController,
                                validator: ValidateInput.birthday)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.height,
                            labelText: "Height",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: heightController,
                                validator: ValidateInput.height)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.scale,
                            labelText: "Weight",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: weightController,
                                validator: ValidateInput.weight)),
                        const SizedBox(height: 20),
                        LabelBox(
                            leadingIcon: Icons.male,
                            labelText: "Gender",
                            child: CustomTextFormField(
                                hintText: "",
                                controller: weightController,
                                validator: ValidateInput.weight)),
                      ])))),
    );
  }

  // Future<void> showPictureDialog() async {
  //   await showDialog<void>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //           title: const Text('Select Action'),
  //           children: [
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 getFromCamera();
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Open Camera'),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 getFromGallery();
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Open Gallery'),
  //             ),
  //           ],
  //         );
  //       });
  // }
  //
  // // get from gallery
  // getFromGallery() async {
  //   final pickedFile = await imagePicker.pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 1800,
  //     maxHeight: 1800,
  //   );
  //   if (pickedFile != null) {
  //     setState(() {
  //       imageFile = File(pickedFile.path);
  //     });
  //   }
  // }
  //
  // // get from camera
  // getFromCamera() async {
  //   final pickedFile = await imagePicker.pickImage(
  //     source: ImageSource.camera,
  //     maxWidth: 1800,
  //     maxHeight: 1800,
  //   );
  //   if (pickedFile != null) {
  //     setState(() {
  //       imageFile = File(pickedFile.path);
  //     });
  //   }
  // }
}
