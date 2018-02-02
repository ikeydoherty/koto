// FlatIconButton is our custom flat icon Button

namespace Koto{
	public class FlatIconButton : Gtk.EventBox {
		public signal void clicked(); // Our click emulation
		public Gtk.Image icon;
		private int _size;

		public FlatIconButton(string icon_string, int size) {
			Object();
			_size = size;

			get_style_context().add_class("button");
			get_style_context().add_class("flat");
			get_style_context().add_class("image-button");
			get_style_context().save();

			set_icon(icon_string, null);
			add(icon);

			button_release_event.connect((e) => {
				if (e.button != 1) {
					return Gdk.EVENT_PROPAGATE; 
				}

				clicked();

				return Gdk.EVENT_STOP;
			});
		}

		public void set_icon(string ico, int? at_size) { // Icon Manipulation
			Gdk.Pixbuf icon_pixbuf;

			if (at_size == null) { // If no requested size is provided
				at_size = _size; // Default at_size to current size
			}

			try {
				icon_pixbuf = Koto.icontheme.load_icon(ico, 64, Gtk.IconLookupFlags.GENERIC_FALLBACK);
			} catch (Error e) {
				error("Failed to fetch the icon for %s in your icon theme.\n".printf(ico));
			}

			int width_ratio = icon_pixbuf.width / icon_pixbuf.height; // Get the ratio of the icon's width to height so we can perform the most appropriate scaling
			int final_width; // The final width

			if (width_ratio == 1) { // If the width is exactly the same as the height
				final_width = at_size;
			} else if (width_ratio < 1) { // If the width is smaller than the height
				final_width = at_size * width_ratio; // Set width to appropriate ratio
			} else { // If width is greater than height
				final_width = (int) Math.floor(at_size / width_ratio); // Set width to the size divided by width
			}

			icon_pixbuf = icon_pixbuf.scale_simple(final_width, at_size, Gdk.InterpType.BILINEAR); // Scale to the appropriate size

			if (icon != null) { // If we already have an icon created
				icon.set_from_pixbuf(icon_pixbuf);
			} else {
				icon = new Gtk.Image.from_pixbuf(icon_pixbuf);
			}

			queue_draw();
		}
	}
}