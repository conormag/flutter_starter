import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_starter/services/models/models.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/services/helpers/helpers.dart';
import 'package:flutter_starter/services/services.dart';

class UpdateProfileUI extends StatefulWidget {
  _UpdateProfileUIState createState() => _UpdateProfileUIState();
}

class _UpdateProfileUIState extends State<UpdateProfileUI> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    //  final AuthProvider authProvider = Provider.of<AuthProvider>(context);
    final labels = AppLocalizations.of(context);
    //final AppStateModel appState = Provider.of<AppStateModel>(context);
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text(labels.auth.updateProfileTitle)),
        body: LoadingScreen(
            child: updateProfileForm(context), inAsyncCall: _loading));
  }
  //_loading = true;
  /* return Scaffold(
        key: _scaffoldKey,
        body: LoadingScreen(
            child: StreamBuilder(
                stream: authProvider.user,
                builder: (context, snapshot) {
                  if ((snapshot.data != null)) {}
                  FirebaseUserAuthModel user = snapshot.data;
                  _name.text = user.displayName;
                  _email.text = user.email;
                  return updateProfileForm(context, user.email);
                }),
            inAsyncCall: _loading));
  }*/

  updateProfileForm(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);
    _name.text = user?.name;
    _email.text = user?.email;
    final labels = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                LogoGraphicHeader(),
                SizedBox(height: 48.0),
                FormInputFieldWithIcon(
                  controller: _name,
                  iconPrefix: CustomIcon.user,
                  labelText: labels.auth.nameFormField,
                  validator: Validator(labels).name,
                  onChanged: (value) => null,
                  onSaved: (value) => _name.text = value,
                ),
                FormVerticalSpace(),
                FormInputFieldWithIcon(
                  controller: _email,
                  iconPrefix: CustomIcon.mail,
                  labelText: labels.auth.emailFormField,
                  validator: Validator(labels).email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => null,
                  onSaved: (value) => _email.text = value,
                ),
                FormVerticalSpace(),
                PrimaryButton(
                    labelText: labels.auth.updateUser,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        UserModel _updatedUser =
                            UserModel(name: _name.text, email: _email.text);
                        _updateUserConfirm(context, _updatedUser, user?.email);
                      }
                    }),
                FormVerticalSpace(),
                LabelButton(
                    labelText: labels.auth.changePasswordLabelButton,
                    onPressed: () => Navigator.pushNamed(
                        context, '/reset-password',
                        arguments: user.email)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _updateUserConfirm(
      BuildContext context, UserModel updatedUser, String oldEmail) async {
    final labels = AppLocalizations.of(context);
    //UserModel _user = Provider.of<UserModel>(context);
    AuthService _auth = AuthService();
    final TextEditingController _password = new TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Text(
              labels.auth.enterPassword,
            ),
            content: FormInputFieldWithIcon(
              controller: _password,
              iconPrefix: CustomIcon.lock,
              labelText: labels.auth.passwordFormField,
              validator: Validator(labels).password,
              obscureText: true,
              onChanged: (value) => null,
              onSaved: (value) => _password.text = value,
              maxLines: 1,
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(labels.auth.cancel.toUpperCase()),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _loading = false;
                  });
                },
              ),
              new FlatButton(
                child: new Text(labels.auth.submit.toUpperCase()),
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  Navigator.of(context).pop();
                  try {
                    await _auth
                        .updateUser(updatedUser, oldEmail, _password.text)
                        .then((result) {
                      setState(() {
                        _loading = false;
                      });

                      if (result == true) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(labels.auth.updateUserSuccessNotice),
                          ),
                        );
                      }
                    });
                  } on PlatformException catch (error) {
                    //List<String> errors = error.toString().split(',');
                    // print("Error: " + errors[1]);
                    print(error.code);
                    String authError;
                    switch (error.code) {
                      case 'ERROR_WRONG_PASSWORD':
                        authError = labels.auth.wrongPasswordNotice;
                        break;
                      default:
                        authError = 'Unknown Error';
                        break;
                    }
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(authError),
                    ));
                    setState(() {
                      _loading = false;
                    });
                  }
                },
              )
            ],
          );
        });
  }
}