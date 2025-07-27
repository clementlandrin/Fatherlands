package ui;

class MainUI extends Window {
	static var SRC =
	<main-u-i>
		<text id="roomDebug"/>
	</main-u-i>

	public function new(?parent) {
		super(parent);
		initComponent();
	}

	public function enterRoom(newRoom : ent.Room) {
		roomDebug.text = newRoom.name;
	}
}