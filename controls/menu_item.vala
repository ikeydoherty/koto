// KotoMenuItem is our custom menu item for lists, popovers, etc.
public class KotoMenuItem : Gtk.Button {
	public KotoMenuItem(string text, string? icon = "", string? arrow = "") {
		var content = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
		set_can_focus(false);

		if ((icon != null) && (icon != "")) { // If we're defined an icon
			var image = new Koto.FlatIconButton(icon, 16);
			content.pack_start(image, false, false, 0);
		}

		var label = new Gtk.Label(text);
		content.pack_start(label, false, true, 0);

		if ((arrow != null) && (arrow != "")) { // If we've defined an arrow direction
			var symbolic = (arrow == "left") ? "previous" : arrow;
			symbolic = (arrow == "right") ? "next" : symbolic;
			var arrow_image = new Koto.FlatIconButton("go-" + symbolic + "-symbolic", 16);
			content.pack_end(arrow_image, false, false, 0);
		}

		get_style_context().add_class("flat");
		set_relief(Gtk.ReliefStyle.NONE);
		add(content);
	}
}