<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.

---
FUTTER
---

- Créer un projet Flutter de façon classique
- Remplacer le nom de package par le bon nom de package
- Créer un projet Firebase
- Activer Google Play Integrity & Google People API & Google Play Game Services dans GCP
- Créer les applis Android et iOS sur Firebase
- Cocher GameCenter, Push Notifications, Background Modes (background fetch & remote notifications) dans XCode
* Ajouter un dossier contenant les images de la mascotte et mettre son nom dans CharacterSettings
- Ajouter le nécessaire dans le pubspec.yaml en prenant un ancien projet
- Ajouter des Client ID dans GCP pour Web, Android et iOS

---
GOOGLE & APPLE
---

In App Purchases à configurer
Créer 2 applications Admob pour le projet

---
FIREBASE
---

Activer Firebase Realtime Database et copier les règles d'un ancien projet
Exécuter flutterfire configure
Configurer Firebase Auth (avec GCP pour Android et rien pour iOS)

---
ANDROID
---

Configurer le Manifest et le Gradle (pour les releases)
Ajouter default_web_client_id à values.xml
Ajouter un key.properties à la racine de android
Configurer Android pour les écrans (le plein écran)
Configurer Firebase Game Services
Ajouter ic_stat_nom pour les notifications dans les ressources de l'application et le manifest
Mettre une description, une image et une feature graphic pour Game Services dans Play Console
Publier les changements de Game Services dans Play Console

---
IOS
---

Cocher Game Center dans la console
Firebase Game Services (à configurer)
Configurer Info.plist (en prenant un ancien projet)
Mettre à 12 la version minimale du projet (dans le Podfile)

---
FINALISATION
---

Mettre les SHA-1 de Release dans Firebase
Mettre le SHA-1 de Release dans les credentials de GCP et lier ça dans Play Console (sinon les connexions ne passeront pas en release)