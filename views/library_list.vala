// This contains the code for our Library List view

namespace Koto {
	public class KotoLibraryListView : Gtk.Box {
		KotoList artist_list;
		Gtk.Box album_list;

		public KotoLibraryListView() {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
			vexpand = true;

			artist_list = new KotoList(250); // Create a new KotoList for artists
			album_list = new Gtk.Box(Gtk.Orientation.VERTICAL, 15); // Create a new vertical list of albums

			pack_start(artist_list, false, false, 0);
			pack_start(album_list, false, true, 0);

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