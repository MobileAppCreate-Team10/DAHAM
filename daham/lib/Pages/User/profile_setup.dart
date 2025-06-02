import 'package:daham/Provider/appstate.dart';
import 'package:daham/Provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class ProfileSetup extends StatelessWidget {
  const ProfileSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('profile_setup'), UserInfoTextForm()],
        ),
      ),
    );
  }
}

class UserInfoTextForm extends StatefulWidget {
  const UserInfoTextForm({super.key});

  @override
  State<UserInfoTextForm> createState() => _UserInfoTextFormState();
}

class _UserInfoTextFormState extends State<UserInfoTextForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'UserProfile');
  final _userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Consumer<AppState>(
              builder: (context, appState, child) {
                return Text('AppState: ${appState.user?.uid.toString()}');
              },
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
            ),
            SizedBox(height: 54),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSubInfo()),
                  );
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

class UserSubInfo extends StatefulWidget {
  const UserSubInfo({super.key});

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
                ).registerUser(uid: uid, userName: 'test');
                await Provider.of<AppState>(
                  context,
                  listen: false,
                ).init(context);
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
          child: Container(
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
