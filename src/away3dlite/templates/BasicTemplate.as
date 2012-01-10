package away3dlite.templates
{
	import away3dlite.arcane;
	import away3dlite.core.clip.*;
	import away3dlite.core.render.*;

	use namespace arcane;

	/**
	 * Template setup designed for general use.
	 */
	public class BasicTemplate extends Template
	{
		/** @private */
		arcane override function init():void
		{
			super.init();

			view.renderer = renderer = renderer ? renderer : view.renderer as BasicRenderer;
			view.clipping = clipping = clipping ? clipping : view.clipping;
		}

		protected var _renderer:BasicRenderer;

		/**
		 * The renderer object used in the template.
		 */
		public function get renderer():BasicRenderer
		{
			return _renderer || view.renderer as BasicRenderer;
		}

		/**
		 * @private
		 */
		public function set renderer(value:BasicRenderer):void
		{
			if (view)
				view.renderer = _renderer = value;
			else
				_renderer = value;
		}

		private var _clipping:Clipping;

		/**
		 * The clipping object used in the template.
		 */
		public function get clipping():Clipping
		{
			return _clipping || view.clipping;
		}

		/**
		 * @private
		 */
		public function set clipping(value:Clipping):void
		{
			if (view)
				view.clipping = _clipping = value;
			else
				_clipping = value;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			_renderer = null;
			_clipping = null;

			view.destroy();
			view = null;

			super.destroy();
		}
	}
}
