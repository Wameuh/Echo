# Vue — lecture

## Objectif

Offrir un texte suffisamment compréhensible tout en permettant une exploration
ponctuelle des mots et expressions. La lecture reste une expérience de sens, pas
une succession de consultations de dictionnaire.

## Avant la lecture

- titre et contexte ;
- niveau ;
- longueur et durée estimée ;
- proportion personnalisée de contenu connu ;
- unités importantes déjà rencontrées ;
- petit nombre d’unités nouvelles prévues ;
- audio du texte disponible ou non.

Une introduction visuelle ou une courte question d’anticipation prépare le contexte
sans révéler le contenu.

## Lecteur

- texte découpé en paragraphes lisibles ;
- taille et espacement configurables ;
- position de lecture sauvegardée ;
- thème clair ou sombre ;
- audio de phrase facultatif ;
- indicateur discret de progression.

Chaque phrase possède un identifiant et une traduction naturelle validée. Chaque
mot ou expression annotée utilise le
[`texte interactif`](TEXTE_INTERACTIF.md).

## Clic sur un mot

Le toucher d’un mot affiche dans un panneau inférieur :

- la forme rencontrée ;
- son lemme ;
- sa traduction dans cette phrase ;
- l’expression englobante lorsqu’elle est plus pertinente ;
- la phrase originale ;
- la traduction de la phrase complète ;
- l’écoute du mot et de la phrase si l’audio existe.

Les détails grammaticaux restent repliés. L’utilisateur peut ajouter volontairement
l’unité aux éléments à revoir, mais un simple clic ne crée pas automatiquement une
flashcard.

## Modes d’aide

- **Lecture naturelle** : aucune annotation visible avant le toucher ;
- **Lecture guidée** : les unités récemment introduites sont discrètement
  soulignées ;
- **Lecture parallèle** : traduction de phrase affichable sous chaque phrase ;
- **Écoute et lecture** : audio synchronisé avec surlignage de la phrase.

La V1 peut commencer par les deux premiers modes. Le mode parallèle doit éviter que
l’utilisateur lise uniquement la traduction.

## Après la lecture

- questions de compréhension ;
- résumé facultatif à choisir ;
- unités comprises sans aide ;
- unités fréquemment consultées ;
- proposition d’une activité différente utilisant les unités centrales.

Finn ne transforme pas chaque mot consulté en échec. Il utilise la fréquence des
aides comme signal parmi d’autres.

## États

- texte non téléchargé ;
- audio facultatif indisponible ;
- traduction partielle ;
- analyse d’un mot indisponible ;
- reprise à une position sauvegardée ;
- nouvelle version du texte ;
- mode hors ligne ;
- taille de police provoquant une nouvelle pagination.
