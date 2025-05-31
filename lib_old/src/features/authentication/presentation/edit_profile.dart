// import 'package:flutter/material.dart';
// import 'package:safer_vpn/src/features/index.dart';
// import 'package:provider/provider.dart';

// class EditProfile extends StatefulWidget {
//   const EditProfile({super.key});

//   @override
//   State<EditProfile> createState() => _EditProfileState();
// }

// class _EditProfileState extends State<EditProfile> {
//   String name = "", firstname = "", lastname = "";
//   TextEditingController namecontroller = TextEditingController();
//   TextEditingController passwordcontroller = TextEditingController();
//   TextEditingController mailcontroller = TextEditingController();

//   final _formkey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthNotifier>(context, listen: false);
//     return Scaffold(
//       body: Container(
//         margin: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//               child: Form(
//                 key: _formkey,
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Name';
//                           }
//                           return null;
//                         },
//                         controller: namecontroller,
//                         decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 1.0, horizontal: 10.0),
//                             border: InputBorder.none,
//                             hintText: "Name",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         keyboardType: TextInputType.emailAddress,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Email';
//                           }
//                           return null;
//                         },
//                         controller: mailcontroller,
//                         decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 1.0, horizontal: 10.0),
//                             border: InputBorder.none,
//                             hintText: "Email",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 2.0, horizontal: 30.0),
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30)),
//                       child: TextFormField(
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please Enter Password';
//                           }
//                           return null;
//                         },
//                         controller: passwordcontroller,
//                         decoration: const InputDecoration(
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 1.0, horizontal: 10.0),
//                             border: InputBorder.none,
//                             hintText: "Password",
//                             hintStyle: TextStyle(
//                                 color: Color(0xFFb2b7bf), fontSize: 18.0)),
//                         obscureText: true,
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 30.0,
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         if (_formkey.currentState!.validate()) {
//                           setState(() {
//                             name = mailcontroller.text;
//                             firstname = namecontroller.text;
//                             lastname = passwordcontroller.text;
//                           });
//                         }
//                         authProvider.updateProfiles(
//                             context, name, firstname, lastname);
//                       },
//                       child: Container(
//                           width: MediaQuery.of(context).size.width,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 13.0, horizontal: 30.0),
//                           decoration: BoxDecoration(
//                               color: const Color(0xFF273671),
//                               borderRadius: BorderRadius.circular(30)),
//                           child: const Center(
//                               child: Text(
//                             "Sign Up",
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22.0,
//                                 fontWeight: FontWeight.w500),
//                           ))),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 40.0,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
