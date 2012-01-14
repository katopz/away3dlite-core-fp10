package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.cameras.*;
	import away3dlite.containers.*;
	import away3dlite.core.*;
	import away3dlite.loaders.utils.*;

	import flash.display.*;
	import flash.geom.*;

	use namespace arcane;

	/**
	 * Dispatched when a user moves the cursor while it is over the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "mouseMove", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user presses the left hand mouse button while the cursor is over the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "mouseDown", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user releases the left hand mouse button while the cursor is over the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "mouseUp", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user moves the cursor over the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "mouseOver", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user moves the cursor away from the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "mouseOut", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user rolls over the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "rollOver", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * Dispatched when a user rolls out of the 3d object.
	 *
	 * @eventType away3dlite.events.MouseEvent3D
	 */
	[Event(name = "rollOut", type = "away3dlite.events.MouseEvent3D")]

	/**
	 * The base class for all 3d objects.
	 */
	public class Object3D extends Sprite implements IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;
		/** @private */
		arcane var _frustumCulling:Boolean;
		/** @private */
		arcane var _perspCulling:Boolean;
		/** @private */
		arcane var _screenZ:Number = 0;
		/** @private */
		arcane var _scene:Scene3D;
		/** @private */
		arcane var _viewMatrix3D:Matrix3D = new Matrix3D();
		/** @private */
		arcane var _sceneMatrix3D:Matrix3D = new Matrix3D();
		/** @private */
		private var _cachedViewMatrix3D:Matrix3D;

		/** @private */
		arcane function updateScene(val:Scene3D):void
		{
		}

		/** @private */
		arcane function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			_sceneMatrix3D.rawData = transform.matrix3D.rawData;

			if (parentSceneMatrix3D)
				_sceneMatrix3D.append(parentSceneMatrix3D);

			_viewMatrix3D.rawData = _sceneMatrix3D.rawData;
			_viewMatrix3D.append(camera._screenMatrix3D);

			_screenZ = _viewMatrix3D.position.z;

			//perspective culling
			var persp:Number = camera.zoom / (1 + _screenZ / camera.focus);

			if (minPersp != maxPersp && (persp < minPersp || persp >= maxPersp))
				_perspCulling = true;
			else
				_perspCulling = false;

			if (!_cachedViewMatrix3D)
			{
				_cachedViewMatrix3D = _viewMatrix3D.clone();
				if (_scene)
					_scene.isDirty = true;
			}

			// dirty
			if (_scene)
			{
				_scene.isDirty = _scene.isDirty || checkDirty(_viewMatrix3D.rawData, _cachedViewMatrix3D.rawData);

				if (_scene.isDirty)
					_cachedViewMatrix3D = _viewMatrix3D.clone();
			}
		}

		private function checkDirty(a:Vector.<Number>, b:Vector.<Number>):Boolean
		{
			var i:int = 16;
			while (--i > -1 && a[int(i)] == b[int(i)])
			{
			}
			if (i >= 0)
				return true;
			else
				return false;
		}

		/**
		 * Returns the maxinum length of 3d object to local center aka radius
		 */
		public var maxRadius:Number = 0;

		/**
		 * Global position in space, use for Frustum object culler
		 */
		public var projectedPosition:Vector3D;

		/**
		 * An optional layer sprite used to draw into inseatd of the default view.
		 */
		arcane var _layer:Sprite;

		public function set layer(value:Sprite):void
		{
			_layer = value;
		}

		public function get layer():Sprite
		{
			return _layer;
		}

		/**
		 * An optional canvas sprite used to draw into inseatd of the default view.
		 */
		arcane var _canvas:Sprite;

		public function set canvas(value:Sprite):void
		{
			_canvas = value;
			if (parent && parent is ObjectContainer3D)
				ObjectContainer3D(parent).updateCanvas();
		}

		public function get canvas():Sprite
		{
			return _canvas;
		}

		/**
		 * Used in loaders to store all parsed materials contained in the model.
		 */
		public var materialLibrary:MaterialLibrary;

		/**
		 * Used in loaders to store all parsed geometry data contained in the model.
		 */
		public var geometryLibrary:GeometryLibrary;

		/**
		 * Used in the loaders to store all parsed animation data contained in the model.
		 */
		public var animationLibrary:AnimationLibrary;

		/**
		 * Returns the type of 3d object.
		 */
		public var type:String;

		/**
		 * Returns the source url of the 3d object, or the name of the family of generative geometry objects if not loaded from an external source.
		 */
		public var url:String;

		/**
		 * The maximum perspective value from which the 3d object can be viewed.
		 */
		public var maxPersp:Number = 0;

		/**
		 * The minimum perspective value from which the 3d object can be viewed.
		 */
		public var minPersp:Number = 0;

		/**
		 * Returns the scene to which the 3d object belongs
		 */
		public function get scene():Scene3D
		{
			return _scene;
		}

		/**
		 * Returns the z-sorting position of the 3d object.
		 */
		public function get screenZ():Number
		{
			return _screenZ;
		}

		/**
		 * Returns a 3d matrix representing the absolute transformation of the 3d object in the view.
		 */
		public function get viewMatrix3D():Matrix3D
		{
			return _viewMatrix3D;
		}

		/**
		 * Returns a 3d matrix representing the absolute transformation of the 3d object in the scene.
		 */
		public function get sceneMatrix3D():Matrix3D
		{
			return _sceneMatrix3D;
		}

		/**
		 * Returns a 3d vector representing the local position of the 3d object.
		 */
		public function get position():Vector3D
		{
			return transform.matrix3D.position;
		}

		override public function set alpha(value:Number):void
		{
			if(super.alpha == value)
				return;
			
			super.alpha = value;
			
			if (canvas && canvas.alpha != value)
				canvas.alpha = value;
			
			if (_scene)
				_scene.isDirty = true;
		}

		override public function set blendMode(value:String):void
		{
			if(super.blendMode == value)
				return;
			
			super.blendMode = value;
			
			if (canvas && canvas.blendMode != value)
				canvas.blendMode = value;
			
			if (_scene)
				_scene.isDirty = true;
		}

		override public function set filters(value:Array):void
		{
			if(super.filters == value)
				return;
			
			super.filters = value;
			
			if (canvas && canvas.filters != value)
				canvas.filters = value;
			
			if (_scene)
				_scene.isDirty = true;
		}

		override public function set visible(value:Boolean):void
		{
			if(super.visible == value)
				return;
			
			super.visible = value;
			
			if (canvas && canvas.visible != value)
				canvas.visible = value;
			
			if (_scene)
				_scene.isDirty = true;
		}

		/**
		 * Creates a new <code>Object3D</code> object.
		 */
		public function Object3D()
		{
			super();

			//enable for 3d calculations
			transform.matrix3D = new Matrix3D();
		}

		/**
		 * Moves the 3D object forwards along it's local z axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveForward(distance:Number):void
		{
			translate(new Vector3D(0, 0, 1), distance);
		}

		/**
		 * Moves the 3D object backwards along it's local z axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveBackward(distance:Number):void
		{
			translate(new Vector3D(0, 0, -1), distance);
		}

		/**
		 * Moves the 3D object backwards along it's local x axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveLeft(distance:Number):void
		{
			translate(new Vector3D(-1, 0, 0), distance);
		}

		/**
		 * Moves the 3D object forwards along it's local x axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveRight(distance:Number):void
		{
			translate(new Vector3D(1, 0, 0), distance);
		}

		/**
		 * Moves the 3D object forwards along it's local y axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveUp(distance:Number):void
		{
			translate(new Vector3D(0, -1, 0), distance);
		}

		/**
		 * Moves the 3D object backwards along it's local y axis
		 *
		 * @param	distance	The length of the movement
		 */
		public function moveDown(distance:Number):void
		{
			translate(new Vector3D(0, 1, 0), distance);
		}

		/**
		 * Moves the 3D object along a vector by a defined length
		 *
		 * @param	axis		The vector defining the axis of movement
		 * @param	distance	The length of the movement
		 */
		public function translate(axis:Vector3D, distance:Number):void
		{
			axis.normalize();
			var _matrix3D:Matrix3D = transform.matrix3D;
			axis.scaleBy(distance);
			_matrix3D.position = _matrix3D.transformVector(axis);

			if (_scene)
				_scene.isDirty = true;
		}

		/**
		 * Rotates the 3D object around it's local x-axis
		 *
		 * @param	degrees		The degree of the rotation.
		 */
		public function pitch(degrees:Number):void
		{
			rotate(degrees, Vector3D.X_AXIS, position);
		}

		/**
		 * Rotates the 3D object around it's local y-axis
		 *
		 * @param	degrees		The degree of the rotation.
		 */
		public function yaw(degrees:Number):void
		{
			rotate(degrees, Vector3D.Y_AXIS, position);
		}

		/**
		 * Rotates the 3D object around it's local z-axis
		 *
		 * @param	degrees		The degree of the rotation.
		 */
		public function roll(degrees:Number):void
		{
			rotate(degrees, Vector3D.Z_AXIS, position);
		}

		/**
		 * Rotates the 3D object around an axis by a defined degrees
		 *
		 * @param	degrees		The degree of the rotation.
		 * @param	axis		The axis or direction of rotation. The usual axes are the X_AXIS (Vector3D(1,0,0)), Y_AXIS (Vector3D(0,1,0)), and Z_AXIS (Vector3D(0,0,1)).
		 * @param	pivotPoint	A point that determines the center of an object's rotation. The default pivot point for an object is its registration point.
		 */
		public function rotate(degrees:Number, axis:Vector3D, pivotPoint:Vector3D = null):void
		{
			axis.normalize();

			var _matrix3D:Matrix3D = transform.matrix3D;
			_matrix3D.appendRotation(degrees, _matrix3D.deltaTransformVector(axis), pivotPoint);

			if (_scene)
				_scene.isDirty = true;
		}

		/**
		 * Rotates the 3D object around to face a point defined relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 *
		 * @param	target		The vector defining the point to be looked at
		 * @param	upAxis		An optional vector used to define the desired up orientation of the 3D object after rotation has occurred
		 */
		public function lookAt(target:Vector3D, upAxis:Vector3D = null):void
		{
			transform.matrix3D.pointAt(target, Vector3D.Z_AXIS, upAxis || new Vector3D(0, -1, 0));
		}

		/**
		 * Duplicates the 3D object's properties to another <code>Object3D</code> object
		 *
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
		public function clone(object:Object3D = null):Object3D
		{
			var object3D:Object3D = object || new Object3D();

			object3D.transform.matrix3D = transform.matrix3D.clone();
			object3D.name = name;
			object3D.filters = filters.concat();
			object3D.blendMode = blendMode;
			object3D.alpha = alpha;
			object3D.visible = visible;
			object3D.mouseEnabled = mouseEnabled;
			object3D.useHandCursor = useHandCursor;

			return object3D;
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			_viewMatrix3D = null;
			_sceneMatrix3D = null;
			_cachedViewMatrix3D = null;

			if (materialLibrary)
				materialLibrary.destroy();
			if (geometryLibrary)
				geometryLibrary.destroy();
			if (animationLibrary)
				animationLibrary.destroy();

			materialLibrary = null;
			geometryLibrary = null;
			animationLibrary = null;

			canvas = null;
			layer = null;

			if (parent)
				parent.removeChild(this);
		}
	}
}
