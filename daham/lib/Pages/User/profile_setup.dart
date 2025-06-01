import 'package:daham/Provider/appstate.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('profile_setup'), ProfileDetailSetup()],
        ),
      ),
    );
  }
}

class ProfileDetailSetup extends StatefulWidget {
  const ProfileDetailSetup({super.key});

  @override
  State<ProfileDetailSetup> createState() => _ProfileDetailSetupState();
}

class _ProfileDetailSetupState extends State<ProfileDetailSetup> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'UserProfile');
  final _userNameController = TextEditingController();
  final _introduceControlloer = TextEditingController();
  var _visibleSubInfo = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 50),
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
                FormBuilderValidators.minLength(3),
              ]),
              controller: _userNameController,
            ),
            SizedBox(height: 12),
            TextFormField(
              decoration: InputDecoration(label: Text('Introduce')),
              controller: _introduceControlloer,
            ),
            SizedBox(height: 54),
            SubInfoSector(visibleSubInfo: _visibleSubInfo, formKey: _formKey),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _visibleSubInfo = true;
                  });
                }
              },
              child: Text('Next'),
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
  final GlobalKey<FormState> formKey;
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
              FormBuilderChipOption(value: 'Trip', child: Text('여행')),
              FormBuilderChipOption(value: 'Book', child: Text('독서')),
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

class UserSubInfo extends StatefulWidget {
  final dynamic userName;

  const UserSubInfo({super.key, required this.userName});

  @override
  State<UserSubInfo> createState() => _UserSubInfoState();
}

class _UserSubInfoState extends State<UserSubInfo> {
  final _formKey = GlobalKey<FormBuilderState>();
  var options = ["Option 1", "Option 2", "Option 3"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            // REGISTER USER
            onPressed: () async {
              final uid =
                  Provider.of<AppState>(context, listen: false).user?.uid;
              if (uid != null) {
                await Provider.of<UserState>(
                  context,
                  listen: false,
                ).registerUser(uid: uid, userName: widget.userName);
              }
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text('skip'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('sub info'),
                FormBuilderRadioGroup(
                  name: '',
                  options:
                      options
                          .map(
                            (option) => FormBuilderFieldOption(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DynamicOptionFormField extends StatelessWidget {
  const DynamicOptionFormField({super.key, required this.options});

  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
      builder: (FormFieldState<dynamic> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: "Select option",
            contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
            border: InputBorder.none,
            errorText: field.errorText,
          ),
          child: SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 30,
              children: options.map((c) => Text(c)).toList(),
              onSelectedItemChanged: (index) {
                field.didChange(options[index]);
              },
            ),
          ),
        );
      },
      name: 'name',
    );
  }
}
