package ui.comp;

class BaseElement extends h2d.Flow implements h2d.domkit.Object {

    var baseUI(get,never) : BaseUI;
    function get_baseUI() return Game.inst.baseUI;

	public function new(?parent) {
		super(parent);
		initComponent();
	}
}