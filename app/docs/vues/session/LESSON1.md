# Finn — session de référence de la leçon 1

Dernière mise à jour : 24 septembre 2026

La leçon 1 est le MVP pédagogique et visuel du parcours. Ce document décrit la
version réellement compilée dans l’application. Les règles réutilisables pour les
autres leçons sont dans
[`AUTHORING_GUIDELINES.md`](../../../../audio-generation/content/curricula/Suomi/Core/AUTHORING_GUIDELINES.md).

## Objectif communicatif

À la fin de la leçon, l’apprenant peut :

- saluer et se présenter en finnois standard (`kirjakieli`) ;
- demander et donner une identité et une nationalité ;
- demander et indiquer où quelqu’un habite et travaille ;
- prononcer les nouveaux mots avec l’accent initial finnois et distinguer une
  voyelle longue, notamment le `oo` de `Lontoossa`.

La scène se déroule dans un café, mais la commande de boisson ne fait plus partie
de la leçon. Il n’y a que deux personnages : Anna et Mikko. Aucun serveur ne doit
apparaître dans le dialogue, les voix, la BD, la lecture, les jeux ou les médias.

## Sources et sorties

- source éditoriale v2 :
  `audio-generation/content/editorial/Suomi/Core/Lesson1.json` ;
- plan de production audio :
  `audio-generation/content/audio-plans/Suomi/Beginner/Lesson1.json` ;
- paquet chargé par Flutter :
  `app/assets/lessons/Suomi/Beginner/Lesson1/`.

Le paquet courant contient 137 segments dans la leçon principale et 6 segments
de transfert, soit 143 segments audio et une piste complète. Il comprend 21
unités, 6 phrases de lecture, 6 paires de Memory, 6 mini-jeux et 11 flashcards.

Le fichier historique
`audio-generation/content/lessons/Suomi/Beginner/Lesson1.json` reste une entrée de
migration pour le constructeur spécialisé. Les transformations normatives et les
filtres de retrait sont dans `build_lesson1_app_content.py`; la source v2 et le
paquet applicatif constituent les références à relire.

## Déroulement dans l’application

La session comporte onze parties :

1. leçon audio complète, puis question de compréhension ;
2. scène et personnages ;
3. deux jeux de rôle ;
4. passage à la même conversation sous forme de BD ;
5. lecture dans un autre contexte ;
6. compréhension écrite ;
7. Memory mot–dessin ;
8. jeux de manipulation de la langue ;
9. second contexte audio avec Sofia et Daniel ;
10. flashcards sélectives ;
11. bilan et planification de la révision.

La transition vers la BD dit « Retrouve la conversation sous forme de BD ». Elle
ne présente pas la conversation comme une nouvelle scène.

## Audio et prononciation

### Texte affiché et texte synthétisé

Le contenu affiché conserve l’orthographe correcte. Le plan audio peut ajouter
`synthesis_text` pour guider uniquement la synthèse vocale. Pour la ligne 71 :

- texte affiché : `« En » sert à répondre négativement…` ;
- texte envoyé à la voix française : `« Aine » sert à répondre négativement…`.

Le mot finnois reste donc correctement écrit pour l’apprenant, sans demander à la
voix francophone de prononcer la graphie comme le mot français « en ».

### Modèles finnois

La voix française explique. Une voix finnoise prononce toujours les syllabes,
mots et phrases à imiter. Les séquences de la leçon incluent notamment :

- `Suo · ma · lai · nen → suomalainen` ;
- `Eng · lan · ti · lai · nen → englantilainen` ;
- `A · sut · ko · Hel · sin · gis · sä → Asutko Helsingissä?` ;
- `Työs · ken · te · len → Työskentelen Helsingissä.` ;
- `Lon → toos → toossa → Lontoossa`.

Pour `Lontoossa`, le narrateur précise que l’accent principal tombe sur `Lon` et
que le `oo` doit être tenu comme une voyelle longue. Le découpage et le modèle
sonore finnois doivent faire l’objet d’une revue native avant publication.

### Identité des voix

Chaque personnage conserve un identifiant propre, même si deux rôles utilisent
temporairement le même fichier de référence. Une référence partagée ne doit jamais
fusionner les personnages dans les données ou l’interface.

## Compréhension après l’audio

La question porte sur le lieu de résidence d’Anna. La réponse correcte est « à
Londres ». Après validation correcte :

1. le retour positif reste visible pendant deux secondes ;
2. l’application passe automatiquement à la partie suivante.

Une réponse incorrecte reste affichée et n’avance pas automatiquement. Le minuteur
est annulé lorsque la carte est détruite.

## Jeux de rôle

Les lignes d’instruction du narrateur sont exclues des cartes. Lors du tour de
l’apprenant :

- l’écran affiche la réponse attendue en français ;
- l’apprenant la produit oralement en finnois ;
- la réponse finnoise n’est pas montrée avant la tentative ;
- « Écouter le modèle » permet ensuite d’entendre la réplique.

Lors du tour de l’interlocuteur, sa réplique finnoise est affichée et jouée. Les
deux jeux de rôle font successivement jouer Anna puis Mikko.

## Lecture, transfert et histoire

La BD reprend la rencontre d’Anna et Mikko en trois panneaux et ne contient pas de
scène de commande. La lecture met en scène Laura et James au travail. Sa fin porte
sur le lieu de résidence :

```text
Laura : Hauska tavata, James. Asutko Helsingissä?
James : En asu Helsingissä. Asun Lontoossa.
```

Le transfert utilise Sofia et Daniel dans un contexte distinct et réemploie les
constructions centrales sans introduire de commande de café.

## Jeux linguistiques

Le premier mini-jeu est un mot mystère de type Wordle :

- indice : `finlandais / finlandaise` ;
- réponse : `suomalainen` ;
- vert : lettre correcte et bien placée ;
- jaune : lettre présente ailleurs ;
- gris : lettre absente.

Ce jeu remplace l’ancien exercice à menus déroulants qui testait surtout la
mémoire des personnages, nationalités et villes. Les noms de villes ou de
personnages ne doivent pas devenir la réponse d’un jeu de lettres sauf objectif
linguistique explicite.

Les cinq autres jeux travaillent l’association question–réponse, l’ordre des
mots, le rappel productif, l’intention communicative et la discrimination audio.

## Règles de validation

Avant de publier une nouvelle version de la leçon :

- reconstruire le paquet et le plan audio ;
- vérifier que les 143 identifiants audio sont présents et générés ;
- vérifier l’absence de serveur et des formes retirées `kahvia`, `Haluatko` et
  `Haluaisin` dans les contenus compilés de la leçon 1 ;
- vérifier que `En` reste affiché et que la synthèse française reçoit `Aine` ;
- vérifier qu’au moins six modèles de prononciation utilisent une voix finnoise ;
- vérifier qu’aucune ligne de narrateur n’apparaît en jeu de rôle ;
- tester l’avance automatique après deux secondes ;
- vérifier que le mot mystère remplace bien l’ancien jeu à menus déroulants ;
- exécuter les validateurs de contenu, l’analyse Flutter et les tests Flutter.

Une future scène de service qui emploierait le vouvoiement devra utiliser
`Haluatteko kahvia?`. Cette forme n’est pas enseignée dans la leçon 1.
