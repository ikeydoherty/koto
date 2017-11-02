// This contains the code for our Menu Popover

public class KotoMenuPopover : Gtk.Popover {

	public KotoMenuPopover(Gtk.Widget? parent_widget) {
		Object(relative_to: parent_widget);
		set_size_request(120,100);
	}
}