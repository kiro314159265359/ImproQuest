import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/theme/background_theme.dart';
import 'package:flutter_application_2/core/utils/get_it_constants.dart';
import 'package:flutter_application_2/core/utils/validate_input.dart';
import 'package:flutter_application_2/core/widget/custom_text_form_field.dart';
import 'package:flutter_application_2/features/settings/presentation/views/widgets/label_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/color_manger.dart';
import '../../../../core/theme/text_style.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widget/dialogs.dart';
import '../../../home/presentation/manager/user_cubit.dart';
import '../../../home/presentation/manager/user_state.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final formKey = GlobalKey<FormState>();

  var cubit = getIt<UserCubit>();

  @override
  void initState() {
    super.initState();
    getIt<UserCubit>().fetchUserData();
  }

  // void _populateUserData(UserModel user) {
  //   userNameController.text = user.username ?? '';
  //   emailController.text = user.email ?? '';
  //   weightController.text = user.weight?.toString() ?? '';
  //   heightController.text = user.height?.toString() ?? '';
  //   birthDayController.text = user.birthDate ?? '';
  //   genderController.text = user.gender ?? '';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.navyColor,
        centerTitle: true,
        title: Text('Personal Info', style: TextStyles.extraBold38White),
        actions: [
          TextButton(
            child: Text('Save', style: TextStyles.semiBold20White),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                getIt<UserCubit>().updateUserData(
                    // username: userNameController.text,
                    // email: emailController.text,
                    // height: int.tryParse(heightController.text)!,
                    // weight: int.tryParse(weightController.text)!,
                    // gender: genderController.text,
                    // birthDate: isoDate
                    );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            setState(() {
              cubit.userNameController.text = state.user.username ?? '';
              cubit.emailController.text = state.user.email ?? '';
              cubit.weightController.text = state.user.weight?.toString() ?? '';
              cubit.heightController.text = state.user.height?.toString() ?? '';
              cubit.birthDayController.text = state.user.birthDate ?? '';
              cubit.genderController.text = state.user.gender ?? '';
            });
          }
          if (state is UserUpdated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
          if (state is UserUpdating) {
            Dialogs.loadingDialog(context: context);
          }
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
          if (state is UpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
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
                  radius: 85,
                  backgroundImage: const AssetImage(AppImages.profilePhoto),
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
                        color: ColorManager.whiteColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),
                LabelBox(
                    leadingIcon: Icons.person_outline,
                    labelText: "Username",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.userNameController,
                        validator: ValidateInput.username)),
                SizedBox(height: h * 0.025),
                LabelBox(
                    leadingIcon: Icons.alternate_email,
                    labelText: "Email",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.emailController,
                        validator: ValidateInput.email)),
                SizedBox(height: h * 0.025),
                // LabelBox(
                //     leadingIcon: Icons.lock_outline,
                //     labelText: "Password",
                //     child: CustomTextFormField(
                //         hintText: "",
                //         controller: passController,
                //         validator: ValidateInput.password)),
                // const SizedBox(height: 20),
                LabelBox(
                    leadingIcon: Icons.calendar_today_outlined,
                    labelText: "Birthday",
                    child: CustomTextFormField(
                        showCalendarIcon: true,
                        hintText: "",
                        controller: cubit.birthDayController,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null)),
                SizedBox(height: h * 0.025),
                LabelBox(
                    leadingIcon: Icons.height,
                    labelText: "Height",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.heightController,
                        validator: ValidateInput.height)),
                SizedBox(height: h * 0.025),
                LabelBox(
                    leadingIcon: Icons.scale,
                    labelText: "Weight",
                    child: CustomTextFormField(
                        hintText: "",
                        controller: cubit.weightController,
                        validator: ValidateInput.weight)),
                SizedBox(height: h * 0.025),
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
