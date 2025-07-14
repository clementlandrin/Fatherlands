package prefab;

class Temporal extends hxsl.Shader {
	
	static var SRC = {

		@const var PAST : Bool;

		#if !editor
		@global var temporalRadius : Float;
		@global var playerPos : Vec3;


		var transformedPosition : Vec3;

		function fragment() {
			var isInside = distance(transformedPosition, playerPos) < temporalRadius;
			if ( PAST ) {
				if ( !isInside )
					discard;
			}
			if ( !PAST ) {
				if ( isInside )
					discard;
			}
		}
		#end
	}
}

class TemporalShader extends hrt.prefab.Shader {

	@:s var PAST : Bool = false;

	override function makeShader() {
		return new Temporal();
	}

	override function updateInstance(?propName) {
		super.updateInstance(propName);

		var sh = cast(shader, Temporal);
		sh.PAST = PAST;
	}

	#if editor
	override function edit( ctx : hide.prefab.EditContext ) {
		ctx.properties.add(new hide.Element('
			<dl>
				<div class="group" name="Mode">
					<dt>Past</dt><dd><input type="checkbox" field="PAST"/></dd>
				</div>
			</dl>
		'),this, pname -> ctx.onChange(this, pname));
	}
	#end

	static var _ = hrt.prefab.Prefab.register("temporalShader", TemporalShader);
}