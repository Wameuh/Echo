# Vue et composant — texte interactif

## Objectif

Permettre à l’utilisateur de comprendre un mot sans perdre le sens de la phrase.
Un clic ou toucher affiche simultanément :

1. la forme sélectionnée ;
2. sa traduction dans ce contexte ;
3. sa forme canonique ou son lemme ;
4. la traduction de la phrase entière.

Ce composant est utilisé dans les lectures, les transcriptions audio, les questions
de compréhension, les corrections et les exemples associés aux unités
linguistiques.

## Interaction principale

Lorsque l’utilisateur touche un mot :

- le mot est visuellement sélectionné dans la phrase ;
- une fiche compacte s’ouvre en bas de l’écran ;
- la fiche affiche d’abord la traduction contextuelle du mot ;
- la traduction de la phrase complète est visible juste en dessous ;
- un second toucher ailleurs ferme la fiche ou sélectionne un autre mot.

Sur grand écran, la fiche peut être affichée dans un panneau latéral. Sur téléphone,
elle prend la forme d’un panneau inférieur que l’utilisateur peut agrandir.

## Contenu de la fiche

### Zone principale

- mot tel qu’il apparaît ;
- lemme ou forme canonique ;
- catégorie grammaticale ;
- traduction adaptée à la phrase ;
- indication du registre si elle est utile ;
- bouton permettant d’écouter le mot ou l’expression.

### Phrase complète

- phrase originale ;
- traduction naturelle de la phrase entière ;
- bouton pour écouter ou réécouter la phrase ;
- indication de la source : lecture, dialogue ou exemple.

La traduction de phrase doit être naturelle. Elle n’est pas construite en
concaténant mécaniquement les traductions de chaque mot.

### Informations facultatives

- analyse de la forme fléchie ;
- cas grammatical, temps ou personne ;
- expression plus longue contenant le mot ;
- exemple supplémentaire ;
- état d’apprentissage de l’unité ;
- action « Ajouter aux éléments à revoir ».

Ces informations sont repliées par défaut pour ne pas transformer chaque clic en
cours de grammaire.

## Expressions composées

Le système privilégie l’unité qui porte réellement le sens. Si l’utilisateur touche
un mot appartenant à une expression connue, la fiche indique :

```text
Mot sélectionné : tavata
Expression dans cette phrase : Hauska tavata
Sens de l’expression : Enchanté / Ravi de vous rencontrer
Sens littéral ou grammatical : disponible dans les détails
```

L’utilisateur peut basculer entre l’analyse du mot seul et celle de l’expression.
La traduction contextuelle de l’expression est affichée en premier lorsqu’elle est
plus utile que celle du mot isolé.

## Ambiguïtés et formes fléchies

Le fichier de contenu doit fournir une analyse validée pour la phrase. Finn ne doit
pas choisir une traduction uniquement à partir d’un dictionnaire général.

Pour chaque occurrence, le contenu peut référencer :

- son unité linguistique ;
- sa plage de caractères ;
- son lemme ;
- sa forme grammaticale ;
- son sens contextuel ;
- l’identifiant d’une expression englobante ;
- les alternatives utiles.

Si une analyse n’est pas disponible, l’interface l’indique clairement au lieu de
présenter une traduction incertaine comme certaine.

## Sélection d’une phrase

La phrase contenant le mot est déterminée lors de la préparation du contenu. La
ponctuation, les abréviations et les dialogues ne doivent pas dépendre d’une
segmentation improvisée sur l’appareil.

Une phrase peut être touchée sans sélectionner de mot grâce à une action dédiée
« Traduire la phrase ». Cette option est utile pour les lecteurs d’écran et lorsque
la phrase contient une expression difficile à sélectionner précisément.

## Niveaux d’aide

Le texte interactif respecte l’ordre d’aide suivant :

1. aucune aide, contexte seulement ;
2. traduction d’un mot ou d’une expression ;
3. traduction de la phrase ;
4. explication grammaticale ;
5. traduction du paragraphe, si le contenu la propose.

La fiche affiche immédiatement le mot et la phrase comme demandé, mais Finn
enregistre séparément les sections réellement consultées. La simple ouverture de
la fiche ne signifie donc pas forcément que l’utilisateur a lu l’explication
grammaticale.

## Utilisation dans l’audio

Dans une transcription synchronisée :

- le segment en cours est surligné ;
- toucher un mot met l’audio en pause, sauf préférence contraire ;
- la fiche affiche la traduction du mot et du segment ou de la phrase entière ;
- fermer la fiche permet de reprendre à l’endroit interrompu ;
- l’utilisateur peut réécouter uniquement la phrase sélectionnée.

La transcription reste cachée par défaut dans les exercices où elle constitue une
aide importante.

## Utilisation dans les exercices

Dans une question de compréhension, toucher le texte peut être autorisé ou non
selon l’objectif. Lorsque l’aide est autorisée :

- son utilisation est enregistrée ;
- la question reste accessible ;
- la note de maîtrise tient compte de l’aide ;
- aucune pénalité émotionnelle ou message culpabilisant n’est affiché.

Pour un exercice évaluant précisément un mot, la traduction directe de ce mot peut
être différée jusqu’après la réponse.

## Accessibilité

- Chaque mot interactif doit être accessible sans exiger un toucher très précis.
- Un lecteur d’écran annonce le mot, puis propose l’action « Afficher la
  traduction et la phrase ».
- La sélection au clavier utilise les flèches ou la tabulation sans fragmenter la
  lecture de manière excessive.
- La couleur de sélection est accompagnée d’un soulignement ou d’un changement de
  fond.
- Le panneau respecte les tailles de police et contrastes configurés.

## Données minimales

Exemple conceptuel pour une occurrence :

```json
{
  "surface": "kahvia",
  "start": 11,
  "end": 17,
  "unit_id": "fi.noun.kahvi",
  "lemma": "kahvi",
  "part_of_speech": "noun",
  "grammar": {
    "case": "partitive",
    "number": "singular"
  },
  "translation": "du café",
  "sentence_id": "sentence-004"
}
```

La phrase référencée contient son texte original et sa traduction complète :

```json
{
  "id": "sentence-004",
  "text": "Haluaisin kahvia.",
  "translation": "Je voudrais du café."
}
```

Les indices de caractères doivent être définis selon une convention unique et
testée, notamment pour les caractères Unicode.

## Événements enregistrés

- ouverture de la traduction d’un mot ;
- consultation de la phrase traduite ;
- ouverture d’une explication grammaticale ;
- écoute du mot ;
- réécoute de la phrase ;
- ajout volontaire aux éléments à revoir.

Ces événements servent à estimer la difficulté et à recommander de futures
rencontres. Ils ne doivent pas être utilisés pour remplir automatiquement le paquet
de flashcards avec tous les mots touchés.

## États particuliers

- traduction disponible hors ligne ;
- traduction non téléchargée ;
- analyse contextuelle indisponible ;
- mot faisant partie de plusieurs expressions ;
- phrase contenant plusieurs langues ;
- contenu corrigé dans une version plus récente ;
- erreur de synchronisation entre audio et texte.
