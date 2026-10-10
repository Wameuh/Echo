# Echo — design général de l’application

Dernière mise à jour : 9 septembre 2026

## Vision

Echo est une application d’apprentissage des langues centrée sur le
*comprehensible input* : l’apprenant rencontre une langue qu’il comprend presque
entièrement, découvre un petit nombre d’éléments nouveaux grâce au contexte, puis
les retrouve à intervalles croissants dans des situations variées.

L’application ne doit pas être une juxtaposition de leçons audio, d’un lecteur et
d’un paquet de flashcards. Ces modes doivent exploiter les mêmes unités
linguistiques et contribuer à un même modèle de progression.

Le finnois constitue la première langue cible. Son contenu pédagogique utilise le
`kirjakieli` afin de proposer une grammaire et une prononciation stables. Le modèle
doit néanmoins pouvoir accueillir d’autres langues sans intégrer de règles
finnoises dans son noyau générique.

## Principes directeurs

1. **Comprendre avant de mémoriser isolément.** Un mot ou une construction est
   d’abord rencontré dans une situation porteuse de sens.
2. **Répéter la langue, pas le contenu.** Une unité revient dans de nouvelles
   phrases, avec d’autres interlocuteurs et dans plusieurs modalités.
3. **Privilégier les expressions utiles.** Une construction comme `Haluaisin…`
   est souvent plus productive qu’une collection de mots isolés.
4. **Rendre les aides graduelles.** Le contexte précède le glossaire, qui précède
   la transcription ou la traduction complète.
5. **Espacer toutes les rencontres.** La répétition espacée concerne les audios,
   les lectures et les exercices, pas seulement les flashcards.
6. **Mesurer plusieurs compétences.** Reconnaître une expression à l’écrit ne
   garantit ni sa compréhension orale ni sa production.
7. **Séparer contenu et rendu.** Une leçon décrit une intention vocale générique ;
   un adaptateur la traduit pour le moteur TTS choisi.
8. **Conserver une V1 simple.** Les règles doivent être explicables, observables et
   remplaçables avant d’introduire une adaptation plus sophistiquée.

## Expérience d’apprentissage

Une session quotidienne associe plusieurs activités courtes autour d’un objectif
commun :

1. réactivation de quelques unités arrivées à échéance ;
2. activité principale d’écoute ou de lecture ;
3. questions de compréhension portant sur le sens ;
4. transfert des unités importantes dans un autre contexte ;
5. flashcards uniquement lorsque leur valeur pédagogique le justifie ;
6. synthèse des acquis et planification de la prochaine rencontre.

La session ne doit pas nécessairement présenter tous ces modes chaque jour. Echo
compose une séquence selon les éléments dus, les faiblesses de l’apprenant, le
temps disponible et la variété récente.

## Noyau commun : les unités linguistiques

Une `language_unit` représente un élément que Echo souhaite suivre dans le temps.
Il peut s’agir :

- d’un mot ou d’un lemme ;
- d’une expression figée ;
- d’une construction productive ;
- d’un point grammatical ;
- d’une distinction de prononciation ;
- d’une forme fléchie importante pour un niveau donné.

Exemple conceptuel :

```json
{
  "id": "fi.expression.haluaisin",
  "language": "fi-FI",
  "type": "construction",
  "canonical_form": "Haluaisin…",
  "meanings": {
    "fr-FR": "Je voudrais…",
    "en-US": "I would like…"
  },
  "register": "kirjakieli",
  "cefr_level": "A1",
  "functions": ["express_a_polite_wish"],
  "tags": ["requests", "politeness"]
}
```

Les dialogues et les textes conservent leurs formulations naturelles, mais ils
référencent les identifiants des unités qu’ils introduisent ou renforcent. Les
traductions, explications et informations grammaticales ne sont ainsi pas
dupliquées dans chaque activité.

## Activités

Toutes les activités partagent un socle minimal :

- un identifiant stable ;
- une famille d’activité ;
- une langue et un niveau ;
- un contexte ;
- des objectifs et prérequis ;
- les unités introduites, ciblées et simplement présentes ;
- les compétences sollicitées ;
- une estimation de difficulté ;
- les aides disponibles.

### Leçons audio interactives

Les leçons audio conservent les qualités recherchées dans une approche inspirée de
Pimsleur : anticipation, rappel actif, réponse à voix haute, progression graduelle
et retours espacés.

Une leçon est composée de segments indépendants comprenant notamment :

- le locuteur et la langue ;
- le texte à synthétiser ;
- son intention pédagogique ;
- une direction vocale générique ;
- les pauses avant, après et éventuellement dans la phrase ;
- les unités linguistiques concernées ;
- le type de réponse attendu ;
- une clé de correction lorsqu’elle est pertinente.

