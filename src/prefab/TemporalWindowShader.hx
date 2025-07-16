package prefab;

class TemporalWindow extends hxsl.Shader {
	
	static var SRC = {

		@param var tex : Sampler2D;

		@global var global : {
			var time : Float;
			@perObject var modelViewInverse : Mat4;
		};

		@global var camera : {
			var inverseViewProj : Mat4;
		};

		var screenUV : Vec2;
		var pixelColor : Vec4;

		function fragment() {
			pixelColor = tex.get(screenUV);
			pixelColor.rgb *= vec3(0.5, 1.0, 0.5);
		}
	}
}

class TemporalWindowShader extends hrt.prefab.Shader {

	override function makeShader() {
		return new TemporalWindow();
	}

	override function updateInstance(?propName) {
		super.updateInstance(propName);

		var sh = cast(shader, TemporalWindow);
		sh.tex = h3d.mat.Texture.fromColor(0xFF00FF);
	}

	#if editor
	override function edit( ctx : hide.prefab.EditContext ) {
		ctx.properties.add(new hide.Element('
		'),this, pname -> ctx.onChange(this, pname));
	}
	#end

	static var _ = hrt.prefab.Prefab.register("temporalWindow", TemporalWindowShader);
}