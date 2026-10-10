# Vue — compréhension

## Objectif

Vérifier que l’apprenant comprend le message d’un audio ou d’un texte, puis fournir
une correction explicative sans réduire l’exercice à une traduction mot à mot.

## Types de questions

- choix d’une information correcte ;
- vrai ou faux ;
- ordre des événements ;
- association d’un interlocuteur à une intention ;
- choix d’une paraphrase ;
- réponse courte ;
- sélection d’un passage justificatif ;
- inférence contextuelle simple.

Les distracteurs doivent rester plausibles sans introduire inutilement du
vocabulaire plus difficile que le texte source.

## Contenu de l’écran

- consigne ;
- question ;
- extrait audio ou textuel si sa consultation est autorisée ;
- réponses possibles ou champ de réponse ;
- action de validation ;
- accès gradué aux aides.

Tout extrait textuel autorisé utilise le
[`texte interactif`](TEXTE_INTERACTIF.md). Le toucher d’un mot donne sa traduction
contextuelle et celle de la phrase entière. Si le mot est précisément l’objet de la
question, cette aide peut être désactivée jusqu’à la réponse puis disponible dans
la correction.

## Aides

- réécouter ou relire ;
- indice sur la partie pertinente ;
- transcription de l’audio ;
- traduction d’un mot ;
- traduction de la phrase ;
- explication après tentative.

Chaque aide est enregistrée pour calibrer la preuve de maîtrise. L’utilisateur sait
avant de l’ouvrir si elle modifiera l’évaluation de la tentative.

## Correction

Après la réponse, afficher :

- résultat ;
- réponse attendue ;
- explication fondée sur le passage ;
- passage original ;
- traduction de la phrase entière ;
- unités linguistiques concernées ;
- possibilité de réécouter ou relire dans le contexte.

Une mauvaise réponse déclenche une future rencontre adaptée, pas nécessairement la
même question.

## Effet sur la maîtrise

Le résultat est attribué aux unités réellement nécessaires pour répondre. Les mots
simplement présents dans l’extrait ne reçoivent qu’une preuve faible ou aucune
preuve.

La réussite est pondérée selon :

- réponse autonome ou aidée ;
- nombre de tentatives ;
- temps de réponse ;
- modalité ;
- nouveauté du contexte.

## États

- question sans réponse choisie ;
- réponse correcte ;
- réponse incorrecte ;
- réponse partiellement correcte ;
- aide utilisée ;
- contenu source indisponible ;
- correction signalée comme ambiguë.
