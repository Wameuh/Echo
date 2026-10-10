document.querySelectorAll('.play-toggle').forEach(button => button.addEventListener('click', () => {
  const paused = button.textContent === '▶';
  button.textContent = paused ? 'Ⅱ' : '▶';
  button.setAttribute('aria-label', paused ? 'Mettre en pause' : 'Reprendre la lecture');
}));

document.querySelector('.comprehension-toggle').addEventListener('click', () => {
  document.querySelector('.quick-question').hidden = false;
});

document.querySelector('.word').addEventListener('click', () => {
  const sheet = document.querySelector('.word-sheet');
  sheet.hidden = !sheet.hidden;
});

document.querySelectorAll('.answers button').forEach(button => button.addEventListener('click', () => {
  document.querySelectorAll('.answers button').forEach(item => item.classList.remove('selected'));
  button.classList.add('selected');
}));

const games = [
  ['?', 'CHOISIR LE SENS', 'Que signifie cette phrase ?', '▶ Haluaisin kahvia.', ['Demander du café poliment','Demander où est le café','Refuser une boisson']],
  ['♫', 'AUDIO ET SITUATION', 'Où cette phrase est-elle utile ?', '▶ Écouter la phrase', ['Au café','À l’hôtel','Dans un bus']],
  ['↕', 'REMETTRE EN ORDRE', 'Construisez la phrase.', 'Haluaisin · kahvia · kiitos', ['Haluaisin','kahvia','kiitos']],
  ['…', 'COMPLÉTER', 'Quel mot manque ?', '_____ kartan, kiitos.', ['Haluaisin','Missä','Anteeksi']],
  ['A/M', 'QUI A DIT QUOI ?', 'Qui souhaite du café ?', '▶ Réécouter l’extrait', ['Anna','Mikko','Juhani']],
  ['✓', 'VRAI OU FAUX', 'Anna commande du thé.', '▶ Vérifier dans la scène', ['Vrai','Faux','Je ne sais pas']],
  ['↗', 'PHRASE ADAPTÉE', 'Vous commandez poliment.', 'Situation : au restaurant', ['Haluaisin vettä.','Missä vesi on?','En halua vettä.']],
  ['≋', 'ÉCOUTE DISCRIMINANTE', 'Quelle phrase entendez-vous ?', '▶ Écouter', ['Haluan kahvia.','Haluaisin kahvia.','Halusin kahvia.']]
];

document.querySelectorAll('.game-tabs button').forEach(button => button.addEventListener('click', () => {
  const game = games[Number(button.dataset.game)];
  document.querySelectorAll('.game-tabs button').forEach(item => item.classList.remove('active'));
  button.classList.add('active');
  document.querySelector('.game-icon').textContent = game[0];
  document.querySelector('.game-kind').textContent = game[1];
  document.querySelector('.game-title').textContent = game[2];
  document.querySelector('.game-audio').textContent = game[3];
  const answers = document.querySelector('.answers');
  answers.replaceChildren(...game[4].map(label => {
    const answer = document.createElement('button');
    answer.textContent = label;
    answer.addEventListener('click', () => {
      answers.querySelectorAll('button').forEach(item => item.classList.remove('selected'));
      answer.classList.add('selected');
    });
    return answer;
  }));
}));

document.querySelector('.validate-game').addEventListener('click', () => {
  const phone = document.querySelector('.game-phone');
  phone.classList.remove('flash');
  requestAnimationFrame(() => requestAnimationFrame(() => phone.classList.add('flash')));
});
