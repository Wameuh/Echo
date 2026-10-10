# Vue — flashcards

## Objectif

Consolider les unités linguistiques qui justifient un rappel isolé, sans transformer
tous les mots rencontrés en dette de révision.

## Entrée dans la vue

Les cartes peuvent apparaître :

- dans une session recommandée ;
- dans une révision courte ;
- depuis une unité linguistique ;
- après une demande explicite de l’utilisateur ;
- après plusieurs difficultés contextuelles.

Finn indique le temps estimé, pas seulement le nombre de cartes.

## Face question

Selon la compétence travaillée :

- mot ou expression en langue cible ;
- traduction ou intention à produire ;
- extrait audio ;
- phrase à trou ;
- contraste entre deux formes proches ;
- image ou situation communicative.

La carte conserve suffisamment de contexte pour éviter une traduction ambiguë.

## Révélation

La face réponse affiche :

- réponse attendue ;
- traduction naturelle ;
- phrase exemple ;
- traduction de la phrase entière ;
- audio du mot, de l’expression et de la phrase ;
- détails grammaticaux repliables ;
- lien vers la vue de l’unité.

Le texte exemple utilise le [`texte interactif`](TEXTE_INTERACTIF.md). Tous ses mots
peuvent être consultés après la réponse. Avant la réponse, les aides sont limitées
selon le type de rappel.

## Auto-évaluation

La V1 propose des réponses simples :

- oublié ;
- difficile ;
- correct avec hésitation ;
- correct facilement.

Le temps, les aides et la modalité complètent ce jugement. L’algorithme planifie la
prochaine rencontre de l’unité, qui peut être une lecture ou un audio plutôt qu’une
nouvelle carte.

## Création et sélection

Une carte peut être proposée lorsque l’unité est importante, transférable,
difficile ou nécessaire prochainement. L’utilisateur confirme son ajout lorsque la
proposition provient simplement d’un mot consulté.

Il peut :

- suspendre une carte ;
- choisir une autre direction de rappel ;
- signaler une traduction incorrecte ;
- demander davantage de contexte ;
- conserver l’unité sans flashcard.

Il n’existe pas de limite fixe par leçon. Finn surveille plutôt la charge quotidienne
prévisionnelle et diffère les cartes secondaires si nécessaire.

## États

- aucune carte due ;
- carte nouvelle ;
- carte issue d’une difficulté ;
- réponse masquée ou révélée ;
- contenu audio indisponible ;
- carte suspendue ;
- unité maîtrisée en contexte et carte devenue optionnelle.
