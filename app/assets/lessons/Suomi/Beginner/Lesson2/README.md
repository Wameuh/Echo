# Paquet média — leçon 2

Ce paquet a été compilé depuis la source éditoriale v2 de la leçon 2.

## État

- audio : 114 segments WAV générés et contrôlés automatiquement ;
- piste complète : `audio/full.wav` (7 min 27,96 s) ;
- illustrations : quatre cases PNG carrées ;
- bulles : définies dans `story/story.json` et reliées aux lignes `line-002` à `line-007` ;
- validation humaine du finnois, du français et de la progression : encore requise.

Les textes ne sont pas inscrits dans les images. L'application doit superposer les bulles à partir de `story/story.json`, afin de préserver l'orthographe finnoise et de permettre l'audio et la traduction à la demande.

## Direction artistique

Les quatre images ont été produites avec l'outil intégré de génération d'images : BD européenne semi-réaliste, traits fins, léger grain papier, palette scandinave chaude et continuité visuelle d'Anna et Mikko avec la leçon 1.

1. matin enneigé à un arrêt de tram d'Helsinki ;
2. salutations de journée dans une bibliothèque ;
3. retrouvailles devant un café au début de soirée ;
4. réponse à « Mitä kuuluu? » dans l'entrée chaleureuse du café.

## Régénération

Depuis la racine du dépôt :

```powershell
audio-generation/.venv/Scripts/python.exe audio-generation/tools/prepare_course_lesson_media.py --lesson 2
audio-generation/.venv/Scripts/python.exe audio-generation/tools/render_course_lesson_audio.py --lesson 2 --resume
audio-generation/.venv/Scripts/python.exe audio-generation/tools/validate_course_lesson_media.py --lesson 2
```
