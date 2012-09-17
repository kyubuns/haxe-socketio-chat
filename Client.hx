import js.JQuery;
import js.Lib;
import Common;

class Client {
  static function main() {
    new JQuery(Lib.document).ready(function(e) {
      var socket:Socket = IO.connect('http://localhost:9876/');

      socket.on('connect', function() {
        new JQuery("#chat").append("<p>onopen</p>");

        socket.on('disconnect', function() {
          new JQuery("#chat").append("<p>onclose</p>");
        });

        socket.on('chat', function(data:BroadcastChatMessage) {
          new JQuery("#chat").append("<p>" + data.aname + ":" + data.amsg + "</p>");
        });

        socket.on('ping', function(data) {
          new JQuery("#chat").append("<p>tick" + data.hello + "</p>");
        });

        new JQuery("#send").click(function(){
          trace("button");
          var tmp:ChatMessage = {name:new JQuery("#name").val(), msg:new JQuery("#message").val()};
          socket.emit('chat', tmp);
        });
      });
    });
  }
}
