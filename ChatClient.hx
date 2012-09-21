import js.JQuery;
import js.Lib;
import Common;

//==============ライブラリでやる==================
class Connection {
  private var m_socket:Socket;
  private var m_handshaked:Bool;
  private var m_commandNo:Int;

  public function new():Void {}
  public function connect(host:String):Void {
    m_socket = IO.connect(host, { reconnect:false, 'connect timeout': 1000 });
    m_socket.on('error', function(){ error("socket error"); });
    m_socket.on('connect_failed', connectFailed);
    m_socket.on('connect', function() {
      m_socket.on('disconnect', onclose);
      m_socket.on('message', function(data:Dynamic) {
        if(m_handshaked == false) return;
        if(data.length != 3) return;
        try {
          m_commandNo  = cast(data[0], Int);
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
        }
        catch(errorMsg:String) {
          //クライアント側は変なデータきてもそのデータ無視するだけで。
          trace("wrong data received");
        }
      });
      m_socket.on('handshake', function(data:Dynamic) {
        if(data.length != 2) return;
        try {
          m_handshaked = cast(data[0], Bool);
          m_commandNo  = cast(data[1], Int);
          if(m_handshaked == false) {
            error("handshake error");
            return;
          }
          onopen();
        }
        catch(errorMsg:String) {
          error("handshake error");
        }
      });
      m_socket.emit('handshake', 'hogefugapiyorofi');
      m_handshaked = false;
      m_commandNo = -1024;
    });
  }

  static private function sanitize(str:String):String {
    str = StringTools.replace(str, "<", '&lt;');
    str = StringTools.replace(str, ">", '&gt;');
    str = StringTools.replace(str, '"', '&quot;');
    str = StringTools.replace(str, "'", '&apos;');
    return str;
  }

  //send
  public function chat(name:String, msg:String):Bool {
    if(!m_handshaked) return false;
    m_socket.emit('message', [++m_commandNo, 123, [sanitize(name), sanitize(msg)]]);
    return true;
  }

  //receive
  public function onopen():Void {}
  public function error(msg:String):Void {}
  public function onclose():Void {}
  public function connectFailed():Void {}
  public function chatNotify(name:String, msg:String):Void {}
}
//================================================

class Client extends Connection {
  override public function onopen():Void {
    ChatClient.addtext("<b>サーバーに接続しました。</b>");
  }

  override public function connectFailed():Void {
    ChatClient.addtext("<b>サーバーに接続できませんでした。</b>");
  }

  override public function onclose():Void {
    ChatClient.addtext("<b>サーバーとの接続が切れました。</b>");
  }

  override public function error(msg:String):Void {
    ChatClient.addtext("<b>エラーが発生しました。["+ msg +"]</b>");
  }

  override public function chatNotify(name:String, msg:String):Void {
    ChatClient.addtext(name + " - " + msg);
  }
}

class ChatClient {
  static public function addtext(text:String):Void {
    new JQuery("div#chat").prepend("<div>" + text + "</div>");
  }

  static function main():Void {
    new JQuery(Lib.document).ready(function(e) {
      var con = new Client();
      ChatClient.addtext("<b>サーバーに接続中...</b>");
      con.connect('http://localhost:9876/');

      new JQuery("#send").click(function(){
        //ToDo: JQueryでテキストボックスから文字列受け取るのメソッド化する
        //(nullチェック中でやりたい)
        var name:String = new JQuery("#name").val();
        var msg:String = new JQuery("#message").val();
        if(name == "" || msg == "") return;
        con.chat(name, msg);
        new JQuery("#message").val("");
      });
    });
  }
}
