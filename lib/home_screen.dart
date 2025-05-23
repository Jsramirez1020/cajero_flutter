import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'withdraw_screen.dart';
import 'UpdateProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  final String nombre;
  final double saldo;

  const HomeScreen({required this.nombre, required this.saldo});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double _balance;

  @override
  void initState() {
    super.initState();
    _balance = widget.saldo;
  }

  void _withdraw(double amount) {
    setState(() {
      _balance -= amount;
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

  void _goToUpdateProfile() {
    final userData = {
      'id': 1, // reemplaza con el ID real si lo tienes
      'nombre': widget.nombre,
      'correo':
          'usuario@correo.com', // puedes usar valores reales si los tienes
      'identificacion': '123456789',
      'usuario': 'usuario123',
      'edad': 30,
      'password': '123456', // si está disponible
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProfileScreen(userData: userData),
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                onPressed: _goToUpdateProfile,
                icon: Icon(Icons.money),
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
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Salir',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class UpdateProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cajero Automático'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'Actualizar perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text('Pantalla de actualización de perfil')),
    );
  }
}*/
