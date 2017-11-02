public class Koto : Gtk.Window {
	public KotoHeaderBar header;
	public KotoMenuPopover menu_popover;

	public Gtk.Box container;
	public Gtk.Stack views;

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

		header = new KotoHeaderBar();
		menu_popover = new KotoMenuPopover(header.menu_button);
		container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		views = create_views(); // Create our views
		container.pack_start(views, true, true, 0);

		set_titlebar(header);
		add(container);

		header.menu_button.clicked.connect(() => { // On button click
			menu_popover.popdown(); // Show the Popover, have it appear from the top
			menu_popover.show();
		});

		destroy.connect(method_destroy);
		show_all();
	}

	// create_views is responsible for the creation of our Gtk.Stack
	Gtk.Stack create_views() {
		Gtk.Stack stack =  new Gtk.Stack();
		var list_view = new KotoListView();
		var cover_view = new KotoCoverView();

		stack.set_transition_duration(250); // 250ms
		stack.set_transition_type(Gtk.StackTransitionType.OVER_LEFT_RIGHT);
		stack.add_named(list_view, "list");
		stack.add_named(cover_view, "cover");
		stack.set_visible_child_name("list");

		return stack;
	}

	// method_destroy will handle our destroy method
	void method_destroy() {
		Gtk.main_quit();
	}
}