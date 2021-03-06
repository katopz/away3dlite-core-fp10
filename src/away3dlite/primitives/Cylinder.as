﻿package away3dlite.primitives
{
	import away3dlite.arcane;
	import away3dlite.core.base.*;
	import away3dlite.materials.*;

	use namespace arcane;

	/**
	 * Creates a 3d cylinder primitive.
	 */
	public class Cylinder extends AbstractPrimitive
	{
		private var jMin:int;
		private var jMax:int;
		private var _radius:Number = 100;
		private var _height:Number = 200;
		private var _segmentsW:int = 8;
		private var _segmentsH:int = 1;
		private var _openEnded:Boolean = false;
		private var _yUp:Boolean = true;

		/**
		 * @inheritDoc
		 */
		protected override function buildPrimitive():void
		{
			super.buildPrimitive();

			var i:int;
			var j:int;

			_height /= 2;

			if (!_openEnded)
			{
				_segmentsH += 2;
				jMin = 1;
				jMax = _segmentsH - 1;

				for (i = 0; i <= _segmentsW; ++i)
				{
					_yUp ? _vertices.push(0, _height, 0) : _vertices.push(0, 0, -_height);
					_uvtData.push(i / _segmentsW, 1, 1);
				}
			}
			else
			{
				jMin = 0;
				jMax = _segmentsH;
			}

			for (j = jMin; j <= jMax; ++j)
			{
				var z:Number = -_height + 2 * _height * (j - jMin) / (jMax - jMin);

				for (i = 0; i <= _segmentsW; ++i)
				{
					var verangle:Number = 2 * Math.PI * i / _segmentsW;
					var x:Number = _radius * Math.cos(verangle);
					var y:Number = _radius * Math.sin(verangle);

					_yUp ? _vertices.push(x, -z, y) : _vertices.push(x, y, z);

					_uvtData.push(i / _segmentsW, 1 - j / _segmentsH, 1);
				}
			}

			if (!_openEnded)
			{
				for (i = 0; i <= _segmentsW; ++i)
				{
					_yUp ? _vertices.push(0, -_height, 0) : _vertices.push(0, 0, _height);
					_uvtData.push(i / _segmentsW, 0, 1);
				}
			}

			for (j = 1; j <= _segmentsH; ++j)
			{
				for (i = 1; i <= _segmentsW; ++i)
				{
					var a:int = (_segmentsW + 1) * j + i;
					var b:int = (_segmentsW + 1) * j + i - 1;
					var c:int = (_segmentsW + 1) * (j - 1) + i - 1;
					var d:int = (_segmentsW + 1) * (j - 1) + i;

					if (j > jMax)
					{
						_indices.push(a, c, d);
						_faceLengths.push(3);
					}
					else if (j <= jMin)
					{
						_indices.push(a, b, c);
						_faceLengths.push(3);
					}
					else
					{
						_indices.push(a, b, c, d);
						_faceLengths.push(4);
					}
				}
			}

			if (!_openEnded)
				_segmentsH -= 2;

			_height *= 2;
		}

		/**
		 * Defines the radius of the cylinder. Defaults to 100.
		 */
		public function get radius():Number
		{
			return _radius;
		}

		public function set radius(val:Number):void
		{
			if (_radius == val)
				return;

			_radius = val;
			_primitiveDirty = true;
		}

		/**
		 * Defines the height of the cylinder. Defaults to 200.
		 */
		public override function get height():Number
		{
			return _height;
		}

		public override function set height(val:Number):void
		{
			if (_height == val)
				return;

			_height = val;
			_primitiveDirty = true;
		}

		/**
		 * Defines the number of horizontal segments that make up the cylinder. Defaults to 8.
		 */
		public function get segmentsW():int
		{
			return _segmentsW;
		}

		public function set segmentsW(val:int):void
		{
			if (_segmentsW == val)
				return;

			_segmentsW = val;
			_primitiveDirty = true;
		}

		/**
		 * Defines the number of vertical segments that make up the cylinder. Defaults to 1.
		 */
		public function get segmentsH():int
		{
			return _segmentsH;
		}

		public function set segmentsH(val:int):void
		{
			if (_segmentsH == val)
				return;

			_segmentsH = val;
			_primitiveDirty = true;
		}

		/**
		 * Defines whether the ends of the cylinder are left open (true) or closed (false). Defaults to false.
		 */
		public function get openEnded():Boolean
		{
			return _openEnded;
		}

		public function set openEnded(val:Boolean):void
		{
			if (_openEnded == val)
				return;

			_openEnded = val;
			_primitiveDirty = true;
		}

		/**
		 * Defines whether the coordinates of the cylinder points use a yUp orientation (true) or a zUp orientation (false). Defaults to true.
		 */
		public function get yUp():Boolean
		{
			return _yUp;
		}

		public function set yUp(val:Boolean):void
		{
			if (_yUp == val)
				return;

			_yUp = val;
			_primitiveDirty = true;
		}

		/**
		 * Creates a new <code>Cylinder</code> object.
		 *
		 * @param	material	Defines the global material used on the faces in the cylinder.
		 * @param	radius		Defines the radius of the cylinder base.
		 * @param	height		Defines the height of the cylinder.
		 * @param	segmentsW	Defines the number of horizontal segments that make up the cylinder.
		 * @param	segmentsH	Defines the number of vertical segments that make up the cylinder.
		 * @param	openEnded	Defines whether the end of the cylinder is left open (true) or closed (false).
		 * @param	yUp			Defines whether the coordinates of the cylinder points use a yUp orientation (true) or a zUp orientation (false).
		 */
		public function Cylinder(material:Material = null, radius:Number = 100, height:Number = 200, segmentsW:int = 8, segmentsH:int = 1, openEnded:Boolean = false, yUp:Boolean = true)
		{
			super(material);

			_radius = radius;
			_height = height;
			_segmentsW = segmentsW;
			_segmentsH = segmentsH;
			_openEnded = openEnded;
			_yUp = yUp;

			type = "Cylinder";
			url = "primitive";
		}

		/**
		 * Duplicates the cylinder properties to another <code>Cylinder</code> object.
		 *
		 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Cylinder</code>.
		 * @return						The new object instance with duplicated properties applied.
		 */
		public override function clone(object:Object3D = null):Object3D
		{
			var cylinder:Cylinder = (object as Cylinder) || new Cylinder();
			super.clone(cylinder);
			cylinder.radius = _radius;
			cylinder.height = _height;
			cylinder.segmentsW = _segmentsW;
			cylinder.segmentsH = _segmentsH;
			cylinder.openEnded = _openEnded;
			cylinder.yUp = _yUp;
			cylinder._primitiveDirty = false;

			return cylinder;
		}
	}
}
