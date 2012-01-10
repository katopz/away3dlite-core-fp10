﻿package away3dlite.materials{	import away3dlite.arcane;	import away3dlite.cameras.*;	import away3dlite.core.base.*;	import away3dlite.lights.*;	import flash.display.*;	import flash.filters.*;	import flash.geom.*;	use namespace arcane;	/**	 * Bitmap material with DOT3 shading.	 */	public class Dot3BitmapMaterial extends BitmapMaterial	{		private var _shaderJob:ShaderJob;		private var _shaderBlendMode:String = BlendMode.HARDLIGHT;		private var _lightMap:BitmapData;		private var _bitmap:BitmapData;		private var _shininess:Number = 20;		private var _specular:Number = 0.7;		private var _normalMap:BitmapData;		private var _normalVector:Vector.<Number>;		private var _normalShader:Shader;		private var _normalFilter:ShaderFilter;		private var _light:AbstractLight3D;		private var _directionalLight:DirectionalLight3D;		private var _pointLight:PointLight3D;		private var _positionMapDirty:Boolean;		[Embed(source = "../../../pbj/normalMapping.pbj", mimeType = "application/octet-stream")]		private var NormalShader:Class;		arcane override function updateMaterial(source:Mesh, camera:Camera3D):void		{			_lightMap.fillRect(_lightMap.rect, 0);			for each (_light in source.scene.sceneLights)			{				if ((_directionalLight = _light as DirectionalLight3D))				{					var _red:Number = _directionalLight._red * _directionalLight.diffuse;					var _green:Number = _directionalLight._green * _directionalLight.diffuse;					var _blue:Number = _directionalLight._blue * _directionalLight.diffuse;					var diffuseTransform:Matrix3D = _directionalLight.diffuseTransform.clone();					diffuseTransform.prepend(source.sceneMatrix3D);					var diffuseRawData:Vector.<Number> = diffuseTransform.rawData;					var _szx:Number = diffuseRawData[2];					var _szy:Number = diffuseRawData[6];					var _szz:Number = -diffuseRawData[10];					var mod:Number = Math.sqrt(_szx * _szx + _szy * _szy + _szz * _szz);					_szx /= mod;					_szy /= mod;					_szz /= mod;					_normalShader.data["diffuseMatrixR"]["value"] = [_red * _szx, _green * _szx, _blue * _szx, 0];					_normalShader.data["diffuseMatrixG"]["value"] = [_red * _szy, _green * _szy, _blue * _szy, 0];					_normalShader.data["diffuseMatrixB"]["value"] = [_red * _szz, _green * _szz, _blue * _szz, 0];					_normalShader.data["diffuseMatrixO"]["value"] = [-_red * (_szx + _szy + _szz) / 2, -_green * (_szx + _szy + _szz) / 2, -_blue * (_szx + _szy + _szz) / 2, 1];					_normalShader.data["ambientMatrixO"]["value"] = [_directionalLight._red * _directionalLight.ambient, _directionalLight._green * _directionalLight.ambient, _directionalLight._blue * _directionalLight.ambient, 1];					_red = (_directionalLight._red + _shininess) * _specular * 2;					_green = (_directionalLight._green + _shininess) * _specular * 2;					_blue = (_directionalLight._blue + _shininess) * _specular * 2;					var specularTransform:Matrix3D = _directionalLight.specularTransform.clone();					specularTransform.prepend(source.sceneMatrix3D);					var specularRawData:Vector.<Number> = specularTransform.rawData;					_szx = specularRawData[2];					_szy = specularRawData[6];					_szz = -specularRawData[10];					_normalShader.data["specularMatrixR"]["value"] = [_red * _szx, _green * _szx, _blue * _szx, 0];					_normalShader.data["specularMatrixG"]["value"] = [_red * _szy, _green * _szy, _blue * _szy, 0];					_normalShader.data["specularMatrixB"]["value"] = [_red * _szz, _green * _szz, _blue * _szz, 0];					_normalShader.data["specularMatrixO"]["value"] = [-_red * (_szx + _szy + _szz) / 2 - shininess * specular, -_green * (_szx + _szy + _szz) / 2 - shininess * specular, -_blue * (_szx + _szy + _szz) / 2 - shininess * specular, 1];					_normalShader.data["lightMap"]["input"] = _lightMap;					_shaderJob = new ShaderJob(_normalShader, _lightMap);					_shaderJob.start(true);				}				else if ((_pointLight = _light as PointLight3D))				{					if (_positionMapDirty)					{						_positionMapDirty = false;					}				}			}			_graphicsBitmapFill.bitmapData = _bitmap.clone();			_graphicsBitmapFill.bitmapData.draw(_lightMap, null, null, _shaderBlendMode);			//_graphicsBitmapFill.bitmapData.applyFilter(_bitmap, bitmap.rect, _zeroPoint, _normalFilter);			super.updateMaterial(source, camera);		}		/**		 * The exponential dropoff value used for specular highlights.		 */		public function get shininess():Number		{			return _shininess;		}		public function set shininess(val:Number):void		{			_shininess = val;		}		/**		 * Coefficient for specular light level.		 */		public function get specular():Number		{			return _specular;		}		public function set specular(val:Number):void		{			_specular = val;		}		/**		 * Returns the bitmapData object being used as the material normal map.		 */		public function get normalMap():BitmapData		{			return _normalMap;		}		/**		 * Creates a new <code>Dot3BitmapMaterial</code> object.		 *		 * @param	bitmap				The bitmapData object to be used as the material's texture.		 * @param	normalMap			The bitmapData object to be used as the material's DOT3 map.		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 */		public function Dot3BitmapMaterial(bitmap:BitmapData, normalMap:BitmapData)		{			super(bitmap);			_lightMap = bitmap.clone();			_bitmap = bitmap;			_normalMap = normalMap;			_normalVector = new Vector.<Number>(_normalMap.width * _normalMap.height * 4);			var w:int = _normalMap.width;			var h:int = _normalMap.height;			var i:int = h;			var j:int;			var pixel:int;			var pixelValue:int;			var rValue:Number;			var gValue:Number;			var bValue:Number;			var mod:Number;			//normalise map			while (i--)			{				j = w;				while (j--)				{					//get values					pixelValue = _normalMap.getPixel32(j, i);					rValue = ((pixelValue & 0x00FF0000) >> 16) - 127;					gValue = ((pixelValue & 0x0000FF00) >> 8) - 127;					bValue = ((pixelValue & 0x000000FF)) - 127;					//calculate modulus					mod = Math.sqrt(rValue * rValue + gValue * gValue + bValue * bValue) * 2;					//set normalised values					pixel = i * w * 4 + j * 4;					_normalVector[pixel] = rValue / mod + 0.5;					_normalVector[pixel + 1] = gValue / mod + 0.5;					_normalVector[pixel + 2] = bValue / mod + 0.5;					_normalVector[pixel + 3] = 1;				}			}			_normalShader = new Shader(new NormalShader());			_normalShader.data["normalMap"]["width"] = w;			_normalShader.data["normalMap"]["height"] = h;			_normalShader.data["normalMap"]["input"] = _normalVector;			_normalFilter = new ShaderFilter(_normalShader);		}	}}