import Common;

class Server {
  static var clients = new IntHash<Socket>();
  static var next_id = 0;
  public static function main() {
    var io = new Require('socket.io').listen(9876, {'log level': 3, 'heartbeat interval': 120});

    io.sockets.on('connection', function(socket:Socket) {
      var myid = next_id++;
      clients.set(myid, socket);

      socket.on('chat', function (data:ChatMessage) {
        trace(data);

        //socket.broadcast.emitと同じ事だが、socket1個1個管理できるのを確かめるために。
        var tmp:BroadcastChatMessage = { aname:Sanitize.run(data.name), amsg:Sanitize.run(data.msg) }
        for(con in clients) con.emit('chat', tmp);
      });

      socket.on('disconnect', function(socket:Socket) {
        clients.remove(myid);
        trace("disconnect");
      });
    });

    new SetInterval(Server.tick, 10000);
    tick();
  }

  public static function tick() {
    //ここから何も送られてこなくてもイベント発生させられる
    trace("tick" + Std.string(Lambda.count(clients)));
    for(con in clients) con.emit('ping', { hello: Lambda.count(clients) });  //なんとなくpingを送る
  }
}
