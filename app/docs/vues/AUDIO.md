# Vue — leçon audio interactive

## Objectif

Faire écouter, anticiper et produire des réponses sans transformer l’activité en
lecteur passif. L’interface reste volontairement sobre afin que l’attention porte
sur la voix.

## En-tête

- titre de la leçon et étape actuelle ;
- progression approximative ;
- pause ou reprise ;
- fermeture avec sauvegarde ;
- accès aux réglages audio.

Le temps restant peut être masqué pour éviter de détourner l’attention.

## Zone principale

Selon le type de segment, elle affiche :

- une consigne courte ;
- une illustration contextuelle facultative ;
- l’indication « Écoutez », « Répondez » ou « Répétez » ;
- un indicateur de temps de réponse non anxiogène ;
- le bouton principal de lecture ou répétition.

Les personnages restent reconnaissables par leur nom et une représentation stable,
mais le genre et la voix viennent des profils de production audio.

## Déroulement d’un segment

1. lecture de la consigne ou de la réplique ;
2. pause permettant une réponse ;
3. lecture de la réponse modèle ;
4. possibilité de comparer et réécouter ;
5. passage automatique ou manuel au segment suivant.

L’utilisateur peut indiquer « Je ne savais pas » ou « Réponse difficile ». La V1 ne
prétend pas évaluer automatiquement la prononciation sans système ASR validé.

## Transcription

La transcription est une aide graduelle :

- cachée par défaut lors d’une première écoute évaluative ;
- affichable pour le segment courant ;
- synchronisée avec l’audio ;
- conservée visible selon la préférence de l’utilisateur hors évaluation.

Chaque mot utilise le [`texte interactif`](TEXTE_INTERACTIF.md). Un toucher :

- met normalement l’audio en pause ;
- affiche la traduction contextuelle du mot ;
- affiche la traduction de la phrase ou du segment entier ;
- permet de réécouter uniquement cette phrase ;
- enregistre le recours à cette aide.

La traduction de la phrase doit rester disponible même lorsque le segment contient
plusieurs courtes propositions.

## Contrôles

- lecture et pause ;
- réécouter la phrase ;
- reculer d’un segment ;
- vitesse normale ou pédagogique prévue par le contenu ;
- afficher la transcription ;
- afficher la traduction ;
- signaler un problème audio ou linguistique.

Un contrôle libre de vitesse peut être proposé hors exercice, mais l’évaluation
enregistre la vitesse réellement utilisée.

## Réponse orale

En V1, Finn demande à l’utilisateur de répondre à voix haute sans enregistrer par
défaut. Il peut ensuite choisir :

- « Je savais » ;
- « Avec hésitation » ;
- « Je ne savais pas » ;
- « Réécouter et réessayer ».

Une extension future pourra enregistrer localement la réponse, afficher la forme
attendue et fournir un retour ASR prudent.

## Fin de leçon

- compréhension globale ;
- unités rencontrées ;
- unités ayant nécessité transcription ou traduction ;
- suggestions de lecture ou de transfert ;
- prochaine réactivation planifiée.

## États

- audio en téléchargement ;
- segment audio manquant ;
- reprise après interruption ;
- sortie audio indisponible ;
- transcription absente ;
- traduction absente ;
- mode sans écran ;
- erreur signalée sur une phrase.
