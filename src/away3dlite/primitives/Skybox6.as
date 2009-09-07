﻿package away3dlite.primitives{	import away3dlite.arcane;	import away3dlite.materials.*;    	use namespace arcane;	    /**    * Creates a 3d Skybox primitive.    */     public class Skybox6 extends AbstractPrimitive    {	    	private var _size:Number = 40000;    	private var _segments:int = 4;    	private var _pixelBorder:int = 1;				/**		 * @inheritDoc		 */    	protected override function buildPrimitive():void    	{    		super.buildPrimitive();    		    		var i:int;            var j:int;                        var udelta:Number = _pixelBorder/600;            var vdelta:Number = _pixelBorder/400;            if (material is BitmapMaterial) {                var bMaterial:BitmapMaterial = material as BitmapMaterial;                udelta = _pixelBorder/bMaterial.width;                vdelta = _pixelBorder/bMaterial.height;            }                    		for (i = 0; i <= _segments; i++) {    			for (j = 0; j <= _segments; j++) {    				    				//create front/back		    		_vertices.push(_size/2 - i*_size/_segments, _size/2 - j*_size/_segments, _size/2);		            _vertices.push(_size/2 - i*_size/_segments, _size/2 - j*_size/_segments, -_size/2);		        						_uvtData.push(1/3 - udelta - i*(1 - 6*udelta)/(3*_segments), 1 - vdelta - j*(1 - 4*vdelta)/(2*_segments), 1);					_uvtData.push(1/3 + udelta + i*(1 - 6*udelta)/(3*_segments), 1/2 - vdelta - j*(1 - 4*vdelta)/(2*_segments), 1);					    				//create top/bottom		    		_vertices.push(_size/2 - i*_size/_segments, _size/2, _size/2 - j*_size/_segments);		            _vertices.push(_size/2 - i*_size/_segments, -_size/2, _size/2 - j*_size/_segments);		                				_uvtData.push(2/3 + udelta + j*(1 - 6*udelta)/(3*_segments), 1/2 + vdelta + i*(1 - 4*vdelta)/(2*_segments), 1);    				_uvtData.push(1/3 + udelta + j*(1 - 6*udelta)/(3*_segments), 1 - vdelta - i*(1 - 4*vdelta)/(2*_segments), 1);    				    				//create left/right    				_vertices.push(_size/2, _size/2 - i*_size/_segments, _size/2 - j*_size/_segments);		            _vertices.push(-_size/2, _size/2 - i*_size/_segments, _size/2 - j*_size/_segments);		                				_uvtData.push(udelta + j*(1 - 6*udelta)/(3*_segments), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segments), 1);    				_uvtData.push(1 - udelta - j*(1 - 6*udelta)/(3*_segments), 1/2 - vdelta - i*(1 - 4*vdelta)/(2*_segments), 1);    			}    		}    		    		for (i = 1; i <= _segments; i++) {    			for (j = 1; j <= _segments; j++) {		            var a:int = 6*((_segments + 1)*j + i);                    var b:int = 6*((_segments + 1)*j + i - 1);                    var c:int = 6*((_segments + 1)*(j - 1) + i - 1);                    var d:int = 6*((_segments + 1)*(j - 1) + i);                                        _indices.push(c,d,b);                    _indices.push(d,a,b);                    _indices.push(c+1,b+1,d+1);                    _indices.push(d+1,b+1,a+1);                                        _indices.push(c+2,b+2,d+2);                    _indices.push(b+2,a+2,d+2);                    _indices.push(c+3,d+3,b+3);                    _indices.push(b+3,d+3,a+3);                                        _indices.push(c+4,d+4,b+4);                    _indices.push(d+4,a+4,b+4);                    _indices.push(c+5,b+5,d+5);                    _indices.push(d+5,b+5,a+5);                        			}    		}    	}    	    	/**    	 * Defines the dimensions of the skybox. Defaults to 40000.    	 */    	public function get size():Number    	{    		return _size;    	}    	    	public function set size(val:Number):void    	{    		if (_size == val)    			return;    		    		_size = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the number of segments that make up each face of the skybox. Defaults to 4.    	 */    	public function get segments():int    	{    		return _segments;    	}    	    	public function set segments(val:int):void    	{    		if (_segments == val)    			return;    		    		_segments = val;    		_primitiveDirty = true;    	}    	    	/**    	 * Defines the texture mapping border in pixels used around each face of the skybox. Defaults to 1    	 */    	public function get pixelBorder():int    	{    		return _pixelBorder;    	}    	    	public function set pixelBorder(val:int):void    	{    		if (_pixelBorder == val)    			return;    		    		_pixelBorder = val;    		_primitiveDirty = true;    	}    			/**		 * Creates a new <code>Skybox6</code> object.		 * 		 * @param	size		Defines the size of the skybox.		 * @param	segments	Defines the number of segments that make up each face of the skybox.		 * @param	pixelBorder	Defines the texture mapping border in pixels used around each face of the skybox.		 */        public function Skybox6(size:Number = 40000, segments:int = 4, pixelBorder:int = 1)        {            super();            			_size = size;			_segments = segments;			_pixelBorder = pixelBorder;						type = "Skybox";			url = "primitive";        }    } }