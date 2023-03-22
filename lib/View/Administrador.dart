import 'package:flutter/material.dart';


class Administrador extends StatefulWidget {
  Administrador();
  @override
  AdministradorApp createState() => AdministradorApp();

}
class AdministradorApp extends State<Administrador>{
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: Text('Adminsitrador'),
        backgroundColor: Colors.redAccent,
      ),
    );

  }
}