Le format pédagogique ne contient aucune balise propre à Higgs. La séparation
entre voix, direction et moteur TTS est détaillée dans
[`audio-generation/docs/INFERENCE.md`](../../audio-generation/docs/INFERENCE.md).

### Lecture de textes

La V1 utilise de courts textes écrits ou sélectionnés pour le parcours. Chaque
document contient :

- un titre, une situation et un niveau ;
- des paragraphes segmentés en phrases ;
- les unités présentes dans chaque phrase ;
- des traductions ou explications facultatives ;
- des questions de compréhension ;
- une estimation de la proportion connue et nouvelle ;
- une licence ou une provenance lorsque le texte n’est pas original.

Le texte associé à une leçon audio ne doit généralement pas en être la
transcription. Il reprend les mêmes constructions dans une autre situation afin de
vérifier leur transfert.

L’import libre de PDF, EPUB, pages Web ou documents numérisés est reporté. Il
nécessitera une segmentation fiable, une gestion des droits, une estimation de
difficulté et, pour les documents personnels, des garanties de confidentialité.

### Compréhension

Les exercices de compréhension évaluent d’abord le message :

- identifier qui parle et dans quelle situation ;
- retrouver une information ;
- reconnaître l’intention d’une phrase ;
- remettre des événements dans l’ordre ;
- choisir une paraphrase ;
- déduire un élément grâce au contexte.

Les questions de traduction mot à mot restent possibles, mais ne doivent pas
devenir la mesure principale de compréhension.

### Flashcards sélectives

Echo ne transforme pas automatiquement tous les mots rencontrés en cartes. Une
unité mérite une flashcard lorsqu’au moins un des critères suivants s’applique :

- elle est un objectif explicite du parcours ;
- elle sera nécessaire dans les activités suivantes ;
- elle est fréquente et transférable à de nombreux contextes ;
- sa forme est difficile à reconstruire ou à distinguer ;
- elle est importante en production active ;
- plusieurs rencontres contextualisées ont échoué ;
- l’apprenant demande explicitement à la conserver.

Une carte est généralement évitée pour un nom propre, un détail propre à une seule
histoire, un cognat évident ou une unité déjà maîtrisée dans plusieurs contextes.

Il n’existe pas de quota fixe de cartes par leçon. Leur densité dépend du niveau,
du contenu et des résultats. Echo régule plutôt la charge de révision future : les
cartes secondaires peuvent être différées lorsque le temps quotidien prévu serait
dépassé.

Une même unité peut proposer plusieurs formes de rappel :

- langue cible vers sens ;
- sens vers langue cible ;
- audio vers sens ;
- phrase à compléter ;
- choix entre des formes proches ;
- plus tard, production orale ou dictée.

Ces variantes partagent le même état linguistique sous-jacent et ne deviennent pas
des connaissances entièrement séparées.

## Calibrage du comprehensible input

Les proportions suivantes constituent des heuristiques initiales à ajuster lors
des tests :

| Activité | Contenu déjà connu | Récemment introduit | Réellement nouveau |
|---|---:|---:|---:|
| Lecture guidée | 85–90 % | 5–10 % | au plus environ 5 % |
| Compréhension orale | 90–95 % | 5–10 % | très peu |

La compréhension orale exige généralement une couverture connue plus élevée, car
l’apprenant ne peut pas examiner chaque mot instantanément.

Pour un niveau débutant, Echo vise également :

- deux à quatre unités réellement nouvelles dans une activité courte ;
- une difficulté nouvelle majeure au maximum par phrase ;
- des phrases brèves et une grammaire contrôlée ;
- un débit clair, naturel et légèrement ralenti ;
- des indices contextuels portés par des unités déjà connues.

La difficulté ne dépend pas seulement du nombre de mots nouveaux. Elle inclut la
longueur des phrases, la complexité grammaticale, le débit, la qualité sonore, la
prévisibilité du contexte et le nombre d’informations à retenir.

### Aides graduelles

Les aides sont proposées dans cet ordre :

1. contexte, titre ou illustration ;
2. répétition du segment ;
3. glossaire au toucher ;
4. transcription ;
5. traduction complète.

Echo enregistre les aides utilisées. Une réponse autonome fournit une preuve de
maîtrise plus forte qu’une réponse obtenue après affichage de la traduction.

## Répétition avec variation

Une unité revient sans imposer le même exercice. Chaque nouvelle rencontre change
si possible au moins deux dimensions parmi :

- la modalité ;
- le contexte ;
- le locuteur ;
- le vocabulaire environnant ;
- l’intention communicative ;
- la structure de la question ;
- le niveau d’aide.

