public class Koto : Gtk.Window {
	public KotoHeaderBar header;
	public KotoMenuPopover menu_popover;
	public KotoPlayerBar playerbar;

	public Gtk.Box container;
	public Gtk.Stack views;

	public string current_view;

	public static int main (string[] args) {
		Gtk.init(ref args);
		Koto koto = new Koto();
		koto.show_all();
		Gtk.main();
		return 0;
	}

	public Koto() {
		Object(type: Gtk.WindowType.TOPLEVEL, window_position: Gtk.WindowPosition.CENTER);

		// Create our basic GTK Application
		set_default_size(800,600); // Set a default of 800px width by 600 height
		title = "Koto";
		current_view = "list"; // Default to list view until we implement preferences

		header = new KotoHeaderBar(this); // Create our Headerbar
		menu_popover = new KotoMenuPopover(); // Create our Menu Popover
		playerbar = new KotoPlayerBar(); // Create our Playerbar

		container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		views = create_views(); // Create our views
		container.pack_start(views, true, true, 0);
		container.pack_start(playerbar, false, false, 0);

		set_titlebar(header);
		add(container);

		destroy.connect(method_destroy);
		show_all();
	}

	// create_views is responsible for the creation of our Gtk.Stack
	Gtk.Stack create_views() {
		Gtk.Stack stack =  new Gtk.Stack();
		var list_view = new KotoListView();
		var grid_view = new KotoGridView();

		stack.set_transition_duration(250); // 250ms
		stack.set_transition_type(Gtk.StackTransitionType.OVER_LEFT_RIGHT);
		stack.add_named(list_view, "list");
		stack.add_named(grid_view, "grid");
		stack.set_visible_child_name(current_view);

		return stack;
	}

	// Toggle View is responsible for toggling our current view
	public void toggle_view() {
		current_view = (current_view == "list") ? "grid" : "list"; // Change List to Grid and vise-versa
		views.set_visible_child_name(current_view);
	}

	// method_destroy will handle our destroy method
	void method_destroy() {
		Gtk.main_quit();
	}
}