// This file contains code for the Views List control

namespace Koto {
	public class KotoViewsList : Gtk.Box {
		public KotoMenuItem library_item;
		public KotoMenuItem playlist_item;
		public KotoMenuItem devices_item;

		public KotoViewsList() {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
			get_style_context().add_class("sidebar");
			set_size_request(200, -1); // Set a width of 200px

			Gtk.Label browse_label = dim_stack_label(_("Browse"));
			Gtk.Label locations_label = dim_stack_label(_("Other Locations"));

			library_item = new KotoMenuItem(_("Library"), "folder-music-symbolic");
			playlist_item = new KotoMenuItem(_("Playlists"), "emblem-favorite-symbolic");
			devices_item = new KotoMenuItem(_("Devices"), "phone-apple-iphone-symbolic");

			pack_start(browse_label, false, false, 10);
			pack_start(library_item, false, false, 0);
			pack_start(playlist_item, false, false, 0);
			pack_start(locations_label, false, false, 10);
			pack_start(devices_item, false, false, 0);

			library_item.clicked.connect(() => {
				switch_to_view("library");
			});

			devices_item.clicked.connect(() => {
				switch_to_view("devices");
			});
		}

		Gtk.Label dim_stack_label(string label_text) {
			Pango.AttrList info_attributes = new Pango.AttrList();
			info_attributes.insert(Pango.attr_scale_new(0.9));

			Gtk.Label dim_label = new Gtk.Label("<b>" + label_text + "</b>");
			dim_label.attributes = info_attributes;
			dim_label.get_style_context().add_class("dim-label");
			dim_label.halign = Gtk.Align.START; // Align horizontally to the start of the item (left for LTR)
			dim_label.margin_left = 10;
			dim_label.margin_right = 10;
			dim_label.use_markup = true;

			return dim_label;
		}

		void switch_to_view(string name) {
			app.current_view = name;
			app.global_views.set_visible_child_name(name);
		}
	}
}