Exemple avec `Haluaisin…` :

- café : `Haluaisin kahvia.` ;
- message : `Haluaisin syödä pian.` ;
- office du tourisme : `Haluaisin kartan.` ;
- hôtel : `Haluaisin huoneen.`.

La réécoute exacte reste utile lorsqu’elle répond à un objectif précis, par exemple
distinguer un son ou comprendre un passage précédemment manqué. Elle n’est pas le
mécanisme de révision par défaut.

## Répétition espacée multimodale

La planification porte sur la prochaine rencontre d’une unité linguistique, et non
uniquement sur une carte. L’état d’une unité pour un apprenant comprend :

- la prochaine échéance ;
- sa stabilité et sa difficulté estimées ;
- la dernière rencontre ;
- les compétences observées par modalité ;
- les derniers contextes et activités ;
- les aides utilisées ;
- les erreurs récentes.

Lorsqu’une unité arrive à échéance, Echo choisit une activité qui :

1. entraîne une compétence encore faible ;
2. utilise une modalité peu pratiquée récemment ;
3. évite les derniers contextes rencontrés ;
4. permet, si possible, de couvrir plusieurs unités dues naturellement ;
5. reste suffisamment compréhensible dans son ensemble.

### Règle initiale pour la V1

- échec : nouvelle rencontre guidée le jour même ou le lendemain ;
- réussite avec une aide importante : retour dans un à deux jours ;
- réussite autonome : retour autour de trois jours ;
- deux réussites autonomes dans des modalités ou contextes distincts : retour
  autour de sept jours ;
- réussites diversifiées suivantes : quatorze jours, puis environ trente jours ;
- nouvel échec : réduction de l’intervalle et activité plus guidée.

Ces intervalles sont des paramètres de départ. L’historique brut des tentatives est
conservé afin de pouvoir adopter ultérieurement un algorithme comme FSRS sans
perdre les données d’apprentissage.

## Progression et suivi des acquis

La progression ne se réduit pas au nombre de leçons terminées. Elle repose sur un
ensemble de compétences par unité :

- compréhension orale ;
- compréhension écrite ;
- rappel du sens ;
- production orale ;
- production écrite ou orthographe.

Chaque tentative produit un événement immuable comprenant :

- l’unité et l’activité ;
- la compétence observée ;
- la réponse et son résultat ;
- les aides utilisées ;
- le temps de réponse ;
- le contexte et la modalité ;
- la date.

Le niveau CECR organise les objectifs et la difficulté du contenu. Le passage au
bloc suivant peut demander :

- la réalisation des activités essentielles ;
- une compréhension minimale dans plusieurs modalités ;
- la maîtrise de certaines unités prérequises ;
- aucune accumulation excessive de révisions en retard.

L’application doit néanmoins laisser l’utilisateur explorer du contenu plus avancé
sans confondre cette exploration avec une maîtrise validée.

## Recommandation de la prochaine activité

La V1 utilise un moteur de règles explicable. Elle exclut d’abord les activités
dont les prérequis ou le niveau de compréhension estimé sont incompatibles, puis
favorise :

- les unités arrivées à échéance ;
- les compétences faibles ;
- les objectifs du parcours courant ;
- les activités qui couvrent plusieurs besoins sans surcharge ;
- une modalité et un contexte différents des derniers exercices ;
- une durée compatible avec la session souhaitée.

Une activité possède un `activity_family_id`, un `activity_id`, un `context_id` et
une `variant_group`. Lorsqu’une unité est due, Echo préfère une variante jamais
vue, puis un nouveau contexte, puis une nouvelle modalité. Le contenu exact déjà
utilisé ne revient qu’en dernier recours ou pour un objectif d’écoute explicite.

## Exemple de mini-parcours

Objectif : exprimer un souhait avec `Haluaisin…` et demander un lieu avec
`Missä … on?`.

| Étape | Activité | Variation et preuve |
|---|---|---|
| 1 | Dialogue au café | Découverte de `Haluaisin kahvia` à l’écoute |
| 2 | Questions sur la scène | Compréhension du sens général |
| 3 | Message écrit depuis une gare | Lecture de `Haluaisin syödä` dans un autre contexte |
| 4 | Dialogue à l’office du tourisme | Transfert vers `Haluaisin kartan` et `Missä museo on?` |
| 5 | Flashcards sélectionnées | Rappel des deux constructions, si nécessaire |
| 6 | Scène d’hôtel quelques jours plus tard | Réactivation avec `Haluaisin huoneen` et `Missä hissi on?` |

