var PointGaming = PointGaming || {};

PointGaming.StreamsController = function(options){
  this.socket = PointGaming.socket;
  this.exchange_name = options.chat_room;

  this.details_container = $('div#stream-details');
  this.thumbnail = $('img#stream-thumbnail');

  this.registerHandlers();
};

PointGaming.StreamsController.prototype.registerHandlers = function() {
  this.socket.on("Stream.update", this.handleStreamUpdated.bind(this));
  this.socket.on("Stream.destroy", this.handleStreamDestroyed.bind(this));
};

PointGaming.StreamsController.prototype.handleStreamUpdated = function(data) {
  this.details_container.html(data.stream.details);
  this.thumbnail.attr('src', data.thumbnail);

  if (data.stream.betting === false) {
    $('a#new-match').attr('disabled', 'disabled');
  } else {
    $('a#new-match').removeAttr('disabled');
  }
};

PointGaming.StreamsController.prototype.handleStreamDestroyed = function(data) {
  // TODO: put this into a modal
  alert('This stream has been deleted.');
};
