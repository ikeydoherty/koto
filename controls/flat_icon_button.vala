// KotoFlatIconButton is our custom flat icon Button
public class KotoFlatIconButton : Gtk.Button {
	private Gtk.IconSize _size;

	public KotoFlatIconButton(string icon_string, Gtk.IconSize size) {
		var image = new Gtk.Image.from_icon_name(icon_string, size);
		Object(image: image);
		_size = size;

		get_style_context().add_class("flat");
		get_style_context().add_class("image-button");
		set_relief(Gtk.ReliefStyle.NONE);
	}

	public void set_icon(string ico) { // Icon Manipulation
		var image = new Gtk.Image.from_icon_name(ico, _size);
		this.image = image;
	}
}