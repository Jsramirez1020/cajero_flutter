import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 1. IMPORTA SharedPreferences

class WithdrawScreen extends StatefulWidget {
  final double balance; // Mantienes el balance que recibes

  const WithdrawScreen({super.key, required this.balance});

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit() async {
    // _submit ya es async, lo cual es bueno
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Monto no válido');
      return;
    }

    // --- 👇 CAMBIO PRINCIPAL AQUÍ 👇 ---
    // 2. Obtén la instancia de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // 3. Lee el 'userId' guardado. Puede ser null si no se encontró.
    final int? userId = prefs.getInt('userId');

    // 4. Verifica si el userId se pudo obtener
    if (userId == null) {
      _showError(
        'Error: No se pudo obtener el ID de usuario. Por favor, inicie sesión nuevamente.',
      );
      return; // No podemos continuar sin el ID del usuario
    }
    // --- 🏁 FIN DEL CAMBIO PRINCIPAL 🏁 ---

    // Ahora 'userId' es el ID del usuario que inició sesión
    // La URL base '/api/users/' es la misma que usaste en LoginScreen, lo cual es consistente.
    final url = Uri.parse('http://10.0.2.2:5000/api/users/$userId/retirar');

    try {
      final response = await http.post(
        url, // La URL ahora usa el userId dinámico
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'monto': amount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Retiro exitoso',
            ), // Considera usar data['mensaje'] de la respuesta
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
          context,
          amount,
        ); // Devuelve el monto para actualizar la UI anterior si es necesario
      } else {
        try {
          final data = jsonDecode(response.body);
          final error = data['error'] ?? 'Error al retirar';
          _showError(error);
        } catch (e) {
          _showError('Error inesperado: ${response.body}');
        }
      }
    } catch (e) {
      _showError('Error de conexión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Retirar dinero'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'Saldo actual: ${widget.balance.toStringAsFixed(2)}', // Muestra el saldo actual si lo deseas
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(
              '¿Cuánto deseas retirar?',
              style: TextStyle(fontSize: 20, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(Icons.check_circle_outline),
              label: Text('Confirmar retiro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
