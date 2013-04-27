var PointGaming = PointGaming || {};

PointGaming.ClientChecker = function(options, callback){
  options = options || {};
  this.latestVersion = options.latestVersion || '0.0.1';

  this.clientInstalled = ($.cookie('desktop_client_installed') === 'yes');
  this.clientVersion = $.cookie('desktop_client_version');

  this.init(callback);
};

PointGaming.ClientChecker.prototype.init = function(callback) {
  if (!this.clientInstalled) {
    this.checkClientInstalled(callback);
  } else {
    if (typeof(callback) === "function") {
      callback(null, this);
    }
  }
};

PointGaming.ClientChecker.prototype.checkClientInstalled = function(callback) {
  var self = this;

  PointGaming.DesktopConnector.getInfo()
    .done(function(data){
      self.setClientInstalled(true);
      self.setClientVersion(data.version);

      if (typeof(callback) === "function") {
        callback(null, self);
      }
    })
    .fail(function(jqXHR, textStatus){
      console.log('AJAX Request Failed: ' + textStatus);

      self.setClientInstalled(false);
      self.setClientVersion(null);

      if (typeof(callback) === "function") {
        callback(null, self);
      }
    });
};

PointGaming.ClientChecker.prototype.setClientInstalled = function(client_installed) {
  this.clientInstalled = client_installed;
  $.cookie('desktop_client_installed', client_installed ? 'yes' : 'no');
};

PointGaming.ClientChecker.prototype.setClientVersion = function(version) {
  this.clientVersion = version;
  $.cookie('desktop_client_version', version);
};
