# 📍 SENAI CheckIn

Aplicativo desenvolvido em **Flutter** para registro de ponto e diário de campo, utilizando **câmera, GPS e SQLite**.

## 🛠️ Tecnologias

* Flutter / Dart
* SQLite
* `image_picker`
* `geolocator`
* `permission_handler`

## ▶️ Como executar

```bash
flutter pub get
flutter run
```

Requer **Android 7 (API 24+)** e um dispositivo/emulador com câmera e localização.

## 📱 Funcionamento

1. Criar um novo registro.
2. Tirar uma foto.
3. Obter a localização pelo GPS.
4. Adicionar uma observação opcional.
5. Salvar o registro.
6. Consultar os registros no histórico.

Os dados são armazenados localmente no **SQLite**, e as fotos são salvas na pasta privada do aplicativo.

## 📂 Estrutura

```text
lib/
├── main.dart
├── registro_model.dart
├── registro_dbhelper.dart
├── hardware_service.dart
├── registro_page.dart
├── cadastro_page.dart
└── detalhes_page.dart
```

## 🧪 Validação

```bash
flutter analyze
flutter test
flutter build apk --debug
```

* ✅ `flutter analyze` sem problemas
* ✅ 2 testes automatizados aprovados
* ✅ APK de debug gerado
* ⚠️ Testes de câmera e GPS ainda precisam ser realizados em dispositivo Android.

## 📚 Documentação

* [image_picker](https://pub.dev/packages/image_picker)
* [geolocator](https://pub.dev/packages/geolocator)
* [permission_handler](https://pub.dev/packages/permission_handler)
