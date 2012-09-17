import js.JQuery;
import js.Lib;
import Common;

class Client {
  static function addtext(text:String):Void {
    new JQuery("div#chat").prepend("<div>" + Sanitize.run(text) + "</div>");
  }

  static function main():Void {
    new JQuery(Lib.document).ready(function(e) {
      var socket:Socket = IO.connect('http://localhost:9876/');

      socket.on('connect', function() {
        addtext("onopen");

        socket.on('disconnect', function() {
          addtext("onclose");
        });

        socket.on('chat', function(data:BroadcastChatMessage) {
          addtext(data.aname + ":" + data.amsg);
        });

        socket.on('ping', function(data) {
          addtext("tick" + data.hello);
        });

        new JQuery("#send").click(function(){
          trace("button");
          var tmp:ChatMessage = {name:new JQuery("#name").val(), msg:new JQuery("#message").val()};
          new JQuery("#message").text("");
          socket.emit('chat', tmp);
        });
      });
    });
  }
}
