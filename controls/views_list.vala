// This file contains code for the Views List control

public class KotoViewsList : Gtk.Box {
	private Koto app;
	public KotoMenuItem library_item;
	public KotoMenuItem devices_item;

	public KotoViewsList(Koto app) {
		Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
		get_style_context().add_class("sidebar");
		this.app = app;
		set_size_request(200, -1); // Set a width of 200px

		library_item = new KotoMenuItem(_("Library"), "folder-music-symbolic");
		devices_item = new KotoMenuItem(_("Devices"), "phone-apple-iphone-symbolic");

		pack_start(library_item, false, false, 0);
		pack_start(devices_item, false, false, 0);

		library_item.clicked.connect(() => {
			switch_to_view("library");
		});

		devices_item.clicked.connect(() => {
			switch_to_view("devices");
		});
	}

	void switch_to_view(string name) {
		if (name == "library") { // Library View
			app.current_view = "library";
			app.global_views.set_visible_child_name("library");
			app.header.toggle_view_button.sensitive = true;
		} else if (name == "devices") { // Devices View
			app.global_views.set_visible_child_name("devices");
			app.current_view = "devices";
			app.header.toggle_view_button.sensitive = false;
		}
	}
}