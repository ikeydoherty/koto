// KotoAlbumItem is our basic item / view for an Album

namespace Koto {
	public class KotoAlbumItem : Gtk.Box {
		private KotoAlbum _album;
		public Gtk.Box album_info; // album_info contains the album name, track link, track grid
		public Gtk.FlowBox track_list;

		public KotoAlbumItem(KotoAlbum album) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 15); // Orient horizontally
			margin = 30;
			_album = album;
			album_info = create_album_info(); // Create our album info

			if (_album.artwork_uri != "") { // If we have album artwork
				try {
					Gdk.Pixbuf artwork_pixbuf = new Gdk.Pixbuf.from_file_at_scale(_album.artwork_uri, 200, 200, true); // Use a Gdk.Pixbuf so we can scale the image up / down depending on its size
					Gtk.Image album_art = new Gtk.Image.from_pixbuf(artwork_pixbuf); // Create a new image based on our artwork pixbuf
					pack_start(album_art, false, false, 0);
				} catch (Error e) {
					stdout.printf("Failed to create a pixbuf for %s: %s", _album.artwork_uri, e.message);
				}
			}

			foreach (KotoTrack track in _album.tracks.values) { // For each track
				Gtk.Label track_label = new Gtk.Label(track.title);
				track_label.justify = Gtk.Justification.LEFT;
				track_label.xalign = 0; // Align to left (or right for RTL)

				track_list.insert(track_label, -1); // Add the track item
			}

			pack_start(album_info, false, true, 0);
		}

		// create_album_info will create our album info box
		private Gtk.Box create_album_info() {
			var album_info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0); // Create a new vertically oriented box

			Gtk.Label album_name_label = new Gtk.Label(_album.name);
			album_name_label.justify = Gtk.Justification.LEFT;
			album_name_label.xalign = 0; // Align to left (or right for RTL)

			Pango.AttrList album_name_attrs = new Pango.AttrList();
			album_name_attrs.insert(Pango.attr_scale_new(1.4));
			album_name_label.attributes = album_name_attrs;

			Gtk.Label tracks_count = new Gtk.Label(_("Tracks (%s)").printf(_album.tracks.size.to_string()));
			tracks_count.get_style_context().add_class("dim-label");
			tracks_count.justify = Gtk.Justification.LEFT;
			tracks_count.margin_bottom = 5; // Have some space between track count and list
			tracks_count.xalign = 0; // Align to left (or right for RTL)

			Pango.AttrList track_count_attrs = new Pango.AttrList();
			track_count_attrs.insert(Pango.attr_scale_new(0.9));
			tracks_count.attributes = track_count_attrs;

			album_info_box.pack_start(album_name_label, false, true, 0); // Add the album name label
			album_info_box.pack_start(tracks_count, false, true, 0); // Add the tracks count label

			track_list = new Gtk.FlowBox();
			track_list.homogeneous = false; // Allow items to have different width
			track_list.selection_mode = Gtk.SelectionMode.SINGLE;
			track_list.min_children_per_line = 2; // At least have a side-by-side list

			// Have some spacing in between tracks
			track_list.column_spacing = 5;
			track_list.row_spacing = 5;

			album_info_box.pack_start(track_list, false, true, 0); // Add track list

			return album_info_box;
		}
	}
}