package away3dlite.containers
{
	import away3dlite.animators.bones.*;
	import away3dlite.arcane;
	import away3dlite.cameras.*;
	import away3dlite.core.IDestroyable;
	import away3dlite.core.base.*;
	import away3dlite.lights.*;
	import away3dlite.sprites.*;

	import flash.display.*;
	import flash.geom.*;

	use namespace arcane;

	/**
	* 3d object container node for other 3d objects in a scene.
	*/
	public class ObjectContainer3D extends Mesh
	{
		/** @private */
		arcane override function updateScene(val:Scene3D):void
		{
			if (_scene == val)
				return;

			var light:AbstractLight3D;

			if (_scene)
				for each (light in _lights)
					_scene.removeSceneLight(light);

			if (val)
				for each (light in _lights)
					val.addSceneLight(light);

			super.updateScene(val);

			var child:Object3D;

			for each (child in _children)
				child.updateScene(_scene);

			updateCanvas();
		}

		public function updateCanvas():void
		{
			isChildUseCanvas = false;
			for each (var _child:Object3D in _children)
				isChildUseCanvas = isChildUseCanvas || (_child.canvas != null);
		}

		/** @private */
		arcane override function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			if (_sprites.length)
			{
				_cameraInvSceneMatrix3D = camera._invSceneMatrix3D;
				_cameraSceneMatrix3D.rawData = _cameraInvSceneMatrix3D.rawData;
				_cameraSceneMatrix3D.invert();
				_cameraPosition = _cameraSceneMatrix3D.position;
				_cameraForwardVector = new Vector3D(_cameraSceneMatrix3D.rawData[8], _cameraSceneMatrix3D.rawData[9], _cameraSceneMatrix3D.rawData[10]);
			}

			var light:AbstractLight3D;

			for each (light in _lights)
				light._camera = camera;

			super.project(camera, parentSceneMatrix3D);

			if (!_perspCulling)
			{
				var child:Object3D;

				for each (child in _children)
					child.project(camera, _sceneMatrix3D);
			}
		}

		private const _toDegrees:Number = 180 / Math.PI;
		private var _index:int;
		private var _children:Array = [];
		private var _sprites:Vector.<Sprite3D> = new Vector.<Sprite3D>();
		private var _lights:Vector.<AbstractLight3D> = new Vector.<AbstractLight3D>();
		private var _spriteVertices:Vector.<Number> = new Vector.<Number>();
		private var _spriteIndices:Vector.<int> = new Vector.<int>();
		private var _spritesDirty:Boolean;
		private var _cameraPosition:Vector3D;
		private var _cameraForwardVector:Vector3D;
		private var _spritePosition:Vector3D;
		private var _spriteRotationVector:Vector3D;
		private var _cameraSceneMatrix3D:Matrix3D = new Matrix3D();
		private var _cameraInvSceneMatrix3D:Matrix3D = new Matrix3D();
		private var _orientationMatrix3D:Matrix3D = new Matrix3D();
		private var _cameraMatrix3D:Matrix3D = new Matrix3D();

		private var _viewDecomposed:Vector.<Vector3D>;

		/**
		 * Set as true if child use canvas, use in render loop to be sure that sorting object for childs or not
		 */
		public var isChildUseCanvas:Boolean;

		/**
		* Returns the children of the container as an array of 3d objects.
		*/
		public function get children():Array
		{
			return _children;
		}

		/**
		* Returns the sprites of the container as an array of 3d sprites.
		*/
		public function get sprites():Vector.<Sprite3D>
		{
			return _sprites;
		}

		override public function set layer(value:Sprite):void
		{
			super.layer = value;

			for each (var object3D:Object3D in children)
				if (object3D is Mesh)
					object3D.layer = value;
		}

		override public function set canvas(value:Sprite):void
		{
			super.canvas = value;

			for each (var object3D:Object3D in children)
				if (object3D is Mesh)
					object3D.canvas = value;
		}


		/**
		* Returns the lights of the container as an array of 3d lights.
		*/
		public function get lights():Vector.<AbstractLight3D>
		{
			return _lights;
		}

		/**
		 * @inheritDoc
		 */
		public override function get vertices():Vector.<Number>
		{
			if (_sprites.length)
			{
				var i:int;
				var index:int;
				var sprite:Sprite3D;

				if (_spritesDirty)
				{
					_spritesDirty = false;

					for each (sprite in _sprites)
					{
						_spriteIndices = sprite.indices;

						index = sprite.index * 4;
						i = 4;

						while (i--)
							_indices[int(index + i)] = _spriteIndices[int(i)] + index;
					}

					buildFaces();
				}

				_orientationMatrix3D.rawData = _sceneMatrix3D.rawData;
				_orientationMatrix3D.append(_cameraInvSceneMatrix3D);

				_viewDecomposed = _orientationMatrix3D.decompose(Orientation3D.AXIS_ANGLE);

				_orientationMatrix3D.identity();
				_orientationMatrix3D.appendRotation(-_viewDecomposed[1].w * 180 / Math.PI, _viewDecomposed[1]);

				for each (sprite in _sprites)
				{
					if (sprite.alignmentType == AlignmentType.VIEWPLANE)
					{
						_orientationMatrix3D.transformVectors(sprite.vertices, _spriteVertices);
					}
					else
					{
						_spritePosition = sprite.position.subtract(_cameraPosition);

						_spriteRotationVector = _cameraForwardVector.crossProduct(_spritePosition);
						_spriteRotationVector.normalize();

						_cameraMatrix3D.rawData = _orientationMatrix3D.rawData;
						_cameraMatrix3D.appendRotation(Math.acos(_cameraForwardVector.dotProduct(_spritePosition) / (_cameraForwardVector.length * _spritePosition.length)) * _toDegrees, _spriteRotationVector);
						_cameraMatrix3D.transformVectors(sprite.vertices, _spriteVertices);
					}

					index = sprite.index * 12;
					i = 12;

					while ((i -= 3) >= 0)
					{
						//int casting avoids memory leak
						_vertices[int(index + i)] = _spriteVertices[int(i)] + sprite.x;
						_vertices[int(index + i + 1)] = _spriteVertices[int(i + 1)] + sprite.y;
						_vertices[int(index + i + 2)] = _spriteVertices[int(i + 2)] + sprite.z;
					}
				}


				// always dirty
				if (_scene)
					_scene.isDirty = true;
			}

			return _vertices;
		}

		/**
		 * Creates a new <code>ObjectContainer3D</code> object.
		 *
		 * @param	...childArray		An array of 3d objects to be added as children of the container on instatiation.
		 */
		public function ObjectContainer3D(... childArray)
		{
			super();

			for each (var child:Object3D in childArray)
				addChild(child);
		}

		/**
		 * Adds a 3d object to the scene as a child of the container.
		 *
		 * @param	child	The 3d object to be added.
		 */
		public override function addChild(child:DisplayObject):DisplayObject
		{
			if (_scene)
				_scene.isDirty = true;

			child = super.addChild(child);

			_children[_children.length] = child as Object3D;

			(child as Object3D).updateScene(_scene);

			return child;
		}

		/**
		 * Removes a 3d object from the child array of the container.
		 *
		 * @param	child	The 3d object to be removed.
		 */
		public override function removeChild(child:DisplayObject):DisplayObject
		{
			if (_scene)
				_scene.isDirty = true;

			if (child.parent)
				child = super.removeChild(child);

			_index = _children.indexOf(child);

			if (_index == -1)
				return null;

			_children.splice(_index, 1);

			(child as Object3D).updateScene(null);

			return child;
		}

		/**
		 * Adds a 3d sprite to the scene as a child of the container.
		 *
		 * @param	sprite	The 3d sprite to be added.
		 */
		public function addSprite(sprite:Sprite3D):Sprite3D
		{
			vectorsFixed = false;
			_sprites[sprite.index = _sprites.length] = sprite;

			_indices.length += 4;
			_vertices.length += 12;

			_uvtData = _uvtData.concat(sprite.uvtData);
			_faceMaterials.push(sprite.material);
			_faceLengths.push(4);

			_spritesDirty = true;
			vectorsFixed = true;

			return sprite;
		}

		/**
		 * Removes a 3d sprite from the sprites array of the container.
		 *
		 * @param	sprite	The 3d sprite to be removed.
		 */
		public function removeSprite(sprite:Sprite3D):Sprite3D
		{
			vectorsFixed = false;
			_index = _sprites.indexOf(sprite);

			if (_index == -1)
				return null;

			_sprites.splice(_index, 1);

			// shift indices down one - get vertices chokes on this
			var _sprites_length:int = _sprites.length;
			for (var i:int = _index; i < _sprites_length; ++i)
				_sprites[int(i)].index = int(i);

			// remove screen vertices if needed - clipping chokes on them
			if (_screenVertices.length > 0)
				_screenVertices.length -= 8;

			_indices.length -= 4;
			_vertices.length -= 12;

			_uvtData.splice(_index * 12, 12);
			_faceMaterials.splice(_index, 1);
			_faceLengths.splice(_index, 1);
			_faces.splice(_index, 1); // rectangle clipping chokes on faces
			_spritesDirty = true;
			vectorsFixed = true;

			return sprite;
		}


		/**
		 * lock or unlock vectors when adding or removing sprites
		 */
		public function set vectorsFixed(value:Boolean):void
		{
			_sprites.fixed = _indices.fixed = _vertices.fixed = _uvtData.fixed = _faceMaterials.fixed = _faceLengths.fixed = _faces.fixed = value;
		}

		/**
		 * Adds a 3d light to the lights array of the container.
		 *
		 * @param	light	The 3d light to be added.
		 */
		public function addLight(light:AbstractLight3D):AbstractLight3D
		{
			_lights[_lights.length] = light;

			if (_scene)
				_scene.addSceneLight(light);

			return light;
		}

		/**
		 * Removes a 3d light from the lights array of the container.
		 *
		 * @param	light	The 3d light to be removed.
		 */
		public function removeLight(light:AbstractLight3D):AbstractLight3D
		{
			_index = _lights.indexOf(light);

			if (_index == -1)
				return null;

			_sprites.splice(_index, 1);

			if (_scene)
				_scene.removeSceneLight(light);

			return light;
		}

		/**
		 * Returns a 3d object specified by name from the child array of the container
		 *
		 * @param	name	The name of the 3d object to be returned
		 * @return			The 3d object, or <code>null</code> if no such child object exists with the specified name
		 */
		public override function getChildByName(childName:String):DisplayObject
		{
			var child:Object3D;
			for each (var object3D:Object3D in children)
			{
				if (object3D.name)
					if (object3D.name == childName)
						return object3D;

				if (object3D is ObjectContainer3D)
				{
					child = (object3D as ObjectContainer3D).getChildByName(childName) as Object3D;
					if (child)
						return child;
				}
			}

			return null;
		}

		/**
		 * Returns a bone object specified by name from the child array of the container
		 *
		 * @param	name	The name of the bone object to be returned
		 * @return			The bone object, or <code>null</code> if no such bone object exists with the specified name
		 */
		public function getBoneByName(boneName:String):Bone
		{
			var bone:Bone;
			for each (var object3D:Object3D in children)
			{
				if (object3D is Bone)
				{
					bone = object3D as Bone;

					if (bone.name)
						if (bone.name == boneName)
							return bone;

					if (bone.boneId)
						if (bone.boneId == boneName)
							return bone;
				}
				if (object3D is ObjectContainer3D)
				{
					bone = (object3D as ObjectContainer3D).getBoneByName(boneName);
					if (bone)
						return bone;
				}
			}

			return null;
		}

		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object
		 *
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
		public override function clone(object:Object3D = null):Object3D
		{
			var container:ObjectContainer3D = (object as ObjectContainer3D) || new ObjectContainer3D();
			super.clone(container);

			var child:Object3D;
			for each (child in children)
				container.addChild(child.clone());

			return container;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			for each (var object3D:IDestroyable in children)
				object3D.destroy();

			object3D = null;

			_children = null;
			_sprites = null;
			_lights = null;
			_spriteVertices = null;
			_spriteIndices = null;
			_cameraSceneMatrix3D = null;
			_cameraInvSceneMatrix3D = null;
			_orientationMatrix3D = null;
			_cameraMatrix3D = null;

			super.destroy();
		}
	}
}
