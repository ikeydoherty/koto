namespace Koto {
	public KotoApp app;
	public KotoDatabase kotodb;
	public KotoFileIO kotoio;

	public class KotoApp : Gtk.Window {
		public KotoHeaderBar header;
		public KotoMenuPopover menu_popover;
		public KotoPlayerBar playerbar;

		public Gtk.Stack global_views;
		public Gtk.Stack library_views;

		public string current_view;
		public string current_library_view;

		public static int main (string[] args) {
			if (!Thread.supported()) {
				error("Cannot run without Vala threading support.");
			}

			Gtk.init(ref args);
			app = new KotoApp();
			Gtk.main();
			return 0;
		}

		public KotoApp() {
			Object(
				icon_name: "audio-headphones", // Use audio-headphones for now
				startup_id: "koto",
				title: "Koto",
				type: Gtk.WindowType.TOPLEVEL,
				window_position: Gtk.WindowPosition.CENTER
			);

			kotoio = new KotoFileIO();

			// Create our basic GTK Application
			set_default_size(1000,600); // Set a default of 800px width by 600 height
			title = "Koto";
			current_view = "library"; // Default to library global view
			current_library_view = "list"; // Default to list view until we implement preferences

			header = new KotoHeaderBar(); // Create our Headerbar
			menu_popover = new KotoMenuPopover(); // Create our Menu Popover
			playerbar = new KotoPlayerBar(); // Create our Playerbar

			var global_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			var main_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var views_list = new KotoViewsList(); // Create our new Views List
			create_views(); // Create our views

			main_container.pack_start(views_list, false, false, 0); // Pack our views list
			main_container.pack_start(global_views, true, true, 0); // Pack our global views into main_container

			global_container.pack_start(main_container, true, true, 0); // Pack our main_container in global_container
			global_container.pack_start(playerbar, false, false, 0); // Pack our playerbar in global_container

			set_titlebar(header);
			add(global_container);

			destroy.connect(method_destroy);

			kotodb = new KotoDatabase(); // Create a new database

			if (kotodb.is_first_run) { // If this is our first run
				var getting_started = new KotoGettingStartedView();
				global_container.add(getting_started);

				// Only show what is absolutely necessary
				getting_started.show();
				header.show();
				global_container.show();
				show();
			} else {
				show_all();
				playerbar.Disable(); // Disable until we start playback
			}
		}

		// create_views is responsible for the creation of our Gtk.Stack
		public void create_views() {
			// Create our primary views
			global_views = new Gtk.Stack();
			library_views =  new Gtk.Stack();

			// Devices View
			var devices_view = new KotoDevicesView();

			// Library Container and Views
			var library_view_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			var library_list_view = new KotoLibraryListView(); // Construct our Library List View
			var library_grid_view = new KotoLibraryGridView(); // Construct our Library Grid View
			library_views.add_named(library_list_view, "list"); // Add List
			library_views.add_named(library_grid_view, "grid"); // Add Grid
			library_view_container.add(library_views); // Add the library stack to the container

			// Stacks Setting and Global Push
			global_views.set_transition_duration(250); // 250ms
			library_views.set_transition_duration(250); // 250ms
			global_views.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN); // Slide Up or Down based on current global view
			library_views.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT); // Slide Left or Right based on current library view

			global_views.add_named(library_view_container, "library"); // Have Library sit above Devices
			global_views.add_named(devices_view, "devices");
		}

		// Toggle Library View is responsible for toggling our current library view
		public void toggle_library_view() {
			if (current_view == "library") { // If our current global view is library
				current_library_view = (current_library_view == "list") ? "grid" : "list"; // Change List to Grid and vise-versa
				library_views.set_visible_child_name(current_library_view);
			}
		}

		// method_destroy will handle our destroy method
		void method_destroy() {
			Gtk.main_quit();
		}
	}
}