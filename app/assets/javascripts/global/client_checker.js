var PointGaming = PointGaming || {};

PointGaming.ClientChecker = function(){
  this.initialized = false;

  this.latestVersion = PointGaming.desktop_client_latest_version || '0.0.0';

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
  $.cookie('desktop_client_installed', (client_installed ? 'yes' : 'no'), { path: '/' });
};

PointGaming.ClientChecker.prototype.setClientVersion = function(version) {
  this.clientVersion = version;
  $.cookie('desktop_client_version', version, { path: '/' });
};

PointGaming.ClientChecker.prototype.isOutOfDate = function() {
  return !compareVersions(this.clientVersion, this.latestVersion);
};

function compareVersions(installed_version, required_version) {
  var a = installed_version.split('.'),
      b = required_version.split('.');

  for (var i = 0; i < a.length; ++i) {
    a[i] = Number(a[i]);
  }
  for (var i = 0; i < b.length; ++i) {
    b[i] = Number(b[i]);
  }
  if (a.length == 2) {
    a[2] = 0;
  }

  if (a[0] > b[0]) return true;
  if (a[0] < b[0]) return false;

  if (a[1] > b[1]) return true;
  if (a[1] < b[1]) return false;

  if (a[2] > b[2]) return true;
  if (a[2] < b[2]) return false;

  return true;
};
