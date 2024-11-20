import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'package:ess_app/state/shared_preference_services.dart';
import 'colors.dart';
import 'dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  var realtoken;
  bool isLoading = false;
  bool _ishidden = true;
  final TextEditingController _userid = TextEditingController();
  final TextEditingController _password = TextEditingController();

  Future<void> authenticate(String userId, String password) async {
    if (_userid.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: const Text("Don't leave user id empty."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (_password.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Alert"),
            content: const Text("Don't leave password empty."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      try {
        setState(() {
          isLoading = true;
        });

        var body = {
            "EmpId": userId,
            "Password": password
        };
        var response = await http.post(
          Uri.parse('API URL'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          var accesstoken = responseBody["accessToken"];
          var refreshtoken = responseBody["refreshToken"];
          var username = responseBody["username"];
          var employeeid = responseBody["empId"];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('Atoken', accesstoken);
          await prefs.setString('Rtoken', refreshtoken);
          await prefs.setString('name', username);
          await prefs.setString('idemp', employeeid);
          await SharedPreferencesService().setLoggedIn(true);
          print("User logged in and token saved: $accesstoken . $refreshtoken");
          print("$username");

          setState(() {
            isLoading = false;
          });

          // Navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dash()),
          );
        }
    else {
          print('Failed. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Alert"),
                content: const Text("Failed to Authenticate. Check your userid and password."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          setState(() {
            isLoading = false;
          });

        }
      } catch (e) {
        print('Error during authentication: $e');
        // Handle the exception accordingly, e.g., show a snackbar, alert dialog, etc.
      } finally {

      }
    }
  }



  @override
  void dispose(){
    _userid.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            color: backgroundColor1,
            child: Stack(
                children:[ SafeArea(
                    child: ListView(
                      children: [
                        SizedBox(height: size.height * 0.03),
                        const Text(
                          "Hello Again !",
                          textAlign: TextAlign.center,


                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 37,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 15),

                        SizedBox(height: size.height * 0.04),
                        // for username and password
                        myTextField1("Enter User ID", Colors.white),
                        myTextField2("Enter Password", Colors.white),
                        SizedBox(height: size.height * 0.04),
                        Center(
                            child: ElevatedButton(
                              onPressed: (){
                                authenticate(_userid.text, _password.text);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: primaryColor, // Text color
                                shadowColor: primaryColor,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.login, size: 24),
                                  SizedBox(width: 10),
                                  Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                        ),
                      ],
                    )
                ),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                ]
            ),
          ) ,




    );

  }
  Container myTextField1(String hint, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: TextField(
        controller: _userid,
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [LengthLimitingTextInputFormatter(40)],
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontSize: 19,
            ),
            suffixIcon: Icon(
              Icons.visibility_off_outlined,
              color: color,
            )),
      ),
    );
  }


  Container myTextField2(String hint, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: TextField(
        controller: _password ,
        keyboardType: TextInputType.visiblePassword,
        inputFormatters: [LengthLimitingTextInputFormatter(40)],
        obscureText: _ishidden,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 22,
            ),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.black45,
              fontSize: 19,
            ),
            suffix: InkWell(
              onTap: _togglepasswordview,
              child: Icon(
                  _ishidden
                      ?Icons.visibility_off
                      :Icons.visibility
              ),
            )
        ),
      ),
    );
  }
  void _togglepasswordview() {
    setState(() {
      _ishidden = !_ishidden;
    });
  }
}
