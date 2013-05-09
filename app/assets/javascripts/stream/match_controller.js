var PointGaming = PointGaming || {};

PointGaming.MatchController = function(match, new_bet_path){
  this.match = match || {};

  this.new_bet_path = new_bet_path;

  this.match_details_container = $('span#stream-match-details');

  this.stream_bet_container = $('div#stream-bet-container');
  this.propose_bet_link = $('a#propose-bet');

  this.bet_window = $('tbody#bet-container');
  this.bet_selector = 'tr.bet';

  this.registerHandlers();
};

PointGaming.MatchController.prototype.registerHandlers = function() {
  PointGaming.socket.on("Match.new", this.handleNewMatch.bind(this));
  PointGaming.socket.on("Match.update", this.handleMatchUpdated.bind(this));

  $('span#stream-name').popover({
    placement: 'bottom',
    trigger: 'hover',
    html: true,
    container: 'body',
    title: 'Stream Details'
  });
};

PointGaming.MatchController.prototype.handleNewMatch = function(data) {
  this.match = data.match;

  this.match_details_container.html(data.match_details ? ' - '+data.match_details : '');

  this.removeOldBets(data.match._id);

  this.propose_bet_link.attr('href', this.new_bet_path.replace(/:match_id/, data.match._id));
  this.stream_bet_container.show();
  this.propose_bet_link.show();
};

PointGaming.MatchController.prototype.removeOldBets = function(new_match_id) {
  $(this.bet_selector, this.bet_window).not('[data-match-id="' + new_match_id + '"]').remove();

  if (this.bet_window.children().length === 0) {
    this.bet_window.prepend('<tr id="no-results"><td colspan="5">No results were found.</td></tr>');
  }
};

PointGaming.MatchController.prototype.state_changed = function(old_value, new_value) {
  if (new_value !== 'new') {
    this.propose_bet_link.hide();
  }
}

PointGaming.MatchController.prototype.handleMatchUpdated = function(data) {
  var changed_trigger,
      key,
      oldValue;

  this.match_details_container.html(data.match_details ? ' - '+data.match_details : '');

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
