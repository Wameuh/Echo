# Application Echo

Ce dossier est un projet Flutter autonome. Il contient l’interface, les contrôleurs,
les tests et les paquets de leçons déjà compilés. Il ne contient aucun moteur de
synthèse vocale.

## Démarrer l’application

Depuis ce dossier :

```powershell
flutter pub get
flutter run -d chrome
```

Le mode de navigation rapide entre les onze parties de la leçon est réservé au
développement :

```powershell
flutter run -d chrome --dart-define=ECHO_QA_MODE=true
```

## Vérifier l’application

```powershell
flutter analyze
flutter test
```

## Contenus audio

L’app lit exclusivement des fichiers déjà produits. Le paquet courant se trouve
dans `assets/lessons/Suomi/Beginner/Lesson1/`; son `audio/manifest.json` relie la
piste complète et les 143 segments à leurs écrans. La piste complète, les scènes,
les répliques de jeu de rôle, le mini-jeu d’écoute et le transfert utilisent tous
les WAV publiés avec la leçon.

Le pipeline Higgs et les sources de génération restent locaux dans
`../audio-generation/` et ne sont pas suivis par Git. Aucune dépendance de ce
sous-projet n’est nécessaire pour construire l’application.

## Identité visuelle

Les SVG de marque utilisés par l’application sont dans
`design-showcase/assets/`. Les fichiers de maquettes visuelles restent locaux.
Après une modification de la forme ou des couleurs du logo :

```powershell
python tool\generate_brand_icons.py
```
