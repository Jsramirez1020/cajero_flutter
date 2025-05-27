import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DepositMoney.dart';
import 'login_screen.dart';
import 'withdraw_screen.dart';
import 'UpdateProfileScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String nombre;
  final double saldo;

  const HomeScreen({super.key, required this.nombre, required this.saldo});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double _balance;
  bool _isBalanceLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final result = await getBalanceFromDatabase();
    setState(() {
      _balance = result;
      _isBalanceLoaded = true;
    });
  }

  Future<double> getBalanceFromDatabase() async {
    // Simula obtener el saldo desde la base de datos o API
    final userId = 1; // Reemplaza con el ID real del usuario
    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/usuarios/$userId/saldo');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final saldo = double.tryParse(data['saldo'].toString());
        return saldo ?? widget.saldo; // Fallback a saldo inicial
      } else {
        print('Error al obtener saldo: ${response.body}');
        return widget.saldo;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return widget.saldo;
    }
  }

  void _withdraw(double amount) {
    setState(() {
      _balance -= amount;
    });
  }

  void _deposit(double amount) {
    setState(() {
      _balance += amount;
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => LoginScreen(),
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _goToUpdateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se encontró el ID del usuario')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProfileScreen(userData: data),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener los datos del perfil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    }
  }

  void _goToWithdraw() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => WithdrawScreen(balance: _balance),
      ),
    );

    if (result != null) {
      _withdraw(result);
    }
  }

  void _goToDeposit() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (context) => DepositMoneyScreen(balance: _balance),
      ),
    );

    if (result != null) {
      _deposit(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Cajero Automático'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Actualizar perfil',
            onPressed: _goToUpdateProfile,
          ),
        ],
      ),
      body: Center(
        child:
            _isBalanceLoaded
                ? _buildMainContent()
                : CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Icon(Icons.account_circle, size: 80, color: Colors.indigo),
          SizedBox(height: 10),
          Text(
            'Bienvenido, ${widget.nombre}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Saldo disponible',
            style: TextStyle(fontSize: 20, color: Colors.grey[800]),
          ),
          SizedBox(height: 10),
          Text(
            '\$${_balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[700],
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _goToWithdraw,
            icon: Icon(Icons.money_off),
            label: Text('Retirar dinero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _goToDeposit,
            icon: Icon(Icons.attach_money),
            label: Text('Depositar dinero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.red),
            label: Text(
              'Salir',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
