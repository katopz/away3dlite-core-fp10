package away3dlite.materials
{
	import away3dlite.arcane;
	import away3dlite.containers.*;

	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.BitmapFilter;
	import flash.geom.*;

	use namespace arcane;

	public class MovieMaterial extends BitmapMaterial
	{
		/** @private */
		arcane override function notifyActivate(scene:Scene3D):void
		{
			super.notifyActivate(scene);
			scene._broadcaster.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			onEnterFrame();
		}

		/** @private */
		arcane override function notifyDeactivate(scene:Scene3D):void
		{
			super.notifyActivate(scene);
			scene._broadcaster.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private var _transparent:Boolean;
		private var _movie:Sprite;
		private var _movieRect:Rectangle;
		private var _rect:Rectangle;
		private var _drawRect:Rectangle;
		private var _bitmapDirty:Boolean;
		private var _smooth:Boolean = true;

		private function onEnterFrame(event:Event = null):void
		{
			if (_isDestroyed)
				EventDispatcher(event.currentTarget).removeEventListener(event.type, arguments["callee"]);
			else if (autoUpdate)
				update();
		}

		private function updateBitmap():void
		{
			_bitmapDirty = false;

			_drawRect = _rect || _movieRect;

			if (_drawRect.width == 0 || _drawRect.height == 0)
				_drawRect = new Rectangle(0, 0, 256, 256);

			_graphicsBitmapFill.bitmapData = new BitmapData(int(_drawRect.width + 0.99), int(_drawRect.height + 0.99), _transparent, 0);

			dirty = true;
		}

		/**
		 * Indicates whether the texture bitmap is updated on every frame
		 */
		public var autoUpdate:Boolean;

		/**
		 * Defines the transparent property of the texture bitmap created from the movie
		 *
		 * @see movie
		 */
		public function get transparent():Boolean
		{
			return _transparent;
		}

		public function set transparent(val:Boolean):void
		{
			_transparent = val;

			_bitmapDirty = true;
		}

		/**
		 * Defines the movieclip used for rendering the material
		 */
		public function get movie():Sprite
		{
			return _movie;
		}

		public function set movie(val:Sprite):void
		{
			if (_movie == val)
				return;

			//if (val && val.parent)
			//	val.parent.removeChild(val);

			_movie = val;

			_movieRect = _movie.getBounds(_movie);

			_bitmapDirty = true;

			if (!autoUpdate)
				update();
		}

		/**
		 * Defines the rectangle of the movie to be rendered into the texture bitmap.
		 *
		 * @see movie
		 */
		public function get rect():Rectangle
		{
			return _rect;
		}

		public function set rect(val:Rectangle):void
		{
			_rect = val;

			_bitmapDirty = true;
		}

		/**
		 * Defines whether smoothing is used when drawing the material.
		 */
		override public function get smooth():Boolean
		{
			return _smooth;
		}

		override public function set smooth(val:Boolean):void
		{
			super.smooth = _smooth = val;

			_bitmapDirty = true;

			if (!autoUpdate)
				update();
		}

		public var filters:Array;

		public function MovieMaterial(movie:Sprite, rect:Rectangle = null, autoUpdate:Boolean = true, transparent:Boolean = true)
		{
			this.autoUpdate = autoUpdate;
			this.movie = movie;
			this.rect = rect;
			this.transparent = transparent;
		}

		/**
		 * Manually updates the texture bitmap with the current frame of the <code>movie</code> display object.
		 * Automatically triggered unless <code>autoUpdate</code> is set to false.
		 *
		 * @see movie
		 * @see autoUpdate
		 */
		public function update():void
		{
			if (_bitmapDirty)
				updateBitmap();

			var _bitmapData:BitmapData = _graphicsBitmapFill.bitmapData;
			var r:Rectangle = _bitmapData.rect;
			var m:Matrix = new Matrix(_movie.scaleX, 0, 0, _movie.scaleY, -_drawRect.x, -_drawRect.y);

			_bitmapData.fillRect(r, 0x000000);
			_bitmapData.draw(_movie, m, _movie.transform.colorTransform, _movie.blendMode, r, _smooth);

			if (filters && filters.length > 0)
				for each (var filter:BitmapFilter in filters)
					_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, new Point, filter);

			dirty = true;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			_movie = null;

			super.destroy();
		}
	}
}