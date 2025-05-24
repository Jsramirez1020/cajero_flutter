import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UpdateProfileScreen({super.key, required this.userData});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _correoController;
  late TextEditingController _identificacionController;
  late TextEditingController _usuarioController;
  late TextEditingController _edadController;
  late TextEditingController _passwordController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing user data
    _nombreController = TextEditingController(
      text: widget.userData['nombre'] ?? '',
    );
    _correoController = TextEditingController(
      text: widget.userData['correo'] ?? '',
    );
    _identificacionController = TextEditingController(
      text: widget.userData['identificacion'] ?? '',
    );
    _usuarioController = TextEditingController(
      text: widget.userData['usuario'] ?? '',
    );
    _edadController = TextEditingController(
      text: widget.userData['edad']?.toString() ?? '',
    );
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _identificacionController.dispose();
    _usuarioController.dispose();
    _edadController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userId = widget.userData['id'];
        if (userId == null) {
          throw Exception('Usuario no encontrado');
        }

        // Prepare update data
        final updateData = {
          'nombre': _nombreController.text,
          'identificacion': _identificacionController.text,
          'usuario': _usuarioController.text,
          'edad': int.parse(_edadController.text),
          'correo': _correoController.text,
          'password':
              _passwordController.text.isEmpty
                  ? widget.userData['password']
                  : _passwordController.text,
        };

        // Send PUT request to update user
        final response = await http.put(
          Uri.parse('http://10.0.2.2:5000/api/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateData),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          if (!mounted) return;
          final errorMessage =
              jsonDecode(response.body)['error'] ??
              'Error al actualizar perfil';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Actualizar Perfil'),
        backgroundColor: Colors.orange,
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
                const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _nombreController,
                  label: 'Nombre completo',
                  validator: (v) => v!.isEmpty ? 'Ingrese su nombre' : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _identificacionController,
                  label: 'Identificación',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Ingrese su ID' : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _usuarioController,
                  label: 'Usuario',
                  validator: (v) => v!.isEmpty ? 'Ingrese un usuario' : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _edadController,
                  label: 'Edad',
                  keyboardType: TextInputType.number,
                  validator:
                      (v) =>
                          v!.isEmpty || int.tryParse(v) == null
                              ? 'Edad inválida'
                              : null,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _correoController,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Correo inválido',
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña (dejar en blanco para mantener la actual)',
                  obscureText: true,
                  validator:
                      (v) =>
                          v!.isNotEmpty && v.length < 6
                              ? 'Mínimo 6 caracteres'
                              : null,
                ),

                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.check),
                      label: const Text('Actualizar Perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.orange),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.orange,
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
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
