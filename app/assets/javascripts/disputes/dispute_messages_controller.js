var PointGaming = PointGaming || {};

PointGaming.DisputeMessagesController = function(options){
  this.socket = PointGaming.socket;
  this.exchange_name = options.chat_room;

  this.messages_container = $('div#messages');
  this.message_count_container = $('span[data-hook="message_count"]');

  this.registerHandlers();
};

PointGaming.DisputeMessagesController.prototype.submitForm = function() {
  var form = $('form#new_message');
  form.parent().find(".alert-error").remove();

  $('body').modalmanager('loading');
};

PointGaming.DisputeMessagesController.prototype.clearForm = function(e) {
  var form = $('form#new_message');
  if (form.length) {
    form[0].reset();
    form.parent().find(".alert-error").remove();
  }
  $('body').modalmanager('loading');
};

PointGaming.DisputeMessagesController.prototype.handleAjaxError = function(event, response, status_text) {
  var form = $('form#new_message'),
      header = form.parent().find('h1'),
      container = form.find('div.modal-body'),
      errors;

  form.find(".alert-error").remove()
  $('body').modalmanager('loading');

  if (response.status === 500) {
    $('<div class="alert alert-error">Internal Server Error</div>').insertAfter(header);
  } else {
    errors = $.parseJSON(response.responseText).errors;
    $.each(errors, function(key, value){
      $('<div class="alert alert-error">'+ value + '</div>').insertAfter(header);
    });
  }
};

PointGaming.DisputeMessagesController.prototype.registerHandlers = function() {
  var self = this;
  this.socket.on("auth_resp", function(data){ self.handleAuthResponse(data); });

  this.socket.on("Dispute.Message.new", this.handleDisputeMessageCreated.bind(this));

  $(document).on('submit', 'form#new_message', this.submitForm);
  $(document).on('ajax:success', 'form#new_message', this.clearForm);
  $(document).on('ajax:error', 'form#new_message', this.handleAjaxError);
};

PointGaming.DisputeMessagesController.prototype.handleAuthResponse = function(data) {
  if (data.success === true) {
    this.joinChat();
  }
};

PointGaming.DisputeMessagesController.prototype.handleDisputeMessageCreated = function(data) {
  var message_count = $('div.message', this.messages_container).length,
      attachment_message = '',
      message;

  if (data.dispute_message.attachment_url) {
    attachment_message = '<p>Attachment: <a href="'+ data.dispute_message.attachment_url + '">' + data.dispute_message.attachment_name + '</a></p>';
  }

  message = $(['<div class="message row-fluid ' + (message_count % 2 === 0 ? 'even' : 'odd') + '">',
      '<div class="user">',
        '<div class="username"><a href="' + data.dispute_message.user.url + '">' + data.dispute_message.user.username + '</a></div>',
        '<div class="icon"><img src="' + data.dispute_message.user.avatar_url + '"></div>',
      '</div>',
      '<div class="contents">',
        '<a name="' + data.dispute_message.anchor + '" href="' + data.dispute_message.url + '"><time class="date">' + PointGaming.formatDateTime(data.dispute_message.created_at) + '</time></a>',
        '<p>' + data.dispute_message.text + '</p>',
        attachment_message,
      '</div>',
    '</div>'].join(''));

  this.messages_container.append(message);

  this.message_count_container.html(message_count + 1);
};

PointGaming.DisputeMessagesController.prototype.joinChat = function() {
  this.socket.emit('Chatroom.join', {_id: this.exchange_name});
};
