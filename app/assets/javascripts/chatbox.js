var PointGaming = PointGaming || {};

PointGaming.chatbox = function(options, socket){
  this.message_window_selector = options.message_window_selector;
  this.exchange_name = options.chat_room || 'general';

  this.socket = socket;

  this.registerHandlers();
  this.joinChat();
};

PointGaming.chatbox.prototype.appendMessage = function(message) {
  var message_window = $(this.message_window_selector);
  message_window.append(message);
  message_window.scrollTop(message_window.prop('scrollHeight'));
};

PointGaming.chatbox.prototype.joinChat = function() {
  this.socket.emit('join_chat', {chat: this.exchange_name});
};

PointGaming.chatbox.prototype.sendMessage = function(message) {
  this.socket.emit('message', {
    chat: this.exchange_name, 
    username: PointGaming.username, 
    message: message
  });
};

PointGaming.chatbox.prototype.handleJoinChat = function(data) {
  var message;
  if (data.success === true) message = "Connected to chat.";
  else message = "Failed to connect to chat.";

  this.appendMessage("<p><strong>" + message + "</strong></p>");
};

PointGaming.chatbox.prototype.handleMessage = function(data) {
  var self = this;
  var parseMessage = function() {
    if (data.exchange === 'c.'+self.exchange_name) {
      return "<p><strong>" + data.username + ":</strong> " + data.message + "</p>";
    } else if (data.exchange === 'u.'+PointGaming.username) {
      return "<p><strong>" + data.username + " whispers:</strong> " + data.message + "</p>";
    }
    return "";
  };

  if (data.username && data.message && data.exchange) {
    var message = parseMessage();
    if (message) self.appendMessage(message);
  }
};

PointGaming.chatbox.prototype.registerHandlers = function() {
  var self = this;

  this.socket.on("join_chat", function(data){ self.handleJoinChat(data); });

  this.socket.on("message", function(data){ self.handleMessage(data); });
};
