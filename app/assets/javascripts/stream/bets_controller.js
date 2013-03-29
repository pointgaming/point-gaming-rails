var PointGaming = PointGaming || {};

PointGaming.BetsController = function(options){
  this.socket = PointGaming.socket;
  this.exchange_name = options.chat_room;

  this.bet_window_selector = 'tbody#bet-container';
  this.bet_selector = 'tr.bet';
  this.bet_actions_column_selector = 'td.actions';

  this.registerHandlers();
};

PointGaming.BetsController.prototype.appendBet = function(bet, tooltip, url) {
  var options = {
        id: bet._id,
        title: "Bet Details",
        class: "bet",
        "data-content": tooltip,
        "data-match-id": bet.match_id
      },
      attributes = "",
      actions = "",
      message = "",
      key;

  for (key in options) {
    if (options.hasOwnProperty(key)) {
      attributes += key + '="' + options[key] + '" ';
    }
  }

  if (PointGaming.user._id === bet.bookie._id) {
    actions += '<a href="'+ url +'" class="btn" data-confirm="Are you sure?" data-method="delete" data-remote="true" data-type="json" rel="nofollow">Cancel</a>';
  } else {
    actions += '<a href="'+ url +'" class="btn" data-confirm="Are you sure?" data-method="put" data-remote="true" data-type="json" rel="nofollow">Accept</a>';
  }

  message += "<td>" + bet.winner_name + "</td>";
  message += "<td>" + bet.loser_name + "</td>";
  message += "<td>" + bet.amount + "</td>";
  message += "<td>" + bet.odds + "</td>";
  message += '<td class="actions">' + actions + "</td>";

  var message_window = $(this.bet_window_selector);
  if (message_window.children().length === 1) {
    $('tr#no-results', message_window).remove();
  }

  message_window.prepend('<tr '+ attributes +' >' + message + '</tr>');
};

PointGaming.BetsController.prototype.handleBetCreated = function(data) {
  this.appendBet(data.bet, data.bet_tooltip, data.bet_path);
};

PointGaming.BetsController.prototype.handleBetUpdated = function(data) {
  var bet_container = $(this.bet_selector + '#'+data.bet._id, this.bet_window_selector);
  $(this.bet_actions_column_selector, bet_container).html(this.getFinalizedStatus(data.bet));
};

PointGaming.BetsController.prototype.getFinalizedStatus = function(bet) {
  if (bet.outcome === 'bettor_won' || bet.outcome === 'bookie_won') {
    if (PointGaming.user._id === bet.bookie._id) {
      return (bet.outcome === 'bettor_won') ? 'You lost' : 'You win';
    } else if (PointGaming.user._id === bet.bettor._id) {
      return (bet.outcome === 'bettor_won') ? 'You win' : 'You lost';
    }
  } else if (bet.outcome !== 'undetermined') {
    return bet.outcome;
  }
  return '';
};

PointGaming.BetsController.prototype.handleNewBettor = function(data) {
  var bet_container = $(this.bet_selector + '#'+data.bet._id, this.bet_window_selector);
  if (PointGaming.user._id === data.bet.bookie._id) {
    // current_user was the bookie, add notification
    $(this.bet_actions_column_selector, bet_container).html('Accepted: ' + data.bet.bettor.username);
  } else if (PointGaming.user._id === data.bet.bettor._id) {
    // current_user was the bettor, add notification
    $(this.bet_actions_column_selector, bet_container).html('Accepted');
  } else {
    bet_container.remove();
  }
};

PointGaming.BetsController.prototype.handleBetDestroyed = function(data) {
  var bets_container = $(this.bet_window_selector),
      bet_container = $(this.bet_selector + '#'+data.bet._id, this.bets_container);

  bet_container.remove();

  if (bets_container.children().length === 0) {
    bets_container.prepend('<tr id="no-results"><td colspan="5">No results were found.</td></tr>');
  }
};

PointGaming.BetsController.prototype.registerHandlers = function() {
  var self = this;

  this.socket.on("Bet.new", this.handleBetCreated.bind(this));
  this.socket.on("Bet.update", this.handleBetUpdated.bind(this));
  this.socket.on("Bet.destroy", this.handleBetDestroyed.bind(this));

  this.socket.on("Bet.Bettor.new", this.handleNewBettor.bind(this));

  $('body').popover({
    selector: this.bet_selector,
    placement: 'top',
    trigger: 'hover',
    html: true
  });
};
