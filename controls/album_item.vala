namespace Koto {
	public class AlbumItem : Gtk.Box {
		public KotoAlbum album;
		public Gtk.Image album_art;
		public Gtk.Box album_info; // album_info contains the album name, track link, track grid
		public Gtk.FlowBox track_list;

		// AlbumItem is our basic item / view for an Album
		public AlbumItem(KotoAlbum a_album) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 15); // Orient horizontally
			margin = 30;
			album = a_album;
			album_info = create_album_info(); // Create our album info

			if (album.artwork_uri != "") { // If we have album artwork
				try {
					Gdk.Pixbuf artwork_pixbuf = new Gdk.Pixbuf.from_file_at_scale(album.artwork_uri, 200, 200, true); // Use a Gdk.Pixbuf so we can scale the image up / down depending on its size
					album_art = new Gtk.Image.from_pixbuf(artwork_pixbuf); // Create a new image based on our artwork pixbuf
					album_art.valign = Gtk.Align.START; // Align to top of album item

					pack_start(album_art, false, false, 0);
				} catch (Error e) {
					stdout.printf("Failed to create a pixbuf for %s: %s", album.artwork_uri, e.message);
				}
			}

			foreach (KotoTrack track in album.tracks) { // For each track
				Koto.TrackItem track_item = new Koto.TrackItem(track); // Create a new track item

				track_list.insert(track_item, -1); // Add the track item
			}

			pack_start(album_info, false, true, 0);
		}

		// create_album_info will create our album info box
		private Gtk.Box create_album_info() {
			var album_info_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0); // Create a new vertically oriented box
			Koto.AlbumHeader album_header = new Koto.AlbumHeader(album); // Create our new Album Header

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

			album_info_box.pack_start(album_header, false, true, 0); // Add the Album Header
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

			album_info_box.pack_start(track_list, false, true, 0); // Add track list

			album_header.play_button.clicked.connect(() => { // On clicking the play button
				play_album();
			});

			return album_info_box;
		}

		// play_album will attempt to load our album as a playlist and play it
		public void play_album() {
			Koto.playback.playlist.clear(); // Clear our playlist
			Koto.playback.playlist.add_tracks(album.tracks);
			Koto.playback.start_playlist(); // Start playback of playlist
		}

		// track_item_click will handle the clicking of an item
		public void track_item_click(Gtk.FlowBoxChild item) {
			KotoTrack track = ((Koto.TrackItem) item.get_child()).track; // Get the cooresponding track to a TrackItem
			Koto.playback.playlist.clear(); // Clear the playlist
			Koto.playback.playlist.add_track(track); // Add this track
			Koto.playback.playlist.change_track(track); // Change the track
			return;
		}
	}

	// AlbumHeader is our custom album header
	public class AlbumHeader : Gtk.Box {
		public Koto.FlatIconButton favorite_button;
		public Koto.FlatIconButton play_button;

		public AlbumHeader(KotoAlbum album) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);

			Gtk.Label album_name_label = new Gtk.Label(album.name);
			album_name_label.justify = Gtk.Justification.LEFT;
			album_name_label.xalign = 0; // Align to left (or right for RTL)

			Pango.AttrList album_name_attrs = new Pango.AttrList();
			album_name_attrs.insert(Pango.attr_scale_new(1.4));
			album_name_label.attributes = album_name_attrs;

			favorite_button = new Koto.FlatIconButton("emblem-favorite-symbolic", Gtk.IconSize.MENU); // Create our favorite button
			play_button = new Koto.FlatIconButton("media-playback-start-symbolic", Gtk.IconSize.MENU); // Create our play icon

			pack_start(album_name_label, false, true, 0); // Add the album title and take up as much space as possible
			pack_end(favorite_button, false, false, 0); // Add favorite button to end of Album Header
			pack_end(play_button, false, false, 15); // Add play button to end of Album Header
		}
	}
}