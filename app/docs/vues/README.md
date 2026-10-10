# Finn — spécification des vues

Dernière mise à jour : 9 septembre 2026

Ce dossier détaille les vues proposées dans le
[`design général`](../DESIGN.md) de Finn. Il décrit le contenu, les actions, les
états et les relations entre écrans sans imposer une technologie d’interface.

## Navigation principale

| Vue | Rôle |
|---|---|
| [`Aujourd’hui`](AUJOURDHUI.md) | Présenter la session recommandée et les éléments dus |
| [`Parcours`](PARCOURS.md) | Montrer la progression structurée par langue et niveau |
| [`Bibliothèque`](BIBLIOTHEQUE.md) | Explorer les leçons, textes et histoires disponibles |
| [`Acquis`](ACQUIS.md) | Examiner la maîtrise et les prochaines révisions |

## Parcours d’activité

| Vue | Rôle |
|---|---|
| [`Session`](SESSION.md) | Orchestrer plusieurs activités dans une même séance |
| [`Vues internes de session`](session/README.md) | Détailler écoute, répétition, lecture, jeux et transitions |
| [`Leçon audio`](AUDIO.md) | Écoute, anticipation et rappel actif |
| [`Lecture`](LECTURE.md) | Lire un texte avec aides contextuelles graduelles |
| [`Compréhension`](COMPREHENSION.md) | Vérifier le sens compris après un texte ou un audio |
| [`Flashcards`](FLASHCARDS.md) | Consolider uniquement les unités sélectionnées |

## Vues transversales

| Vue | Rôle |
|---|---|
| [`Unité linguistique`](UNITE_LINGUISTIQUE.md) | Regrouper sens, exemples, progression et activités d’une unité |
| [`Texte interactif`](TEXTE_INTERACTIF.md) | Définir le clic sur un mot et la traduction de la phrase |
| [`Démarrage`](DEMARRAGE.md) | Choisir la langue, le niveau et l’objectif initial |
| [`Paramètres`](PARAMETRES.md) | Configurer langue d’interface, audio, aides et confidentialité |

## Principes communs

- Une vue met en avant une action principale clairement identifiable.
- Le contenu linguistique utilise les mêmes identifiants d’unités dans tous les
  modes.
- Les aides sont disponibles sans interrompre inutilement l’activité.
- L’ouverture d’une traduction est enregistrée comme une aide utilisée, jamais
  comme une erreur.
- Une progression ne dépend pas uniquement de la complétion d’un écran.
- Le fonctionnement essentiel reste disponible hors ligne après téléchargement du
  contenu.
- Les états de chargement, vide, erreur, téléchargement et contenu indisponible
  sont prévus pour chaque vue concernée.
- Les contrôles restent utilisables au clavier, avec un lecteur d’écran et avec une
  taille de texte agrandie.

## Flux principal

```text
Démarrage
   ↓
Aujourd’hui ─── Parcours ─── Bibliothèque ─── Acquis
   ↓                 ↓              ↓              ↓
Session        Détail leçon     Lecture libre   Unité linguistique
   ↓
Audio → Compréhension → Lecture → Compréhension → Réactivation
                                  ↓
                        Flashcard si pertinente
```

La séquence exacte est adaptée aux unités arrivées à échéance. Le même contenu ne
doit pas être rejoué mécaniquement : Finn cherche une nouvelle modalité ou un
nouveau contexte appartenant à la même famille d’activité.
