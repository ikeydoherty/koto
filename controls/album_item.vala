// KotoAlbumItem is our basic item / view for an Album

namespace Koto {
	public class KotoAlbumItem : Gtk.Box {
		public KotoAlbum album;
		public Gtk.Box album_info; // album_info contains the album name, track link, track grid
		public Gtk.FlowBox track_list;

		public KotoAlbumItem(KotoAlbum a_album) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 15); // Orient horizontally
			margin = 30;
			album = a_album;
			album_info = create_album_info(); // Create our album info

			if (album.artwork_uri != "") { // If we have album artwork
				try {
					Gdk.Pixbuf artwork_pixbuf = new Gdk.Pixbuf.from_file_at_scale(album.artwork_uri, 200, 200, true); // Use a Gdk.Pixbuf so we can scale the image up / down depending on its size
					Gtk.Image album_art = new Gtk.Image.from_pixbuf(artwork_pixbuf); // Create a new image based on our artwork pixbuf
					album_art.valign = Gtk.Align.START; // Align to top of album item

					pack_start(album_art, false, false, 0);
				} catch (Error e) {
					stdout.printf("Failed to create a pixbuf for %s: %s", album.artwork_uri, e.message);
				}
			}

			foreach (KotoTrack track in album.tracks.values) { // For each track
				Koto.TrackItem track_item = new Koto.TrackItem(track); // Create a new track item

				track_list.insert(track_item, -1); // Add the track item
				track_list.invalidate_sort(); // Sort our tracks
			}

			pack_start(album_info, false, true, 0);
		}

		// create_album_info will create our album info box
		private Gtk.Box create_album_info() {
			var album_info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0); // Create a new vertically oriented box

			Gtk.Label album_name_label = new Gtk.Label(album.name);
			album_name_label.justify = Gtk.Justification.LEFT;
			album_name_label.xalign = 0; // Align to left (or right for RTL)

			Pango.AttrList album_name_attrs = new Pango.AttrList();
			album_name_attrs.insert(Pango.attr_scale_new(1.4));
			album_name_label.attributes = album_name_attrs;

			var tracks_count_str = _("Tracks (%s)"); // Default to tracks count being Tracks (num)

			if (album.genres.contains("Audiobook")) { // If this is an Audiobook
				tracks_count_str = _("Chapters (%s)");
			}

			Gtk.Label tracks_count = new Gtk.Label(tracks_count_str.printf(album.tracks.size.to_string()));
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
			track_list.activate_on_single_click = false; // Require double-click to activate item
			track_list.child_activated.connect(track_item_click);
			track_list.homogeneous = false; // Allow items to have different width
			track_list.selection_mode = Gtk.SelectionMode.SINGLE;
			track_list.min_children_per_line = 2; // At least have a side-by-side list

			// Have some spacing in between tracks
			track_list.column_spacing = 5;
			track_list.row_spacing = 5;

			// Sort our files
			track_list.set_sort_func(track_items_sort);

			album_info_box.pack_start(track_list, false, true, 0); // Add track list

			return album_info_box;
		}

		// track_item_click will handle the clicking of an item
		public void track_item_click(Gtk.FlowBoxChild item) {
			KotoTrack track = ((Koto.TrackItem) item.get_child()).track; // Get the cooresponding track to a TrackItem
			Koto.playback.track = track; // Change the track
			Koto.playback.load_file(track); // Load the track's file
			Koto.playback.play(); // Start playing
			return;
		}

		// track_items_sort is responsible for sorting between two children
		private int track_items_sort(Gtk.FlowBoxChild first_child, Gtk.FlowBoxChild second_child) {
			string first_child_text = ((Koto.TrackItem) first_child.get_child()).track.title;
			string second_child_text = ((Koto.TrackItem) second_child.get_child()).track.title;

			if (first_child_text.has_prefix(_("Chapter"))) { // If this is an audiobook, has the string Chapter, do some special comparison because strcmp isn't good with numbers
				int first_chapter_num = int.parse(first_child_text.replace(_("Chapter") + " ", "")); // Strip out Chapter # (or the locale string) for the first chapter
				int second_chapter_num = int.parse(second_child_text.replace(_("Chapter") + " ", "")); // Strip out Chapter # (or the locale string) for the second chapter

				return (first_chapter_num <= second_chapter_num) ? -1 : 1; // If the first chapter is a lower number than the second chapter, place it first
			} else {
				return (GLib.strcmp(first_child_text, second_child_text) <= 0) ? -1 : 1;
			}
		}
	}
}