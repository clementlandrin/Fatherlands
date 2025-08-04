package st;

class GameState extends State {
	@:s public var player : ent.Player;
	
	@:s public var curRoomId : String;
	@:ignore public var curRoom : ent.Room;
}