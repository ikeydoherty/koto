// KotoList is our basic scrollable List

public class KotoList : Gtk.ScrolledWindow {
	public signal void click_item(KotoTextListItem item);
	public Gtk.ListBox list;
	private int list_width;

	public KotoList(int? width) {
		Object();
		overlay_scrolling = true; // Enable overlay scrolling
		hscrollbar_policy = Gtk.PolicyType.NEVER; // Never have a horizontal scrollbar
		vscrollbar_policy = Gtk.PolicyType.AUTOMATIC; // Only appear when needed

		list = new Gtk.ListBox();
		list.activate_on_single_click = true;
		list.selection_mode = Gtk.SelectionMode.SINGLE; // Only allow one item to be selected
		list.hexpand = false;
		list.vexpand = false;

		if (width != null) { // If a width is defined
			list_width = width;
			list.width_request = width;
		}

		list.row_selected.connect((item) => {
			var kotoListItem = (KotoTextListItem) item;
			
			if (kotoListItem != null) {
				click_item(kotoListItem);
			}
			return;
		});

		list.set_sort_func((row1, row2) => { // Alphabetize items
			var row1_text = ((Gtk.Label) row1.get_child()).label;
			var row2_text = ((Gtk.Label) row2.get_child()).label;
			return (strcmp(row1_text, row2_text) <= 0) ? -1 : 1;
		});

		add(list);
	}

	// add_with_string will create a new KotoTextListItem and add it to our list
	public void add_with_string(string label) {
		var list_item = new KotoTextListItem(label); // Create the list item
		add_item(list_item); // Add the item
	}

	// add_item will add a KotoTextListItem to our list and re-sort
	public void add_item(KotoTextListItem item) {
		list.insert(item, -1); // Append to end of list since I'd rather we push to end then move to the right position on re-order than show it at the top then possibly hide it from view
		list.invalidate_sort();
	}

	// empty will clear our ListBox of all items
	public void empty() {
		foreach (var item in list.get_children()) { // For each child
			item.destroy();
		}
	}
}