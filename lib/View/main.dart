import 'dart:html';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:pruebauno/View/Geoposition.dart';
import '../DTO/User.dart';
import 'Administrador.dart';
import 'Invitado.dart';
import 'Registro.dart';
import 'firebase_options.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  HomeStart createState() => HomeStart();
}

class HomeStart extends State<Home> {
  TextEditingController nombre = TextEditingController();
  TextEditingController pass = TextEditingController();
  User objUser = User();
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> biometrico() async {
    //print("biométrico");

    // bool flag = true;
    bool authenticated = false;

    const androidString = const AndroidAuthMessages(
      cancelButton: "Cancelar",
      goToSettingsButton: "Ajustes",
      signInTitle: "Ingrese",
      //fingerprintNotRecognized: 'Error de reconocimiento de huella digital',
      goToSettingsDescription: "Confirme su huella",
      //fingerprintSuccess: 'Reconocimiento de huella digital exitoso',
      biometricHint: "Toque el sensor",
      //signInTitle: 'Verificación de huellas digitales',
      biometricNotRecognized: "Huella no reconocida",
      biometricRequiredTitle: "Required Title",
      biometricSuccess: "Huella reconocida",
      //fingerprintRequiredTitle: '¡Ingrese primero la huella digital!',
    );
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    // bool isBiometricSupported = await auth.();
    bool isBiometricSupported = await auth.isDeviceSupported();

    List<BiometricType> availableBiometrics =
    await auth.getAvailableBiometrics();
    print(canCheckBiometrics); //Returns trueB
    // print("support -->" + isBiometricSupported.toString());
    print(availableBiometrics.toString()); //Returns [BiometricType.fingerprint]
    try {
      authenticated = await auth.authenticate(
          localizedReason: "Autentíquese para acceder",
          useErrorDialogs: true,
          stickyAuth: true,
          //biometricOnly: true,
          androidAuthStrings: androidString);
      if (!authenticated) {
        authenticated = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }
    /* if (!mounted) {
        return;
      }*/

    return authenticated;
  }

  validarDatos() async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection('Usuarios');
      QuerySnapshot usuarios = await ref.get();

      if (usuarios.docs.length != 0) {
        for (var cursor in usuarios.docs) {
          if (cursor.get('NombreUsuario') == nombre.text) {
            print('Usuario encontrado');
            print(cursor.get('IdentidadUsuario'));
            if (cursor.get('ContrasenaUsuario') == pass.text) {
              print('********** Acceso aceptado **********');
              mensaje('Bienvenido', cursor.get('rol'));
              objUser.nombre = cursor.get('NombreUsuario');
              objUser.id = cursor.get('IdentidadUsuario');
              objUser.rol=cursor.get("rol");
              nombre.clear();
              pass.clear();
            } else
              print('********** Acceso denegado **********');
          }
        }
      } else {
        print('No hay documentos en la colecccion');
      }
      print('Envio correcto');

    } catch (e) {
      print('ERROR....' + e.toString());
    }
  }
  void mensaje(String titulo,String contenido) {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(contenido),
            actions: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  //Navigator.pop(context);
                  if(objUser.rol=='administrador'){
                    //Navigator.push(context, MaterialPageRoute(builder: (_) => Administrador()));
                  }else if(objUser.rol=='invitado'){
                    //Navigator.push(context, MaterialPageRoute(builder: (_) => Invitado()));
                  }
                },
                child:
                Text('OK', style: TextStyle(color:Colors.blueGrey)),
              )
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienvenidos',
      home: Scaffold(
        appBar: AppBar(
          title: Text('App Línea 2'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Image.asset('img/img.png'),
                  )),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: nombre,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Email Usuario',
                      hintText: 'Digite email de Usuario'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: pass,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelText: 'Contrasena',
                      hintText: 'Digite su Contrasena'),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => Geoposition()));

                    pass.text = sha1.convert(utf8.encode(pass.text)).toString();
                    print('contrasena original ${pass.text}');
                    print('crypto SHA-1 :' + pass.text);
                    print('***** Ingresando *****');
                    validarDatos();
                  },
                  child: Text('Enviar'),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: TextButton(
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Registro(objUser)));
                  },
                  child: Text('Registrar'),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(50, 50),
                    backgroundColor: Colors.black45,
                  ),
                  onPressed: () async {
                    if (await biometrico()){
                      mensaje('Huella', 'HuellaEncontrada');
                    }
                    biometrico();
                  },
                  child: Icon(Icons.fingerprint, size:80),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
