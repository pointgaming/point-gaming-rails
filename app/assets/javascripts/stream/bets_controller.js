var PointGaming = PointGaming || {};

PointGaming.BetsController = function(options){
  this.socket = PointGaming.socket;
  this.exchange_name = options.chat_room;

  this.bet_window_selector = options.bet_window_selector || 'div#bet-container';
  this.bet_selector = options.bet_selector || 'div.bet';


  this.registerHandlers();
};

PointGaming.BetsController.prototype.appendMessage = function(message, options) {
  var attributes = '',
      key;
  if (!message) return;

  for (key in options) {
    if (options.hasOwnProperty(key)) {
      attributes += key + '="' + options[key] + '" ';
    }
  }

  var message_window = $(this.bet_window_selector);
  message_window.prepend('<div '+ attributes +' class="well well-small bet">' + message + '</div>');
};

PointGaming.BetsController.prototype.joinChat = function() {
//  TODO: add server-side support for 2 join_chat requests over the same connection
//  this will be sent by the chatbox app for now

//  this.socket.emit('join_chat', {chat: this.exchange_name});
};

PointGaming.BetsController.prototype.handleAuthResponse = function(data) {
  if (data.success === true) {
    this.joinChat();
  }
};

PointGaming.BetsController.prototype.handleJoinChat = function(data) {
  var message;
  if (data.success === true) message = "Connected to bet server.";
  else message = "Failed to connect to bet server.";

  this.appendMessage("<strong>" + message + "</strong>");
};

PointGaming.BetsController.prototype.handleBetCreated = function(data) {
  var message = data.bet.bookie.username + ": " + data.bet.winner_name + ">" + data.bet.loser_name + " " + data.bet.amount + " Points " + data.bet.odds;
  // if current_user is bookie
  if (PointGaming.user._id === data.bet.bookie._id) {
    message += '<div class="pull-right"><a href="'+ data.bet_path +'" data-confirm="Are you sure?" data-method="delete" data-remote="true" data-type="json" rel="nofollow">Cancel</a></div>';
  } else {
    message += '<div class="pull-right"><a href="'+ data.bet_path +'" data-confirm="Are you sure?" data-method="put" data-remote="true" data-type="json" rel="nofollow">Accept</a></div>';
  }
  this.appendMessage(message, {id: data.bet._id, "data-content": data.bet_tooltip, "data-match-id": data.bet.match_id, title: 'Bet Details'});
};

PointGaming.BetsController.prototype.handleBetUpdated = function(data) {
  var bet_container = $(this.bet_selector + '#'+data.bet._id, this.bet_window_selector);
  if (data.bet.outcome === 'bettor_won') {
    if (PointGaming.user._id === data.bet.bookie._id) {
      $('div.pull-right', bet_container).html('You lost');
    } else if (PointGaming.user._id === data.bet.bettor._id) {
      $('div.pull-right', bet_container).html('You win');
    }
  } else if (data.bet.outcome === 'bookie_won') {
    if (PointGaming.user._id === data.bet.bookie._id) {
      $('div.pull-right', bet_container).html('You win');
    } else if (PointGaming.user._id === data.bet.bettor._id) {
      $('div.pull-right', bet_container).html('You lost');
    }
  } else if (data.bet.outcome !== 'undetermined') {
    $('div.pull-right', bet_container).html(data.bet.outcome);
  }
};

PointGaming.BetsController.prototype.handleNewBettor = function(data) {
  // find bet row
  var bet_container = $(this.bet_selector + '#'+data.bet._id, this.bet_window_selector);
  if (PointGaming.user._id === data.bet.bookie._id) {
    // current_user was the bookie, add notification
    $('div.pull-right', bet_container).html('Accepted: ' + data.bet.bettor.username);
  } else if (PointGaming.user._id === data.bet.bettor._id) {
    // current_user was the bettor, add notification
    $('div.pull-right', bet_container).html('Accepted');
  } else {
    bet_container.remove();
  }
};

PointGaming.BetsController.prototype.handleBetDestroyed = function(data) {
  var bet_container = $(this.bet_selector + '#'+data.bet._id, this.bet_window_selector);
  bet_container.remove();
};

PointGaming.BetsController.prototype.registerHandlers = function() {
  var self = this;

  this.socket.on("auth_resp", function(data){ self.handleAuthResponse(data); });

  this.socket.on("join_chat", function(data){ self.handleJoinChat(data); });

  this.socket.on("Bet.new", this.handleBetCreated.bind(this));
  this.socket.on("Bet.update", this.handleBetUpdated.bind(this));
  this.socket.on("Bet.destroy", this.handleBetDestroyed.bind(this));

  this.socket.on("Bet.Bettor.new", this.handleNewBettor.bind(this));

  $('body').popover({
    selector: this.bet_selector,
    placement: 'bottom',
    trigger: 'hover',
    html: true
  });
};
