package st;

class KnowledgeNode extends State {

	@:s public var discovered : Bool = false;
	@:s public var id : Data.KnowledgeKind;
	public var parent : KnowledgeNode = null;
	public var children : Array<KnowledgeNode> = [];
	public var inf : Data.Knowledge_props;
	public var level : Int;

	public function new(id) {
		super();
		this.id = id;
	}

	public function iter(cb : KnowledgeNode -> Void) {
		cb(this);
		for ( c in children )
			c.iter(cb);
	}

	public function getIndex() {
		if ( parent != null )
			return parent.children.indexOf(this);
		return -1;
	}

	public static function buildTree() {
		var knowledgeCdb = Data.knowledge.all.toArrayCopy();
		var knowledges = [for ( i => k in knowledgeCdb ) new KnowledgeNode(k.id)];
		var root = null;
		for ( i => k in knowledgeCdb ) {
			var knowledge = knowledges[i];
			knowledge.inf = k.props;
			if ( k.parent != null ) {
				var parentIndex = knowledgeCdb.indexOf(k.parent);
				var parent = knowledges[parentIndex];
				knowledge.parent = parent;
				parent.children.push(knowledge);
			} else {
				if ( root != null )
					throw "There must be ONLY one knowledge without parent (the root)";
				root = knowledge;
			}
		}
		for ( n in knowledges ) {
			var level = 0;
			var p = n.parent;
			while ( p != null ) {
				p = p.parent;
				level++;
			}
			n.level = level;
		}
		if ( root == null )
			throw "There must be one knowledge without parent (the root)";
		return root;
	}
}