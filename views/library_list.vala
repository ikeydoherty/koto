// This contains the code for our Library List view

namespace Koto {
	public class KotoLibraryListView : Gtk.Box {
		Gtk.ListBox artist_list;
		Gtk.ListBox album_list;

		public KotoLibraryListView() {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
			vexpand = true;
			artist_list = new Gtk.ListBox();
			artist_list.selection_mode = Gtk.SelectionMode.SINGLE; // Only allow one item to be selected

			artist_list.set_sort_func((row1, row2) => {
				var row1_text = ((Gtk.Label)row1.get_child()).label;
				var row2_text = ((Gtk.Label) row2.get_child()).label;
				return (strcmp(row1_text, row2_text) <= 0) ? -1 : 1;
			});

			artist_list.hexpand = false;
			artist_list.vexpand = false;
			artist_list.width_request = 200;

			var artist_scrollcontainer = new Gtk.ScrolledWindow(null, null);
			artist_scrollcontainer.hscrollbar_policy = Gtk.PolicyType.NEVER; // Never have a horizontal scrollbar
			artist_scrollcontainer.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC; // Only appear when needed
			artist_scrollcontainer.add(artist_list); // Add the artist list

			pack_start(artist_scrollcontainer, false, false, 0);

			if (Koto.kotodb.data.keys.size > 0) { // If there are items to load
				refresh();
			}
		}

		// propagate will do a refresh of the list view
		public void refresh() {
			foreach (string artist in Koto.kotodb.data.keys) { // For each artist
				add_artist(artist);
			}
		}

		// add_artist will create KotoTextListItem and add it to our artist list
		public void add_artist(string artist) {
			var list_item = new KotoTextListItem(artist);
			artist_list.insert(list_item, -1); // Append to end of list since I'd rather we push to end then move to the right position on re-order than show it at the top then possibly hide it from view
			artist_list.invalidate_sort();
		}
	}
}