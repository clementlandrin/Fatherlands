package gfx;

class Material extends h3d.mat.PbrMaterial {

	override function set_specularTexture(t) {
		if( specularTexture == t )
			return t;
		var spec = mainPass.getShader(gfx.PropsTexture);
		var props : h3d.mat.PbrMaterial.PbrProps = props;
		var emit = props == null || props.emissive == null ? 0 : props.emissive;
		if( t != null ) {
			if( spec == null ) {
				spec = new gfx.PropsTexture();
				spec.emissiveValue = emit;
				mainPass.addShader(spec);
			}
		}
		return super.set_specularTexture(t);
	}
}