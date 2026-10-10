# Paquet applicatif — leçon 1

Ce dossier contient uniquement les données compilées que Flutter charge à
l’exécution : déroulement de session, unités, activités, traductions et manifeste
léger des médias. Les seeds, profils de voix et contrôles qualité détaillés restent
dans le plan de production sous `audio-generation/content/audio-plans/`.

Les sources éditoriales et les scripts de fabrication se trouvent dans
`audio-generation/`. Les fichiers de ce paquet peuvent être régénérés depuis le
poste audio avec :

```powershell
.venv\Scripts\python.exe tools\build_lesson1_app_content.py
.venv\Scripts\python.exe tools\render_lesson1_audio.py
.venv\Scripts\python.exe tools\validate_lesson1_app_content.py
```

Ces commandes sont lancées depuis `audio-generation/`. L’application ne les
exécute jamais et ne génère aucun son.

Le mode de production validé génère séparément chaque couple voix–texte unique à
partir de sa référence humaine d'environ 15 secondes, puis recopie le même WAV pour
les répétitions strictement identiques. Il n'utilise ni chaînage de sorties
synthétiques, ni blocs longs regroupant plusieurs répliques.
