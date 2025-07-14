package gfx;

class PropsTexture extends h3d.shader.pbr.PropsTexture {
	static var SRC = {

		function __init__fragment() {
			{
				var v = texture.get(calculatedUV);
				metalness = v.r;
				roughness = v.g;
				occlusion = v.b;
				emissive = emissiveValue * v.a;
			}
			custom1 = custom1Value;
			custom2 = custom2Value;
		}
	}

	public function new(?t) {
		super();
		this.texture = t;
	}
}
