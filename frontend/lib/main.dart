import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/chat_provider.dart';
import 'views/chat_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ConnectRealApp());
}

class ConnectRealApp extends StatelessWidget {
  const ConnectRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5A61E8);
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: MaterialApp(
        title: 'ConnectReal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        home: const ChatView(),
      ),
    );
  }
}
