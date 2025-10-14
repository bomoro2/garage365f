import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Garage365')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Ingresos (FDU)'),
            subtitle: const Text('Ver ingresos por equipo'),
            onTap: () => context.go('/fdu'),
          ),
          ListTile(
            title: const Text('QR Preview'),
            subtitle: const Text('Compartir QR de equipo'),
            onTap: () => context.go('/qr'),
          ),
          ListTile(
            title: const Text('Ajustes'),
            subtitle: const Text('Reset Demo, preferencias'),
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}
