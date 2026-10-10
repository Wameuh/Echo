# Vue — Aujourd’hui

## Objectif

Donner immédiatement une action pertinente sans obliger l’utilisateur à choisir
entre audio, lecture et flashcards. Cette vue assemble une session à partir des
unités arrivées à échéance, de la progression courante et du temps disponible.

## En-tête

- langue actuellement étudiée ;
- série de jours facultative, sans pression excessive ;
- objectif quotidien en minutes ;
- accès au changement de langue ;
- état des contenus nécessaires hors ligne.

## Carte principale

La carte « Continuer » affiche :

- le thème de la session ;
- sa durée estimée ;
- les modalités prévues ;
- le nombre approximatif d’unités réactivées et nouvelles ;
- l’étape actuelle si la session a été interrompue ;
- une action principale « Commencer » ou « Reprendre ».

Elle ne présente pas une longue liste de tâches obligatoires. Le détail de la
séquence reste consultable avant de commencer.

## Révisions dues

Un résumé indique :

- unités à réactiver aujourd’hui ;
- activités déjà planifiées ;
- éventuelle charge reportée ;
- temps estimé plutôt qu’un simple nombre de cartes.

L’action « Révision courte » construit une séquence multimodale. Elle peut contenir
un micro-audio, une phrase de lecture et quelques rappels ciblés.

## Suggestions secondaires

- prochaine étape du parcours ;
- lecture courte adaptée au niveau ;
- activité libre récemment commencée ;
- téléchargement conseillé avant un déplacement.

Les suggestions expliquent brièvement leur raison : « pour revoir les demandes
polies » ou « adapté à votre compréhension écrite actuelle ».

## Fin de journée

Lorsque l’objectif est atteint, la vue met en avant :

- les unités renforcées ;
- un exemple de transfert réussi ;
- la prochaine échéance importante ;
- une activité libre facultative.

## États

- nouvel utilisateur sans historique ;
- aucune révision due ;
- nombreuses révisions en retard ;
- contenu principal non téléchargé ;
- session interrompue ;
- mode hors ligne ;
- objectif quotidien atteint.

En cas de retard important, Finn répartit la charge sur plusieurs jours et évite
un message culpabilisant.
