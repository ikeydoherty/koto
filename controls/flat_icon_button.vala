// FlatIconButton is our custom flat icon Button

namespace Koto{
	public class FlatIconButton : Gtk.EventBox {
		public signal void clicked(); // Our click emulation
		public Gtk.Image icon;
		private Gtk.IconSize _size;

		public FlatIconButton(string icon_string, Gtk.IconSize size) {
			Object();

			get_style_context().add_class("button");
			get_style_context().add_class("flat");
			get_style_context().add_class("image-button");
			get_style_context().save();

			icon = new Gtk.Image.from_icon_name(icon_string, size);
			add(icon);
			_size = size;

			button_release_event.connect((e) => {
				if (e.button != 1) {
					return Gdk.EVENT_PROPAGATE; 
				}

				clicked();

				return Gdk.EVENT_STOP;
			});
		}

		public void set_icon(string ico) { // Icon Manipulation
			icon.set_from_icon_name(ico, _size);
		}
	}
}