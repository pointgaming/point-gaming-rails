var PointGaming = PointGaming || {};

PointGaming.MatchController = function(match, new_bet_path){
  this.match = match || {};

  this.new_bet_path = new_bet_path;

  this.match_details_container = $('h4#stream-match-details');

  this.stream_bet_container = $('div#stream-bet-container');
  this.propose_bet_link = $('a#propose-bet');

  this.bet_window = $('div#bet-container');
  this.bet_selector = 'div.bet';

  this.registerHandlers();
};

PointGaming.MatchController.prototype.registerHandlers = function() {
  PointGaming.socket.on("Match.new", this.handleNewMatch.bind(this));
  PointGaming.socket.on("Match.update", this.handleMatchUpdated.bind(this));
};

PointGaming.MatchController.prototype.handleNewMatch = function(data) {
  this.match = data.match;

  this.match_details_container.html(data.match_details);

  $(this.bet_selector, this.bet_window).not('[data-match-id="' + data.match._id + '"]').remove();

  if (data.match.betting) {
    this.propose_bet_link.attr('href', this.new_bet_path.replace(/:match_id/, data.match._id));
    this.stream_bet_container.show();
    this.betting_changed(false, true);
  }
};

PointGaming.MatchController.prototype.betting_changed = function(old_value, new_value) {
  this.appendMessage('Betting is now ' + (new_value ? 'Enabled' : 'Disabled'));

  if (new_value) {
    this.propose_bet_link.show();
  } else {
    this.propose_bet_link.hide();
  }
};

PointGaming.MatchController.prototype.handleMatchUpdated = function(data) {
  var changed_trigger,
      key,
      oldValue;

  this.match_details_container.html(data.match_details);

  for (key in data.match) {
    if (data.match.hasOwnProperty(key)) {
      if (this.match[key] !== data.match[key]) {
        // stash old value
        oldValue = this.match[key];

        // update value to reflect changes
        this.match[key] = data.match[key];

        // TODO: switch this to an event emitter
        // called changed method, if exists
        changed_trigger = key + "_changed";
        if (typeof(this[changed_trigger]) === "function") {
          this[changed_trigger](oldValue, data.match[key]);
        }
      }
    }
  }
};

PointGaming.MatchController.prototype.appendMessage = function(message, options) {
  if (!message) return;

  options = options || {};
  var id = options.id ? 'id="'+ options.id +'"' : '',
      data_content = options.data_content ? ' data-content="'+ options.data_content +'"' : "",
      title = options.title ? ' title="'+ options.title +'"' : "";

  this.bet_window.prepend('<div '+id + title + data_content +' class="well well-small bet">' + message + '</div>');
};

