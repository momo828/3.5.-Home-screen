import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  Future<void> _guardarEnFavoritos(Movie movie) async {
    await FirebaseFirestore.instance.collection('favoritos').add({
      'titulo': movie.title,
      'imagen': movie.imageUrl,
      'fecha': Timestamp.now(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${movie.title} se guardó en Firebase Firestore'),
        backgroundColor: Colors.green,
      ),
    );
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
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
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () => _guardarEnFavoritos(snapshot.data!),
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          label: const Text('Guardar en Firebase'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('favoritos')
                              .snapshots(),
                          builder: (context, dbSnapshot) {
                            if (!dbSnapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final total = dbSnapshot.data!.docs.length;
                            return Text(
                              'Guardados en Firestore: $total',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            );
                          },
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
          ),
        ],
      ),
    );
  }
}
