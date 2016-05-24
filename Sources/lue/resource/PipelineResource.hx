package lue.resource;

import kha.Image;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import lue.resource.SceneFormat;

class PipelineResource extends Resource {

	public var resource:TPipelineResource;
	public var renderTargets:Map<String, RenderTarget> = null;

	public function new(resource:TPipelineResource) {
		super();

		if (resource == null) {
			trace("Resource not found!");
			return;
		}

		this.resource = resource;

		if (resource.render_targets.length > 0) {
			renderTargets = new Map();

			for (t in resource.render_targets) {
				var rt = makeRenderTarget(t);
				if (t.ping_pong != null && t.ping_pong) rt.pong = makeRenderTarget(t);
				renderTargets.set(t.id, rt);
			}
		}
	}
	
	function makeRenderTarget(t:TPipelineRenderTarget) {
		var rt = new RenderTarget();
		var depthStencil = t.depth_buffer != null ? getDepthStencilFormat(t.depth_buffer, t.stencil_buffer) : DepthStencilFormat.NoDepthAndStencil;
		rt.image = createImage(t, depthStencil);
		rt.hasDepth = depthStencil == DepthStencilFormat.NoDepthAndStencil ? false : true;
		return rt;
	}

	function createImage(t:TPipelineRenderTarget, depthStencil:DepthStencilFormat):Image {
		return Image.createRenderTarget(
			t.width == 0 ? kha.System.windowWidth() : t.width,
			t.height == 0 ? kha.System.windowHeight() : t.height,
			t.format != null ? getTextureFormat(t.format) : TextureFormat.RGBA32,
			depthStencil);
	}

	inline function getTextureFormat(s:String):TextureFormat {
		if (s == "RGBA32") return TextureFormat.RGBA32;
		else if (s == "RGBA128") return TextureFormat.RGBA128;
		else if (s == "DEPTH16") return TextureFormat.DEPTH16;
		else if (s == "RGBA64") return TextureFormat.RGBA64;
		else return TextureFormat.RGBA32;
	}
	
	inline function getDepthStencilFormat(depth:Bool, stencil:Bool):DepthStencilFormat {
		if (depth && stencil) return DepthStencilFormat.Depth24Stencil8;
		else if (depth) return DepthStencilFormat.DepthOnly;
		else return DepthStencilFormat.NoDepthAndStencil; 
	}

	public static function parse(name:String, id:String):PipelineResource {
		var format:TSceneFormat = Resource.getSceneResource(name);
		var resource:TPipelineResource = Resource.getPipelineResourceById(format.pipeline_resources, id);
		return new PipelineResource(resource);
	}
}

class RenderTarget {
	// TODO: separate for each render target
	public static var is_pong = false;
	public static var is_last_target_pong = false;
	public static var is_last_two_targets_pong = false;
	public static var last_pong_target_pong = false;
	public var pong:RenderTarget = null;
	
	public var image:Image;
	public var hasDepth:Bool;
	public function new() {}
}
