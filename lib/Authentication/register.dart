import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final TextEditingController _cPasswordEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth=MediaQuery.of(context).size.width,_screenHeight=MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 8.0,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _textEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordEditingController,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordEditingController,
                    data: Icons.person,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  )
                ],
              ),

            ),
            RaisedButton(
              onPressed: () {
                uploadAndSave();
              },
              color: Colors.red,
              child: Text("Sign Up", style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 30.0,
            ),
            /*  Container(
              height: 4.0,
              width: _screenWidth=0.8,
              color: Colors.pink,

            ),
            SizedBox(
              height: 15.0,
            ),*/
          ],

        ),
      ),
    );
  }

  Future<void> uploadAndSave() async
  {
    _passwordEditingController.text == _cPasswordEditingController.text
        ? _emailEditingController.text.isNotEmpty &&
        _passwordEditingController.text.isNotEmpty &&
        _cPasswordEditingController.text.isNotEmpty &&
        _textEditingController.text.isNotEmpty

        ? uploadToStorage()

        : displayDialog("Complete the Required details!")
        : displayDialog("Password not match!");
  }


  displayDialog(String msg)
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return ErrorAlertDialog(message: msg,);
        }
    );
  }

  uploadToStorage() async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingAlertDialog(message: "Please wait...",);
        }
    );

    _registeruser();
  }

  FirebaseAuth _auth=FirebaseAuth.instance;
  void _registeruser() async
  {
    FirebaseUser firebaseUser;
    await _auth.createUserWithEmailAndPassword
      (
      email: _emailEditingController.text.trim(),
      password: _passwordEditingController.text.trim(),

    ).then((auth){
      firebaseUser=auth.user;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorAlertDialog(message: error.message.toString(),);
          }
      );
    });

    if(firebaseUser !=null)
    {
      saveUserInfoToFirestore(firebaseUser).then((value)
      {
        Navigator.pop(context);
        Route route=MaterialPageRoute(builder: (c)=> StoreHome());
        Navigator.pushReplacement(context, route);

      });

    }
  }
  Future saveUserInfoToFirestore(FirebaseUser fUser)async
  {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid":fUser.uid,
      "email":fUser.email,
      "name":_textEditingController.text.trim(),
      EcommerceApp.userCartList:["garbageValue"]
    });

    await EcommerceApp.sharedPreferences.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences.setString("email", fUser.email);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName,_textEditingController.text);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }

}

