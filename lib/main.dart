import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Capa del fondo: Imagen de internet
            Image.network(
              'https://www.google.com/imgres?q=imagen%20de%20cine%20animado%C2%A0&imgurl=https%3A%2F%2Fi.pinimg.com%2F736x%2Fd8%2F98%2F70%2Fd89870ecbe781af6cf48d0db5813660d.jpg&imgrefurl=https%3A%2F%2Fes.pinterest.com%2Fpin%2F268667934016380270%2F&docid=t8JWFNjXjBK0EM&tbnid=TxdxayZB-Z_goM&vet=12ahUKEwjE5r7YiOiXAxVFm2oFHcouD-wQnPAOegQIUhAA..i&w=626&h=626&hcb=2&ved=2ahUKEwjE5r7YiOiXAxVFm2oFHcouD-wQnPAOegQIUhAA',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.6)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'CineApp',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '¡Bienvenido a tu catálogo de películas!',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
