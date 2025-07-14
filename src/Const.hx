
class Const {

#if hl

	static function getConst( i : Data.ConstantKind ) {
		var c = Data.constant.get(i);
		if( c == null ) throw "Missing constant "+i+" (recompile)";
		return c;
	}

	public static inline function get( i : Data.ConstantKind ) : Float {
		return getConst(i).value;
	}

	public static inline function getInt( i : Data.ConstantKind ) {
		return Std.int(get(i));
	}

	// public static inline function getColor( i : Data.ConstantKind ) {
	// 	return getConst(i).color;
	// }

#end

}