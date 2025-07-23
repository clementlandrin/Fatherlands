package shaders;

class OutlineShader extends hxsl.Shader {

	static var SRC = {

		@:import h3d.shader.BaseMesh;

		@input var normal : Vec3;

		@param var size : Float;
		@param var color : Vec4;
		var modelScale : Vec3;

		function __init__vertex() {
			{
				modelScale = vec3((vec4(1,0,0,0) * global.modelView).xyz.length(), (vec4(0,1,0,0) * global.modelView).xyz.length(), (vec4(0,0,1,0) * global.modelView).xyz.length());
				var pproj = vec4(relativePosition * global.modelView.mat3x4(), 1.) * camera.viewProj;
				relativePosition += normal * size * sqrt(pproj.w / 100) / modelScale;
			}
		}

		function fragment() {
			pixelColor = color;
		}

	};

}