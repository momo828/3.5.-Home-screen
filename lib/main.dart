import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Movie {
  final String title;
  final String imageUrl;

  const Movie({required this.title, required this.imageUrl});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['name'] ?? 'Sin título',
      imageUrl: json['image']?['medium'] ?? '',
    );
  }
}

Future<Movie> fetchMovie() async {
  final response = await http.get(
    Uri.parse('https://api.tvmaze.com/singlesearch/shows?q=stranger+things'),
  );

  if (response.statusCode == 200) {
    return Movie.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error al descargar la serie');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CineHomeScreen(),
    );
  }
}

class CineHomeScreen extends StatefulWidget {
  const CineHomeScreen({super.key});

  @override
  State<CineHomeScreen> createState() => _CineHomeScreenState();
}

class _CineHomeScreenState extends State<CineHomeScreen> {
  late Future<Movie> futureMovie;

  @override
  void initState() {
    super.initState();
    futureMovie = fetchMovie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),

          Container(color: Colors.black.withValues(alpha: 0.7)),

          Center(
            child: FutureBuilder<Movie>(
              future: futureMovie,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'CineApp',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 30),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          snapshot.data!.imageUrl,
                          height: 300,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        snapshot.data!.title,
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Hubo un error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  );
                }

                return const CircularProgressIndicator(color: Colors.amber);
              },
            ),
          ),
        ],
      ),
    );
  }
}
