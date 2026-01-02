import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offNamed('/');
      }
    });
  }

  Widget _buildLogoWidget(Color accentColor) {
    return FutureBuilder<bool>(
      future: _checkAssetExists(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return ClipOval(
            child: Image.asset(
              'assets/images/app-logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                if (kDebugMode) {
                  print('Logo image error: $error');
                }
                return _buildFallbackIcon(accentColor);
              },
            ),
          );
        }
        return _buildFallbackIcon(accentColor);
      },
    );
  }

  Future<bool> _checkAssetExists() async {
    try {
      await DefaultAssetBundle.of(context).load('assets/images/app-logo.png');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Asset check failed: $e');
      }
      return false;
    }
  }

  Widget _buildFallbackIcon(Color accentColor) {
    final primaryBlue = const Color(0xFF2196F3);
    final accentRed = const Color(0xFFF44336);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryBlue,
            primaryBlue.withValues(alpha: 0.8),
            accentRed.withValues(alpha: 0.6),
            accentRed.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 48, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF2196F3);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF1565C0),
              const Color(0xFF1976D2),
              const Color(0xFF1E88E5),
            ],
          ),
        ),
        child: Center(child: _buildLogoWidget(primaryBlue)),
      ),
    );
  }
}
