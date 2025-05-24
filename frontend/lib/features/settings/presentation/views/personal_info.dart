import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/core/utils/validate_input.dart';
import 'package:flutter_application_2/core/widget/custom_text_form_field.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widget/dialogs.dart';
import '../../../../core/widget/snackabars.dart';
import '../../../home/presentation/manager/user_cubit.dart';
import '../../../home/presentation/manager/user_state.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();
  XFile? imageFile;
  var cubit = getIt<UserCubit>();

  @override
  void initState() {
    super.initState();
    // Always fetch fresh data to keep the edit form updated
    cubit.fetchUserData(forceRefresh: true).then((_) {
      // Populate text fields after data is fetched
      _populateTextFields();
    });
  }

  void _populateTextFields() {
    final user = cubit.currentUser;
    if (user != null) {
      cubit.userNameController.text = user.username ?? '';
      cubit.emailController.text = user.email ?? '';
      cubit.weightController.text = user.weight?.toString() ?? '';
      cubit.heightController.text = user.height?.toString() ?? '';
      cubit.birthDayController.text = user.birthDate ?? '';
      cubit.genderController.text = user.gender ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.navyColor,
        actions: [
          TextButton(
            child: Text('Save', style: TextStyles.semiBold20White),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                cubit.updateUserData(profilePicture: imageFile);
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            _populateTextFields();
          }
          if (state is UserUpdated) {
            Navigator.pop(context);
            Snackbars.showSuccessSnackbar(
                context, "Profile updated successfully");
          }
          if (state is UserUpdating) {
            Dialogs.loadingDialog(context: context);
          }
          if (state is UserError || state is UpdateError) {
            Snackbars.showErrorSnackbar(
                context,
                state is UserError
                    ? state.failure.message
                    : (state as UpdateError).failure.message);
          }
        },
        builder: (context, state) {
          if (state is UserLoading && cubit.currentUser == null) {
            return const Scaffold(
                backgroundColor: ColorManager.navyColor,
                body: Center(child: CircularProgressIndicator()));
          }
          return Scaffold(
            body: _buildBody(),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    ImageProvider<Object> backgroundImageProvider;
    if (imageFile != null) {
      backgroundImageProvider = FileImage(File(imageFile!.path));
    } else if (cubit.currentUser?.avatarUrl != null &&
        cubit.currentUser!.avatarUrl!.isNotEmpty) {
      backgroundImageProvider = NetworkImage(cubit.currentUser!.avatarUrl!);
    } else {
      backgroundImageProvider = const AssetImage(AppImages.profilePhoto);
    }

    return BackgroundTheme(
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: ColorManager.primaryColor,
                  radius: 64,
                  backgroundImage: backgroundImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: ColorManager.primaryColor,
                      radius: 20.0,
                      child: IconButton(
                        onPressed: () {
                          showPictureDialog();
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        color: ColorManager.whiteColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.person_outline,
                    labelText: "Username",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.userNameController,
                        validator: ValidateInput.username)),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.alternate_email,
                    labelText: "Email",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.emailController,
                        validator: ValidateInput.email)),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.calendar_today_outlined,
                    labelText: "Birthday",
                    child: CustomTextFormField(
                        showCalendarIcon: true,
                        hintText: "",
                        controller: cubit.birthDayController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null)),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.height,
                    labelText: "Height",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.heightController,
                        validator: ValidateInput.height)),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.scale,
                    labelText: "Weight",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.weightController,
                        validator: ValidateInput.weight)),
                SizedBox(height: h * 0.012),
                LabelBox(
                    leadingIcon: Icons.male,
                    labelText: "Gender",
                    child: CustomTextFormField(
                      hintText: "",
                      controller: cubit.genderController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Required' : null,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showPictureDialog() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Action'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  getFromCamera();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  getFromGallery();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Gallery'),
              ),
            ],
          );
        });
  }

  getFromGallery() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = XFile(pickedFile.path);
      });
    }
  }

  getFromCamera() async {
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 200,
      maxHeight: 200,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = XFile(pickedFile.path);
      });
    }
  }
}
