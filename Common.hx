package;

@:native("require")
extern class Require {
  function new(data:String) : Void;
  function listen(port:Int, option:Dynamic) : SocketIO; //Socket.IO
}

@:native("io")
extern class IO {
  static function connect(host:String):Socket;
}

extern class SocketIO {
  var sockets : Sockets;
}

extern class Sockets {
  function on(event:String, handler:Socket->Void) : Void;
}

extern class Socket {
  function emit(event:String, data:Dynamic) : Void;
  @:overload(function (event:String, handler:Void->Void):Void{})
  function on(event:String, handler:Dynamic->Void) : Void;
}

@:native("setInterval")
extern class SetInterval {
  function new(f:Void->Void, interval:Int) : Void;
}

typedef ChatMessage = {
  var name : String;
  var msg : String;
}

typedef BroadcastChatMessage = {
  var aname : String;
  var amsg : String;
}

class Sanitize{
  //こんなことやってると絶対に抜けが発生するので中で勝手にやってくれる方法考える
  // -Socket.on|Sockets.onをオーバーライドして勝手に変換してから送受信
  // -ChatMessage, BroadcastChatMessageのメッセージの型を
  //  送信側だけSafeString型にする
  //  （今はこのファイルをサーバーからもクライアントからも読んでいるのでできない。）
  static public function run(str:String):String {
    str = StringTools.replace(str, "<", '&lt;');
    str = StringTools.replace(str, ">", '&gt;');
    str = StringTools.replace(str, '"', '&quot;');
    str = StringTools.replace(str, "'", '&$39;');
    return str;
  }
}
