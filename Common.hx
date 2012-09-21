package;

@:native("io")
extern class IO {
  static function connect(host:String, ?option:Dynamic):Socket;
}

extern class SocketIO {
  var sockets : Sockets;
  function set(name:String, option:Dynamic):Void;
}

extern class Sockets {
  function on(event:String, handler:Socket->Void) : Void;
}

extern class Socket {
  function emit(event:String, data:Dynamic) : Void;
  @:overload(function (event:String, handler:Void->Void):Void{})
  function on(event:String, handler:Dynamic->Void) : Void;
  function disconnect() : Void;
}

@:native("setInterval")
extern class SetInterval {
  function new(f:Void->Void, interval:Int) : Void;
}

