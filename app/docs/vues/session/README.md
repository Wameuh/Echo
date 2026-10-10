# Finn — vues internes d’une session

## Objectif

Décrire les micro-écrans qui composent une session d’apprentissage. Ces vues ne
sont pas des rubriques indépendantes de l’application : elles s’enchaînent dans un
flux continu piloté par les unités linguistiques à découvrir ou réactiver.

## Séquence de référence

```text
Mise en contexte
      ↓
Leçon audio guidée
      ↓
Compréhension rapide
      ↓
Jeux de rôle
      ↓
Transition de contexte
      ↓
Lecture courte
      ↓
Compréhension du texte
      ↓
Memory de phrases
      ↓
Mini-jeu de manipulation ou de compréhension
      ↓
Réactivation audio ou productive
      ↓
Bilan et planification
```

La séquence n’est pas rigide. Finn retire une étape lorsqu’elle n’apporte pas de
preuve utile et ajoute une reprise guidée lorsqu’un élément reste incompris.

## Vues documentées

Les [vues conceptuelles interactives](concepts/index.html) traduisent les huit
spécifications ci-dessous avec la baseline Echo v2.

| Vue | Fonction |
|---|---|
| [`Mise en contexte`](MISE_EN_CONTEXTE.md) | Préparer la situation sans traduire tout le contenu |
| [`Écoute`](ECOUTE.md) | Comprendre d’abord le sens global d’un passage audio |
| [`Rappel oral`](RAPPEL_ACTIF.md) | Produire avant le modèle, directement dans la piste audio |
| [`Lecture de session`](LECTURE.md) | Réutiliser les unités dans un nouveau texte |
| [`Memory`](MEMORY.md) | Associer des mots finnois à des dessins |
| [`Mini-jeux`](MINI_JEUX.md) | Manipuler le sens, l’ordre et les formes sans activité gratuite |
| [`Transition`](TRANSITION.md) | Expliquer le changement de modalité ou de contexte |
| [`Bilan`](BILAN.md) | Montrer les acquis et programmer les prochaines rencontres |

La déclinaison complète de ce parcours pour la première leçon est décrite dans
[`LESSON1.md`](LESSON1.md).

## Éléments persistants

Toutes les vues internes partagent un cadre minimal :

- fermeture avec sauvegarde ;
- progression dans la session ;
- titre très court de l’étape ;
- accès au son ;
- menu d’accessibilité ;
- action principale située au même endroit ;
- absence de barre de navigation globale pendant l’activité.

La progression représente des étapes, pas un compte à rebours à la seconde. Elle
peut prendre la forme de quelques points ou segments afin de rester lisible.

## Règles pédagogiques

- Une vue ne présente qu’un objectif cognitif principal.
- Une nouvelle unité est d’abord portée par un contexte compréhensible.
- La réponse de l’apprenant précède la correction lorsque l’objectif est le rappel.
- Les jeux réutilisent des unités déjà contextualisées ; ils n’introduisent pas une
  liste de nouveaux mots hors contexte.
- Le texte cliquable reste disponible lorsque cela ne révèle pas directement la
  réponse évaluée.
- Une aide réduit la force de la preuve de maîtrise, mais n’est jamais traitée comme
  une faute.
- Une répétition exacte est utilisée pour la prononciation ; une révision espacée
  préfère un nouveau contexte.

## Session courte

Une session courte conserve une boucle pédagogique complète :

```text
contexte → activité principale → vérification → rappel → bilan
```

Elle réduit le nombre d’unités et de variantes plutôt que de supprimer la
compréhension ou le rappel final.
