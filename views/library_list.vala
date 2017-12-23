// This contains the code for our Library List view

namespace Koto {
	public class KotoLibraryListView : Gtk.Box {
		KotoList artist_list;
		Gtk.Box album_list;

		public KotoLibraryListView() {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
			vexpand = true;

			artist_list = new KotoList(250); // Create a new KotoList for artists
			Gtk.ScrolledWindow album_list_scrollwindow = new Gtk.ScrolledWindow(null, null); // Create a new scrolled window
			album_list_scrollwindow.overlay_scrolling = true;
			album_list_scrollwindow.hscrollbar_policy = Gtk.PolicyType.NEVER; // Never have a horizontal scrollbar
			album_list_scrollwindow.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC; // Only appear when needed

			album_list = new Gtk.Box(Gtk.Orientation.VERTICAL, 15); // Create a new vertical list of albums
			album_list_scrollwindow.add(album_list); // Add our album_list to the scrolled window

			pack_start(artist_list, false, false, 0);
			pack_start(album_list_scrollwindow, true, true, 0);

			if (Koto.kotodb.data.keys.size > 0) { // If there are items to load
				refresh();
			}

			artist_list.click_item.connect(on_artist_click);
		}

		// on_artist_click will handle when we click on an item in the artist list
		public void on_artist_click(KotoTextListItem item) {
			string artist = item.text;
			album_list.hide(); // Hide the album list

			foreach (var album_list_item in album_list.get_children()) { // For each child
				album_list_item.destroy();
			}

			foreach (KotoAlbum album in Koto.kotodb.data[artist].albums.values) {
				KotoAlbumItem album_item = new KotoAlbumItem(album); // Create a new album item
				album_list.pack_start(album_item, false, true, 0); // Add item
			}

			album_list.show_all(); // Show the album list and its contents
		}

		// propagate will do a refresh of the list view
		public void refresh() {
			foreach (string artist in Koto.kotodb.data.keys) { // For each artist
				artist_list.add_with_string(artist);
			}
		}
	}
}