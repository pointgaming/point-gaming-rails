var PointGaming = PointGaming || {};

PointGaming.DesktopController = function(){
  this.client_checker = new PointGaming.ClientChecker({});

  this.element_decorator = {
    clientInstalled: function(element) {
      this.removeClasses(element);
      element.addClass('client-installed');
    },
    clientNotInstalled: function(element) {
      this.removeClasses(element);
      element.addClass('client-not-installed');
    },
    clientOutOfDate: function(element) {
      this.removeClasses(element);
      element.addClass('client-out-of-date');
    },
    removeClasses: function(element) {
      element.removeClass('check-for-client client-installed client-not-installed client-out-of-date');
    }
  };

  if ($('a.requires-desktop-client').length > 0) {
    this.checkForClient();
  }

  this.registerHandlers();
};

PointGaming.DesktopController.prototype.decorateElement = function(element) {
  element = element || $('.requires-desktop-client');
  if (this.client_checker.clientInstalled) {
    if (this.client_checker.isOutOfDate()) {
      this.element_decorator.clientOutOfDate(element);
    } else {
      this.element_decorator.clientInstalled(element);
    }
  } else {
    this.element_decorator.clientNotInstalled(element);
  }
};

PointGaming.DesktopController.prototype.checkForClient = function(callback, recheck) {
  var self = this;

  this.client_checker.checkClientInstalled(function(err, client_checker){
    self.decorateElement();

    if (typeof(callback) === 'function') {
      callback(err, client_checker);
    }
  }, recheck);
};

PointGaming.DesktopController.prototype.registerHandlers = function() {
  var self = this;

  $(document).on('click', 'a.requires-desktop-client.client-installed[data-action="joinLobby"]', this.joinLobby.bind(this));
  $(document).on('click', 'a.requires-desktop-client.client-not-installed', this.displayClientRequiredModal.bind(this));
  $(document).on('click', 'a.requires-desktop-client.client-out-of-date', this.displayClientOutOfDateModal.bind(this));

  $(document).on('click', 'a.requires-desktop-client.check-for-client', function(e) {
    var action = $(e.target);

    self.checkForClient(function(err, client_checker) {
      self.decorateElement(action);
      action.click();
    });
  });

  $(document).on('click', 'a.desktop-client-required[data-action="tryAgain"]', function() {
    var action = $('#desktop-client-action-container :first-child');

    $(this).closest('.modal').modal('hide');

    self.checkForClient(function(err, client_checker) {
      action.click();
    }, true);
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

      self.displayClientRequiredModal(e);
    });

  return false;
};

PointGaming.DesktopController.prototype.displayClientRequiredModal = function(e) {
  e.preventDefault();
  this.displayModal($('#desktop-client-required-modal'), $(e.target).clone());
};

PointGaming.DesktopController.prototype.displayClientOutOfDateModal = function(e) {
  e.preventDefault();
  this.displayModal($('#desktop-client-out-of-date-modal'), $(e.target).clone());
};

PointGaming.DesktopController.prototype.displayModal = function(modal, link) {
  var actionContainer = $('#desktop-client-action-container');

  actionContainer.html('');
  actionContainer.append(link);

  modal.modal({});
  return false;
};
