import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}





class _LoginState extends State<Login>
{
  final TextEditingController _emailEditingController= TextEditingController();
  final TextEditingController _passwordEditingController= TextEditingController();
  final GlobalKey<FormState> _formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth=MediaQuery.of(context).size.width,_screenHeight=MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/login.png",
                height: 240.0,
                width: 240.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Login to your account",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _emailEditingController ,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordEditingController ,
                    data: Icons.person,
                    hintText: "Password",
                    isObsecure: true,
                  ),

                ],
              ),

            ),
            RaisedButton(
              onPressed: (){
                _emailEditingController.text.isNotEmpty && _passwordEditingController.text.isNotEmpty
                    ? loginUser()
                    : showDialog(
                    context: context,
                    builder: (c)
                    {
                      return ErrorAlertDialog(message: "Please write email and password",);
                    }
                );
              },
              color: Colors.red,
              child: Text("Login",style: TextStyle(color: Colors.white),),
            ),
            SizedBox(
              height: 50.0,
            ),
            FlatButton.icon(
              onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminSignInPage())),
              icon: (Icon(Icons.nature_people, color: Colors.pink,)),
              label: Text("I am an Admin",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
  FirebaseAuth _auth=FirebaseAuth.instance;
  void loginUser()async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingAlertDialog(message: "Please wait",);
        }
    );
    FirebaseUser firebaseUser;
    await _auth.signInWithEmailAndPassword(
      email: _emailEditingController.text.trim(),
      password: _passwordEditingController.text.trim(),
    ).then((authUser){
      firebaseUser=authUser.user;
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
    if(firebaseUser != null)
    {
      readData(firebaseUser).then((s)
      {
        Navigator.pop(context);
        Route route=MaterialPageRoute(builder: (c)=> StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }

  }
  Future readData(FirebaseUser fUser)async
  {
    Firestore.instance.collection("users").document(fUser.uid).get().then((dataSnapshot)
    async{
      await EcommerceApp.sharedPreferences.setString("uid", dataSnapshot.data[EcommerceApp.userUID]);
      await EcommerceApp.sharedPreferences.setString("email",dataSnapshot.data[EcommerceApp.userEmail]);
      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName,dataSnapshot.data[EcommerceApp.userName]);
      List<String> cartList=dataSnapshot.data[EcommerceApp.userCartList].cast<String>();
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, cartList);
    });
  }
}


