var PointGaming = PointGaming || {};

PointGaming.ClientChecker = function(options){
  options = options || {};

  this.initialized = false;

  this.latestVersion = options.latestVersion || '0.0.1';

  this.clientInstalled = ($.cookie('desktop_client_installed') === 'yes');
  this.clientVersion = $.cookie('desktop_client_version');
};

PointGaming.ClientChecker.prototype.checkClientInstalled = function(callback, recheck) {
  var self = this;
  recheck = recheck || false;

  if (!this.initialized || recheck) {
    PointGaming.DesktopConnector.getInfo()
      .done(function(data){
        self.setClientInstalled(true);
        self.setClientVersion(data.version);
        self.initialized = true;

        if (typeof(callback) === "function") {
          callback(null, self);
        }
      })
      .fail(function(jqXHR, textStatus){
        self.setClientInstalled(false);
        self.setClientVersion(null);
        self.initialized = true;

        if (typeof(callback) === "function") {
          callback(null, self);
        }
      });
  } else {
    callback(null, self);
  }
};

PointGaming.ClientChecker.prototype.setClientInstalled = function(client_installed) {
  this.clientInstalled = client_installed;
  $.cookie('desktop_client_installed', client_installed ? 'yes' : 'no');
};

PointGaming.ClientChecker.prototype.setClientVersion = function(version) {
  this.clientVersion = version;
  $.cookie('desktop_client_version', version);
};
