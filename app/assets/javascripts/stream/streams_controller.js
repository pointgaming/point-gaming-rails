var PointGaming = PointGaming || {};

PointGaming.StreamsController = function(options){
  this.socket = PointGaming.socket;
  this.exchange_name = options.chat_room;

  this.name_container = 'h1#stream-name';
  this.details_container = 'div#stream-details';
  this.bet_details_container = 'h4#stream-bet-details';
  this.bet_container = 'div#stream-bet-container';

  this.registerHandlers();
};

PointGaming.StreamsController.prototype.joinChat = function() {
//  TODO: add server-side support for 2 join_chat requests over the same connection
//  this will be sent by the chatbox app for now

//  this.socket.emit('join_chat', {chat: this.exchange_name});
};

PointGaming.StreamsController.prototype.handleAuthResponse = function(data) {
  if (data.success === true) {
    this.joinChat();
  }
};

PointGaming.StreamsController.prototype.handleJoinChat = function(data) {

};

PointGaming.StreamsController.prototype.handleMessage = function(data) {
  if (data.action) {
    switch (data.action) {
      case "stream_updated":
        this.handleStreamUpdated(data);
        break;
      case "stream_destroyed":
        this.handleStreamDestroyed(data);
        break;
    }
  }
};

PointGaming.StreamsController.prototype.handleStreamUpdated = function(data) {
  $(this.name_container).html(data.stream.name);
  $(this.details_container).html(data.stream.details || "");
  $(this.bet_details_container).html(data.bet_details);
  if (data.stream.betting) {
    $(this.bet_container).show();
  } else {
    $(this.bet_container).hide();
  }
};

PointGaming.StreamsController.prototype.handleStreamDestroyed = function(data) {
  alert('This stream has been deleted.');
};

PointGaming.StreamsController.prototype.registerHandlers = function() {
  var self = this;

  this.socket.on("auth_resp", function(data){ self.handleAuthResponse(data); });

  this.socket.on("join_chat", function(data){ self.handleJoinChat(data); });

  this.socket.on("message", function(data){ self.handleMessage(data); });
};
