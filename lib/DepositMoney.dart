// En tu archivo: DepositMoney.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DepositMoneyScreen extends StatefulWidget {
  // A diferencia de WithdrawScreen, no necesariamente necesitamos el balance actual aquí,
  // a menos que quieras mostrarlo o usarlo para alguna validación específica de depósito.
  // Por ahora, lo mantendré simple. Si necesitas el balance, puedes agregarlo.
  // final double currentBalance;

  const DepositMoneyScreen({
    super.key,
    required double balance /*, this.currentBalance */,
  });

  @override
  _DepositMoneyScreenState createState() => _DepositMoneyScreenState();
}

class _DepositMoneyScreenState extends State<DepositMoneyScreen> {
  final _amountController = TextEditingController();

  void _submitDeposit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Monto no válido. Debe ser un número positivo.');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(
        'userId',
      ); // <- Reemplázalo con el ID real del usuario logueado

      if (userId == null) {
        _showError('No se pudo obtener el ID del usuario.');
        return;
      }
      final url = Uri.parse('http://10.0.2.2:5000/api/users/$userId/consignar');

      // Enviar la solicitud POST al servidor
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'monto': amount}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consignación exitosa'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, amount); // Devuelve el monto a HomeScreen
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Error desconocido';
        _showError(error);
      }
    } catch (e) {
      _showError('Error al conectar con el servidor');
      print('Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Consignar Dinero'),
        backgroundColor: Colors.green, // Un color distintivo para consignar
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center, // Para centrar el contenido si es poco
          children: [
            SizedBox(height: 30),
            Text(
              '¿Cuánto deseas consignar?',
              style: TextStyle(fontSize: 20, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto a consignar',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitDeposit,
              icon: Icon(Icons.check_circle_outline),
              label: Text('Confirmar consignación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
