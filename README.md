---
FUTTER
---

- Créer un projet Flutter de façon classique
- Remplacer le nom de package par le bon nom de package
- Changer le development team
- Créer un projet Firebase
- Activer Google Play Integrity & Google People API & Google Play Game Services dans GCP
- Créer les applis Android et iOS sur Firebase
- Cocher GameCenter, Push Notifications, Background Modes (background fetch & remote notifications) dans XCode
- Ajouter un dossier contenant les images de la mascotte et mettre son nom dans CharacterSettings
- Ajouter le nécessaire dans le pubspec.yaml en prenant un ancien projet
- Ajouter des Client ID dans GCP pour Web, Android et iOS
- Créer 2 applications Admob pour le projet

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
Configurer Android pour les écrans (le plein écran)
Configurer Game Services
Ajouter ic_stat_nom pour les notifications dans les ressources de l'application et le manifest
Mettre une description, une image et une feature graphic pour Game Services dans Play Console
Publier les changements de Game Services dans Play Console

---
IOS
---

Cocher Game Center dans AppStoreConnect
Configurer Info.plist (en prenant un ancien projet)
Mettre à 15 la version minimale du projet (dans le Podfile)

---
FINALISATION
---

IAP & Leaderboards à configurer
Mettre le SHA-1 de Release dans Firebase
Mettre le SHA-1 de Release dans les credentials de GCP et lier ça dans Play Console (sinon les connexions ne passeront pas en release)
    Parmi les SHA-1 de la console Google Play, il faut prendre le SHA-1 de la section "App signing key certificate"