import 'dart:io';
import 'package:flutter/material.dart';

class FotoRegistro extends StatelessWidget {
  final String caminho;
  final double? largura;
  final double altura;

  const FotoRegistro({
    super.key,
    required this.caminho,
    this.largura,
    this.altura = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14141B),
        border: Border.all(color: const Color(0x33D4AF37)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Image.file(
          File(caminho),
          width: largura,
          height: altura,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => SizedBox(
            width: largura,
            height: altura,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Color(0xFFD4AF37),
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
