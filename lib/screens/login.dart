import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startup_namer/screens/startup_names.dart';
import '../providers/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var isLoading = false;
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: Builder(builder: (BuildContext context) {
          if (!isLoading) {
            return Form(
                child: Center(
                    child: Column(children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(70.0, 50.0, 70.0, 15.0),
                  child: Text(
                      "Welcome Aboard! please login if you wish to pick a startup name")),
              Padding(
                  padding: const EdgeInsets.fromLTRB(70.0, 10.0, 70.0, 20.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.fromLTRB(70.0, 20.0, 70.0, 40.0),
                  child: TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                    ),
                  )),
              SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.deepPurple;
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    child: const Text('Login'),
                    onPressed: () async {
                      //LOGIN ACTION:
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        bool res = await auth.signIn(
                            emailController.text, passwordController.text);
                        if (res) {
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const StartupNames())).then((value) {
                            setState(() {
                              // refresh state
                            });
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'There was an error logging into the app'),
                            ),
                          );
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } on Exception catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                  )),
              SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ))),
                    child: const Text('New user? Click to sign up'),
                    onPressed: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => _showSignUp(auth));
                    },
                  ))
            ])));
          } else {
            return const SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }));
  }
  Widget _showSignUp(Auth auth) {
    return Form(
        key: key,
        child: SizedBox(
            height: 200,
            child: Column(children: <Widget>[
              const Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text('Please confirm your password below:'))),
              const Divider(),
              Center(
                  child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords must match';
                          }
                          if(passwordController.text.length < 6){
                            return 'Password too short';
                          }
                          return null;
                        },
                        controller: confirmPasswordController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ))),
              Center(
                child: Container(
                  width: 100,
                  height: 40,
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.teal),
                  child: TextButton(
                    onPressed: () async {
                      if (key.currentState!.validate()) {
                        await auth.signUp(
                            emailController.text, passwordController.text);
                        Navigator.pushNamed(context, '/');
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ])));
  }
}
