import Common;
import js.Node;
import Std;

//================================================
class Server {
  private var m_io:SocketIO;

  public function new():Void {}
  public function listen(port:Int, option:Dynamic, connection:Class<Connection>) {
    m_io = Node.require('socket.io').listen(port, option);
    m_io.sockets.on('connection', function(socket:Socket) {
      trace('connection');
      var con:Connection = Type.createInstance(connection , [socket]);
      con.onopen();
    });
  }
}

class Connection {
  private var m_socket:Socket;
  private var m_handshaked:Bool;
  private var m_commandNo:Int;
  private var m_functions:IntHash<Dynamic->Void>;

  public function new(socket:Socket):Void {
    m_socket = socket;
    m_socket.on('message', function (data:Dynamic) {
      if(data.length != 3) return;
      try {
        var commandNo  = cast(data[0], Int);
        if(m_handshaked == false) return;
        if(commandNo < 0 || commandNo <= m_commandNo) throw "wrong command NO";
        m_commandNo = (commandNo < 1000) ? commandNo : 0;

        var functionNo = cast(data[1], Int);
        var args:Dynamic = data[2];
        var func = m_functions.get(functionNo);
        if(func == null) throw "non-existent function";
        func(args);
      }
      catch(errorMsg:String) {
        trace("wrong data received ["+errorMsg+"]");
        socket.disconnect();
      }
    });

    m_socket.on('handshake', handshakeRequest);
    socket.on('disconnect', onclose);
    m_handshaked = false;
    m_commandNo = -1024;
  }

  private function handshakeRequest(data:Dynamic) {
    try {
      var protocolhash = cast(data, String);
      if(protocolhash != 'hogefugapiyorofi') throw "wrong version";
      trace("handshake ok");
      m_handshaked = true;
      m_commandNo = 0;
    }
    catch(errorMsg:String) {
      trace("handshake error");
    }

    m_socket.emit('handshake', [m_handshaked, m_commandNo]);
    if(m_handshaked == false) {
      m_socket.disconnect();
      return;
    }

    m_functions = new IntHash<Dynamic->Void>();
    m_functions.set(123, call_chat);
  }

  private function call_chat(args:Dynamic) {
    if(args.length != 2) return;
    var name = sanitize(cast(args[0], String));
    var msg  = sanitize(cast(args[1], String));
    chat(name, msg);
  }

  static private function sanitize(str:String):String {
    str = StringTools.replace(str, "<", '&lt;');
    str = StringTools.replace(str, ">", '&gt;');
    str = StringTools.replace(str, '"', '&quot;');
    str = StringTools.replace(str, "'", '&$39;');
    return str;
  }

  //send
  public function chatNotify(name:String, msg:String):Bool {
    if(!m_handshaked) return false;
    m_socket.emit('message', [++m_commandNo, 123, [sanitize(name), sanitize(msg)]]);
    return true;
  }

  //receive
  public function onopen():Void {}
  public function onclose():Void {}
  public function chat(name:String, msg:String):Void {}
}
//================================================
class Client extends Connection{
  private static var nextId:Int = 0;
  public static var clients = new IntHash<Client>();

  private var myid:Int;
  override public function onopen():Void {
    myid = nextId++;
    clients.set(myid, this);

    trace("onopen - ID:" + Std.string(myid));
    for(con in Client.clients) con.chatNotify("info", "ID:"+Std.string(myid)+"さんが来たよ〜");
  }

  override public function onclose():Void {
    clients.remove(myid);
    trace("onclose - ID:" + Std.string(myid));
    for(con in Client.clients) con.chatNotify("info", "ID:"+Std.string(myid)+"さんが帰ったよ〜");
  }

  override public function chat(name:String, msg:String):Void {
    if(name == "" || msg == "") return;
    name = name + "(ID:" + Std.string(myid) + ")";
    for(con in clients) con.chatNotify(name, msg);
  }

}

class ChatServer {
  static var next_id = 0;
  public static function main() {
    var server:Server = new Server();
    server.listen(9876, {'log level': 3, 'heartbeat interval': 120, 'close timeout': 180}, Client);

    new SetInterval(ChatServer.tick, 60000);
    tick();
  }

  public static function tick() {
    //ここから何も送られてこなくてもイベント発生させられる
    var fugaaaa:String = Std.string(Lambda.count(Client.clients));
    trace("tick" + fugaaaa);
    for(con in Client.clients) con.chatNotify("info", "現在"+fugaaaa+"人が接続中。");
  }
}
