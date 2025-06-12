// ignore_for_file: use_build_context_synchronously

import 'package:daham/Pages/Login/log_out_dialog.dart';
import 'package:daham/Provider/appstate.dart';
import 'package:daham/Provider/todo_provider.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ProfileSetup extends StatelessWidget {
  const ProfileSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserPageAppBar(),
      body: Center(child: SafeArea(child: ProfileDetailSetup())),
    );
  }
}

class UserPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const UserPageAppBar({super.key, this.title = "프로필 설정"});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isAnonymous = appState.user?.isAnonymous ?? false;
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: Colors.blue,
      elevation: 2,
      actions: [
        if (isAnonymous)
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              showSignOutDialog(context);
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProfileDetailSetup extends StatefulWidget {
  const ProfileDetailSetup({super.key});

  @override
  State<ProfileDetailSetup> createState() => _ProfileDetailSetupState();
}

class _ProfileDetailSetupState extends State<ProfileDetailSetup> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _userNameController = TextEditingController();
  final _introduceControlloer = TextEditingController();
  var _visibleSubInfo = false;
  var _submitStep = false;
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserState>(context, listen: false);
    final String? _userName = userData.userData['userName'];
    final String? _bio = userData.userData['bio'];
    ElevatedButton nextButton = ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _visibleSubInfo = true;
            _submitStep = true;
          });
        }
      },
      child: Text('Next'),
    );
    ElevatedButton submitButton = ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState?.saveAndValidate() ?? false) {
          final values = _formKey.currentState!.value;

          final avatarJson = await FluttermojiFunctions().encodeMySVGtoString();
          final appState = Provider.of<AppState>(context, listen: false);
          final uid = appState.user?.uid;
          if (uid != null) {
            await Provider.of<UserState>(context, listen: false).registerUser(
              bio: _introduceControlloer.text,
              uid: uid,
              userName: _userNameController.text,
              avatarJson: avatarJson,
              interest: values['interests'], // Pass the selected interests
            );
          }
          appState.init(context);
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: Text('Submit'),
    );
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap:
                  () => {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      body: Column(
                        children: [
                          SizedBox(height: 30),
                          ProfileAvatar(custom: true),
                        ],
                      ),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 2,
                      ),
                    ).show(),
                  },
              child: ProfileAvatar(custom: false),
            ),
            TextFormField(
              decoration: InputDecoration(label: Text('UserName')),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ]),
              controller: _userNameController..text = _userName ?? '',
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(label: Text('BIO')),
              controller: _introduceControlloer..text = _bio ?? '',
            ),
            SizedBox(height: 20),
            SubInfoSector(visibleSubInfo: _visibleSubInfo, formKey: _formKey),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
              child:
                  _submitStep
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => showSubjectEditDialog(context),
                            child: Text('과목 편집'),
                          ),
                          submitButton,
                        ],
                      )
                      : nextButton,
            ),
          ],
        ),
      ),
    );
  }
}

class SubInfoSector extends StatelessWidget {
  const SubInfoSector({
    super.key,
    required bool visibleSubInfo,
    required this.formKey,
  }) : _visibleSubInfo = visibleSubInfo;

  final bool _visibleSubInfo;
  final GlobalKey<FormBuilderState> formKey;
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visibleSubInfo,
      child: Column(
        children: [
          FormBuilderCheckboxGroup<String>(
            name: 'interests',
            decoration: InputDecoration(labelText: '관심있는 사항을 모두 선택하세요'),
            options: [
              FormBuilderChipOption(value: 'Exercise', child: Text('운동')),
              FormBuilderChipOption(value: 'Music', child: Text('음악')),
              FormBuilderChipOption(value: 'Coding', child: Text('코딩')),
              FormBuilderChipOption(
                value: 'Self-Develope',
                child: Text('자기계발'),
              ),
            ],
            validator: FormBuilderValidators.minLength(
              1,
              errorText: '최소 1개 이상 선택하세요',
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final bool custom;

  const ProfileAvatar({super.key, required this.custom});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FluttermojiCircleAvatar(radius: 60),
        if (custom == true) FluttermojiCustomizer(),
      ],
    );
  }
}

void showSubjectEditDialog(BuildContext context) async {
  final todoState = Provider.of<TodoState>(context, listen: false);
  List<String> subjects = List.from(await todoState.fetchSubjects());

  TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('과목 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...subjects.map(
              (subject) => ListTile(
                title: Text(subject),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await todoState.removeSubject(subject);
                    Navigator.of(context).pop();
                    showSubjectEditDialog(context); // 새로고침
                  },
                ),
              ),
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: '새 과목 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    if (controller.text.trim().isNotEmpty) {
                      await todoState.addSubject(controller.text.trim());
                      controller.clear();
                      Navigator.of(context).pop();
                      showSubjectEditDialog(context); // 새로고침
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('닫기'),
          ),
        ],
      );
    },
  );
}
