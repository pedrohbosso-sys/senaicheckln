import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RecursoException implements Exception {
  final String mensagem;
  final bool abrirConfiguracoes;
  final bool ativarGps;

  const RecursoException(
    this.mensagem, {
    this.abrirConfiguracoes = false,
    this.ativarGps = false,
  });
}

class HardwareService {
  final ImagePicker _picker = ImagePicker();

  Future<void> _solicitarPermissao(Permission permissao, String recurso) async {
    final status = await permissao.request();
    if (!status.isGranted) {
      throw RecursoException(
        'Permita o acesso à $recurso para prosseguir.',
        abrirConfiguracoes: status.isPermanentlyDenied || status.isRestricted,
      );
    }
  }

  Future<XFile?> fotografar() async {
    await _solicitarPermissao(Permission.camera, 'câmera');
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
  }

  Future<Position> localizar() async {
    await _solicitarPermissao(Permission.locationWhenInUse, 'localização');

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const RecursoException(
        'Ative o GPS nas configurações do dispositivo.',
        ativarGps: true,
      );
    }

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 25),
        ),
      );

      if (!posicao.accuracy.isFinite || posicao.accuracy > 100) {
        throw const RecursoException(
          'Sinal de GPS fraco. Vá para um local aberto e tente novamente.',
        );
      }

      return posicao;
    } on TimeoutException {
      throw const RecursoException(
        'O GPS demorou a responder. Tente novamente em local aberto.',
      );
    }
  }
}
