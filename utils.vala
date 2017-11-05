// This file contains various utilities

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

// KotoMenuItem is our custom Menu Item
public class KotoMenuItem : Gtk.Button {
	public KotoMenuItem(string text, string? icon = "", string? arrow = "") {
		var content = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
		set_can_focus(false);

		if ((icon != null) && (icon != "")) { // If we're defined an icon
			var image = new Gtk.Image.from_icon_name(icon, Gtk.IconSize.MENU);
			content.pack_start(image, false, false, 0);
		}

		var label = new Gtk.Label(text);
		content.pack_start(label, false, true, 0);

		if ((arrow != null) && (arrow != "")) { // If we've defined an arrow direction
			var symbolic = (arrow == "left") ? "previous" : arrow;
			symbolic = (arrow == "right") ? "next" : symbolic;
			var arrow_image = new Gtk.Image.from_icon_name("go-" + symbolic + "-symbolic", Gtk.IconSize.MENU);
			content.pack_end(arrow_image, false, false, 0);
		}

		get_style_context().add_class("flat");
		set_relief(Gtk.ReliefStyle.NONE);
		add(content);
	}
}