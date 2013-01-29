var PointGaming = PointGaming || {};

$(function () {
  var socket = io.connect(PointGaming.socketio_uri);
  socket.on("connect", function() {
    if (PointGaming.authToken) {
      // register listener for auth callback
      socket.on("auth_resp", function(data){
        console.log("Auth Callback!!");
        console.log(data);
      });

      // send auth request
      socket.emit("auth", {auth_token: PointGaming.authToken});
    }
  });
  socket.on("message", function(data){
    var message;
    if (data && data.action) {
      message =  "<p>";
      switch(data.action){
        case 'message':
          message += "<strong>[Whisper] " + data.username + ":</strong> " + data.text;
          break;
        case 'logged_in':
          message += "<strong>" + data.username + " has logged in</strong>";
          break;
        case 'logged_out':
          message += "<strong>" + data.username + " has logged out</strong>";
          break;
      }
      message += "</p>";

      $("#chatbox").append(message);
    }
  });
});
