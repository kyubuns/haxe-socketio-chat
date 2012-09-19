import js.JQuery;
import js.Lib;
import Common;

//==============ライブラリでやる==================
//ToDo: handshake
class Connection {
  private var m_socket:Socket;
  private var m_handshaked:Bool;
  private var m_commandNo:Int;

  public function new():Void {}
  public function connect(host:String):Void {
    m_socket = IO.connect(host, { reconnect:false });
    m_socket.on('connect', function() {
      m_socket.on('disconnect', onclose);
      m_socket.on('message', function(data:Dynamic) {
        if(data.length != 3) return;
        try {
          var commandNo  = cast(data[0], Int);
          var functionNo = cast(data[1], Int);
          var args:Dynamic = data[2];

          //ToDo: リファクタリング
          if(functionNo == 123) {
            //chatNotify
            if(args.length != 2) return;
            var name = sanitize(cast(args[0], String));
            var msg  = sanitize(cast(args[1], String));
            chatNotify(name, msg);
          }
        } catch(errorMsg:String) {
          //クライアント側は変なデータきてもそのデータ無視するだけで。
          trace("wrong data received");
        }
      });
      onopen();
      m_handshaked = true;//ToDo
      m_commandNo = 0;
    });
  }

  static private function sanitize(str:String):String {
    str = StringTools.replace(str, "<", '&lt;');
    str = StringTools.replace(str, ">", '&gt;');
    str = StringTools.replace(str, '"', '&quot;');
    str = StringTools.replace(str, "'", '&$39;');
    return str;
  }

  //send
  public function chat(name:String, msg:String):Bool {
    if(!m_handshaked) return false;
    m_socket.emit('message', [m_commandNo, 123, [sanitize(name), sanitize(msg)]]);
    return true;
  }

  //receive
  public function onopen():Void {}
  public function onclose():Void {}
  public function chatNotify(name:String, msg:String):Void {}
}
//================================================

class Client extends Connection {
  override public function onopen():Void {
    ChatClient.addtext("onopen");
  }

  override public function onclose():Void {
    ChatClient.addtext("onclose");
  }

  override public function chatNotify(name:String, msg:String):Void {
    ChatClient.addtext(name + ":" + msg);
  }
}

class ChatClient {
  static public function addtext(text:String):Void {
    new JQuery("div#chat").prepend("<div>" + text + "</div>");
  }

  static function main():Void {
    new JQuery(Lib.document).ready(function(e) {
      var con = new Client();
      con.connect('http://localhost:9876/');

      new JQuery("#send").click(function(){
        con.chat(new JQuery("#name").val(), new JQuery("#message").val());
        new JQuery("#message").val("");
      });
    });
  }
}
