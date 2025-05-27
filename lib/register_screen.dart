import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String _nombre = '';
  String _correo = '';
  String _identificacion = '';
  String _usuario = '';
  String _edad = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await http.post(
          Uri.parse(
            'http://10.0.2.2:5000/api/users',
          ), // Usa tu IP local si es un dispositivo real
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nombre': _nombre,
            'identificacion': _identificacion,
            'usuario': _usuario,
            'edad': int.parse(_edad),
            'correo': _correo,
            'password': _password,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Registro exitoso')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error de red: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Crear cuenta'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_add, size: 80, color: Colors.indigo),
                SizedBox(height: 20),

                // Nombre
                _buildTextField(
                  label: 'Nombre completo',
                  onSaved: (v) => _nombre = v!,
                  validator: (v) => v!.isEmpty ? 'Ingrese su nombre' : null,
                ),

                SizedBox(height: 16),

                // Identificación
                _buildTextField(
                  label: 'Identificación',
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _identificacion = v!,
                  validator: (v) => v!.isEmpty ? 'Ingrese su ID' : null,
                ),

                SizedBox(height: 16),

                // Usuario
                _buildTextField(
                  label: 'Usuario',
                  onSaved: (v) => _usuario = v!,
                  validator: (v) => v!.isEmpty ? 'Ingrese un usuario' : null,
                ),

                SizedBox(height: 16),

                // Edad
                _buildTextField(
                  label: 'Edad',
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _edad = v!,
                  validator:
                      (v) =>
                          v!.isEmpty || int.tryParse(v) == null
                              ? 'Edad inválida'
                              : null,
                ),

                SizedBox(height: 16),

                // Correo
                _buildTextField(
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (v) => _correo = v!,
                  validator: (v) => v!.contains('@') ? null : 'Correo inválido',
                ),

                SizedBox(height: 16),

                // Contraseña
                _buildTextField(
                  label: 'Contraseña',
                  obscureText: true,
                  onSaved: (v) => _password = v!,
                  validator:
                      (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),

                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.check),
                  label: Text('Registrarse'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.indigo),
                  label: Text(
                    'Ya tengo cuenta',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}
