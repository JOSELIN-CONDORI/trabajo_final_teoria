import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_flutter_api_rest/src/components/app_bar_create.dart';
import 'package:front_flutter_api_rest/src/controller/empresaController.dart';
import 'package:front_flutter_api_rest/src/model/empresaModel.dart';
import 'package:front_flutter_api_rest/src/providers/theme.dart';
import 'package:front_flutter_api_rest/src/routes/route.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EmpresaCreatePage extends StatefulWidget {
  @override
  _EmpresaCreatePageState createState() => _EmpresaCreatePageState();
}

class _EmpresaCreatePageState extends State<EmpresaCreatePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _ra_socialController = TextEditingController();
  final _marcaController = TextEditingController();

  String? selectedEstado;
  File? selectedImage;

  EmpresaController empresaController = EmpresaController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void _crearEmpresa() async {
    if (_formKey.currentState!.validate()) {
      String? downloadUrl = await _uploadImage(_ra_socialController.text);

      final nuevaEmpresa = EmpresaModel(
        ra_social: _ra_socialController.text,
        marca: _marcaController.text,
        numero: selectedEstado ?? "",
        foto: downloadUrl ?? '', // Usar la URL de descarga de la imagen
      );

      try {
        final response = await empresaController.crearEmpresa(nuevaEmpresa);
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoría creada con éxito')),
          );
          Navigator.pushNamed(context, AppRoutes.empresaListRoute);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al crear la categoría: ${response.body}')),
          );
        }
      } catch (e) {
        print('Error al crear la categoría: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la categoría: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage(String title) async {
    try {
      if (selectedImage != null) {
        final fileName = 'venta/$title-${DateTime.now()}.png';
        final firebaseStorageReference =
            FirebaseStorage.instance.ref().child(fileName);

        await firebaseStorageReference.putFile(selectedImage!);
        final downloadUrl = await firebaseStorageReference.getDownloadURL();

        return downloadUrl;
      } else {
        return null;
      }
    } catch (error) {
      print("Error uploading image: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeColors = themeProvider.getThemeColors();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeProvider.isDiurno ? themeColors[1] : themeColors[7],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarCreate(
              onBackTap: () {
                Navigator.pushNamed(context, AppRoutes.empresaListRoute);
              },
            ),
            SizedBox(height: 20), // Espacio entre la AppBar y el formulario
            Card(
              color: themeProvider.isDiurno ? themeColors[2] : themeColors[7],
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                          _ra_socialController, 'Nombre', themeProvider),
                      SizedBox(height: 20),
                      _buildTextField(_marcaController, 'Tag', themeProvider),
                      SizedBox(height: 20),
                      _buildDropdownEstado(themeProvider),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(
                          Icons.image,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Seleccionar Imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (selectedImage != null)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDiurno
                                  ? themeColors[2]
                                  : themeColors[0],
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white
                                      .withOpacity(0.4), // Sombra más suave
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 30),
                      // Botón de crear categoría
                      ElevatedButton(
                        onPressed: _crearEmpresa,
                        child: Text('Crear Empresa'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextField(TextEditingController controller, String label,
      ThemeProvider themeProvider) {
    final themeColors = themeProvider.getThemeColors();
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: themeProvider.isDiurno ? themeColors[7] : themeColors[2],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: themeProvider.isDiurno ? themeColors[10] : themeColors[9],
        ),
        filled: true,
        fillColor: themeProvider.isDiurno ? themeColors[1] : themeColors[7],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa $label';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildDropdownEstado(
      ThemeProvider themeProvider) {
    final themeColors = themeProvider.getThemeColors();
    return DropdownButtonFormField<String>(
      value: selectedEstado,
      onChanged: (String? newValue) {
        setState(() {
          selectedEstado = newValue;
        });
      },
      items: ['Activo', 'Inactivo'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: Colors.blue),
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Estado',
        filled: true,
        fillColor: themeProvider.isDiurno ? themeColors[1] : themeColors[7],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un numero';
        }
        return null;
      },
    );
  }
}
