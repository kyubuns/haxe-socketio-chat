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
