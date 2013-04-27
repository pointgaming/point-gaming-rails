var DesktopConnector = function(){
  this.endpoint = 'http://local.pointgaming.com:9779/'
};

var PointGaming = PointGaming || {};
PointGaming.DesktopConnector = new DesktopConnector();

DesktopConnector.prototype.getInfo = function() {
  return $.ajax(this.endpoint + 'info');
};

DesktopConnector.prototype.joinLobby = function(game_id) {
  return $.ajax(this.endpoint + 'lobby/' + game_id + '?username=' + PointGaming.username);
};
