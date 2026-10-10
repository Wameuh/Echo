# Echo

Echo est une application Flutter d’apprentissage des langues centrée sur l’écoute.
Le premier parcours enseigne le finnois standard (`kirjakieli`) avec des dialogues,
des répétitions et des activités de compréhension.

## Contenu du dépôt

- `app/` contient l’application, ses tests et sa configuration Flutter.
- `app/assets/` contient les leçons, les médias et les ressources visuelles utilisés
  par l’application.
- `app/design-showcase/assets/` conserve les SVG de marque utilisés par l’interface.

Le pipeline Higgs et les recherches de génération audio sont conservés localement dans
`audio-generation/`, mais ignorés par Git. Les notes d’architecture et les fichiers
de maquettes visuelles sont également conservés localement sans être suivis par Git.

Pour démarrer ou vérifier l’application, consulter [`app/README.md`](app/README.md).

## Licence

Le projet est distribué sous licence MIT. Voir [LICENSE](LICENSE).
