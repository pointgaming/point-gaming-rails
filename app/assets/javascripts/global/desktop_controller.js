var PointGaming = PointGaming || {};

PointGaming.DesktopController = function(){
  this.PageDecorator = {
    clientInstalled: function() {
      this.removeClasses();
      $('.requires-desktop-client').addClass('client-installed');
    },
    clientNotInstalled: function() {
      this.removeClasses();
      $('.requires-desktop-client').addClass('client-not-installed');
    },
    clientOutOfDate: function() {
      this.removeClasses();
      $('.requires-desktop-client').addClass('client-out-of-date');
    },
    removeClasses: function() {
      $('.requires-desktop-client').removeClass('client-installed client-not-installed client-out-of-date');
    }
  };

  this.checkForClient();
  this.registerHandlers();
};

PointGaming.DesktopController.prototype.checkForClient = function(callback) {
  var self = this;

  this.client_checker = new PointGaming.ClientChecker({}, function(err, client_checker){
    if (client_checker.clientInstalled) {
      if (client_checker.clientOutOfDate) {
        self.PageDecorator.clientOutOfDate();
      } else {
        self.PageDecorator.clientInstalled();
      }
    } else {
      self.PageDecorator.clientNotInstalled();
    }

    if (typeof(callback) === 'function') {
      callback(err, client_checker);
    }
  });
};

PointGaming.DesktopController.prototype.registerHandlers = function() {
  $(document).on('click', 'a.requires-desktop-client.client-installed[data-action="joinLobby"]', this.joinLobby.bind(this));
  $(document).on('click', 'a.requires-desktop-client.client-not-installed[data-action="joinLobby"]', this.displayClientRequiredModal.bind(this));

  $(document).on('click', '#desktop-client-required-modal a[data-action="tryAgain"]', this.recheckForClient.bind(this));
};

PointGaming.DesktopController.prototype.recheckForClient = function(e) {
  var action = $('#desktop-client-required-modal #desktop-client-action-container :first-child');

  this.client_checker.setClientInstalled(false);
  this.client_checker.setClientVersion(null);

  $('#desktop-client-required-modal').modal('hide');

  this.checkForClient(function(err, client_checker) {
    action.click();
  });
};

PointGaming.DesktopController.prototype.joinLobby = function(e) {
  var self = this,
      game_id = $(e.target).attr('href').split(':')[2];
  e.preventDefault();

  $('body').modalmanager('loading');

  PointGaming.DesktopConnector.joinLobby(game_id)
    .done(function(data){
      $('body').modalmanager('loading');
    })
    .fail(function(jqXHR, textStatus){
      $('body').modalmanager('loading');

      console.log('AJAX Request Failed: ' + textStatus);
      self.displayClientRequiredModal(e);
    });

  return false;
};

PointGaming.DesktopController.prototype.displayClientRequiredModal = function(e) {
  e.preventDefault();

  var modal = $('#desktop-client-required-modal'),
      actionContainer = $('#desktop-client-action-container', modal);

  actionContainer.html('');
  actionContainer.append($(e.target).clone());

  modal.modal({});
  return false;
};
