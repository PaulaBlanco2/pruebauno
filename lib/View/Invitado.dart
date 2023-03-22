import 'package:flutter/material.dart';


class Invitado extends StatefulWidget {
  Invitado();
  @override
  InvitadoApp createState() => InvitadoApp();

}
class InvitadoApp extends State<Invitado>{
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: Text('Invitado'),
        backgroundColor: Colors.lightBlueAccent,
      ),
    );

  }
}