Le texte n’est jamais une simple transcription du premier dialogue. Chaque étape
apporte une information ou une situation nouvelle tout en réactivant les unités
centrales.

## Architecture des données

Echo sépare trois catégories de données.

### Contenu versionné

- langues, niveaux et parcours ;
- unités linguistiques ;
- activités et relations entre elles ;
- textes, dialogues, questions et solutions ;
- profils vocaux et intentions génériques ;
- références vers les médias générés.

Le contenu peut être rédigé en YAML, validé, puis compilé en JSON pour
l’application. Le Markdown devient un aperçu généré ou une documentation, plutôt
qu’une seconde source à maintenir manuellement.

### État local de l’apprenant

- événements de tentative ;
- maîtrise calculée par unité et compétence ;
- échéances de répétition ;
- préférences, objectifs et temps quotidien ;
- téléchargements et progression locale.

Sur Android, une base locale comme Room/SQLite convient à cet état. Le contenu
statique peut être distribué sous forme de paquets versionnés.

### Médias générés

- fichiers audio individuels ;
- assemblages de leçons ;
- images éventuelles ;
- manifestes contenant modèle, voix, paramètres, seed et contrôles qualité.

Le modèle TTS reste sur le poste de production. L’application consomme uniquement
les médias exportés et leurs manifestes.

## Navigation produit proposée

Le contenu détaillé de chaque écran et des composants transversaux est regroupé
dans la [`spécification des vues`](vues/README.md).

La V1 peut rester organisée autour de quatre surfaces principales :

1. **Aujourd’hui** : session recommandée et révisions dues ;
2. **Parcours** : progression structurée par langue et niveau ;
3. **Bibliothèque** : textes, histoires et leçons accessibles librement ;
4. **Acquis** : unités apprises, compétences, échéances et difficultés.

Les flashcards ne nécessitent pas forcément un onglet principal. Elles apparaissent
dans les sessions et peuvent être consultées depuis une unité ou depuis la page des
acquis.

## Première version réaliste

1. Stabiliser un schéma commun avec identifiants d’unités et d’activités.
2. Extraire le vocabulaire existant dans un petit catalogue partagé.
3. Relier les segments audio existants à ces unités.
4. Ajouter les événements de tentative et un état de maîtrise local.
5. Introduire quelques lectures courtes liées aux mêmes objectifs que les audios.
6. Ajouter des questions de compréhension simples.
7. Générer ou rédiger les flashcards réellement justifiées.
8. Mettre en place la règle d’espacement multimodale initiale.
9. Composer une session quotidienne avec variation de modalité et de contexte.
10. Mesurer les abandons, aides utilisées, erreurs et retours réussis.

## Extensions futures

- import EPUB, PDF, pages Web et documents personnels ;
- segmentation, glossaire et estimation automatique de difficulté ;
- création assistée de variantes contextuelles ;
- reconnaissance vocale et retour sur la prononciation ;
- dictée et production écrite ;
- conversations libres ou scénarisées ;
- algorithme d’espacement plus avancé ;
- synchronisation entre appareils ;
- parcours communautaires et packs de contenu ;
- prise en charge contrôlée de registres supplémentaires, dont éventuellement le
  `puhekieli` à un niveau plus avancé.

## Risques à surveiller

- **Surcharge de contenu** : trop d’unités nouvelles réduit la compréhension.
- **Fausse variété** : changer seulement un nom ne garantit pas un nouveau contexte
  cognitif.
- **Explosion des cartes** : chaque mot rencontré ne doit pas devenir une dette de
  révision.
- **Mesure trop optimiste** : une réussite avec traduction ne vaut pas une réussite
  autonome.
- **Dérive entre formats** : JSON, YAML et Markdown ne doivent pas être trois
  sources concurrentes.
- **Dépendance au TTS** : les leçons doivent rester indépendantes de Higgs.
- **Contenu généré incorrect** : toute génération linguistique ou audio destinée au
  parcours doit être validée.
- **Progression rigide** : les prérequis guident la recommandation sans empêcher
  l’exploration.

## Décisions recommandées

- Faire de l’unité linguistique la source commune de progression.
- Planifier des rencontres multimodales plutôt que des cartes isolées.
- Utiliser la répétition avec variation comme mécanisme central.
- Réserver les flashcards aux éléments importants ou insuffisamment maîtrisés.
- Commencer avec des lectures courtes et contrôlées plutôt qu’un lecteur universel.
- Conserver l’historique des tentatives séparément de l’état de maîtrise calculé.
- Employer un moteur de recommandation à règles pour la V1.
- Garder le contenu et les intentions vocales indépendants du moteur TTS.
- Utiliser une source éditoriale canonique, puis générer les formats dérivés.
