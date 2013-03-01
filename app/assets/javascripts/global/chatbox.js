var PointGaming = PointGaming || {};

PointGaming.chatbox = function(options, socket){
  this.message_window_selector = options.message_window_selector;
  this.exchange_name = options.chat_room || 'general';

  this.socket = socket;

  this.registerHandlers();
};

PointGaming.chatbox.prototype.appendMessage = function(message) {
  var message_window = $(this.message_window_selector);
  message_window.append(message);
  message_window.scrollTop(message_window.prop('scrollHeight'));
};

PointGaming.chatbox.prototype.joinChat = function() {
  this.socket.emit('Chatroom.join', {_id: this.exchange_name});
};

PointGaming.chatbox.prototype.sendMessage = function(message) {
  this.socket.emit('Chatroom.Message.send', {
    _id: this.exchange_name, 
    message: message
  });
};

PointGaming.chatbox.prototype.handleJoinChat = function(data) {
  var message;
  if (data.success === true) message = "Connected to chat.";
  else message = "Failed to connect to chat.";

  this.appendMessage("<p><strong>" + message + "</strong></p>");
};

PointGaming.chatbox.prototype.handleAuthResponse = function(data) {
  if (data.success === true) {
    this.joinChat();
  }
};

PointGaming.chatbox.prototype.handleMessage = function(data) {
  var self = this;
  var parseMessage = function() {
    if (data.fromUser && data.message) {
      return "<p><strong>" + data.fromUser.username + " whispers:</strong> " + data.message + "</p>";
    }
    return "";
  };

  var message = parseMessage();
  if (message) self.appendMessage(message);
};

PointGaming.chatbox.prototype.handleChatMessage = function(data) {
  var self = this;
  var parseMessage = function() {
    if (data._id === self.exchange_name && data.fromUser && data.message) {
      return "<p><strong>" + data.fromUser.username + ":</strong> " + data.message + "</p>";
    }
    return "";
  };

  var message = parseMessage();
  if (message) self.appendMessage(message);
};

PointGaming.chatbox.prototype.registerHandlers = function() {
  var self = this;

  this.socket.on("auth_resp", function(data){ self.handleAuthResponse(data); });

  this.socket.on("join_chat", function(data){ self.handleJoinChat(data); });

  this.socket.on("Message.new", function(data){ self.handleMessage(data); });

  this.socket.on("Chatroom.Message.new", function(data){ self.handleChatMessage(data); });
};
