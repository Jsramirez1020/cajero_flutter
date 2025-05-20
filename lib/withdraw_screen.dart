import 'package:flutter/material.dart';

class WithdrawScreen extends StatefulWidget {
  final double balance;

  const WithdrawScreen({super.key, required this.balance});

  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();

  void _submit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Monto no válido');
    } else if (amount > widget.balance) {
      _showError('Fondos insuficientes');
    } else {
      Navigator.pop(context, amount);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
