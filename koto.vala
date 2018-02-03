namespace Koto {
	public KotoApp app;
	public KotoDatabase kotodb;
	public Koto.Utils utils;
	public MediaKeyHandler mediakeys;
	public Gtk.IconTheme icontheme;
	public PlaybackEngine playback;
	public string music_dir; // User Music Directory

	public class KotoAppMain : Gtk.Application {
		public KotoAppMain() {
			Object(application_id: "com.joshstrobl.koto", flags: ApplicationFlags.FLAGS_NONE);
		}

		protected override void activate() {
			app = new KotoApp(this);
		}

		public static int main(string[] args) {
			if (!Thread.supported()) {
				error("Cannot run without Vala threading support.");
			}

			Gst.init(ref args);

			KotoAppMain kotomain = new KotoAppMain();
			return kotomain.run(args);
		}
	}

	public class KotoApp : Gtk.ApplicationWindow {
		public KotoHeaderBar header;
		public KotoMenuPopover menu_popover;
		public PlayerBar playerbar;

		public Gtk.Box global_container;
		public Gtk.Box main_container;
		public Gtk.Stack global_views;

		public string current_view;

		public KotoGettingStartedView getting_started;
		public LibraryView library_view;

		public KotoApp(Gtk.Application gapp) {
			Object(
				application: gapp,
				icon_name: "audio-headphones", // Use audio-headphones for now
				startup_id: "com.joshstrobl.koto",
				title: "Koto",
				type: Gtk.WindowType.TOPLEVEL,
				window_position: Gtk.WindowPosition.CENTER
			);

			set_wmclass("Koto","com.joshstrobl.koto");

			utils = new Koto.Utils();
			playback = new Koto.PlaybackEngine();
			mediakeys = new Koto.MediaKeyHandler();

			Notify.init("Koto"); // Initialize Notify
			icontheme = new Gtk.IconTheme(); // Create a new IconTheme to load icons

			music_dir = Environment.get_user_special_dir(UserDirectory.MUSIC); // Get the user's Music directory, using XDG special user directories
			kotodb = new KotoDatabase(); // Create a new database

			// Create our basic GTK Application
			set_default_size(1000,600); // Set a default of 1000px width by 600 height
			title = "Koto";
			current_view = "library"; // Default to library global view

			header = new KotoHeaderBar(); // Create our Headerbar
			menu_popover = new KotoMenuPopover(); // Create our Menu Popover
			playerbar = new Koto.PlayerBar(); // Create our Playerbar

			global_container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			main_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			var views_list = new KotoViewsList(); // Create our new Views List
			create_views(); // Create our views

			main_container.pack_start(views_list, false, false, 0); // Pack our views list
			main_container.pack_start(global_views, true, true, 0); // Pack our global views into main_container

			global_container.pack_start(main_container, true, true, 0); // Pack our main_container in global_container
			global_container.pack_start(playerbar, false, false, 0); // Pack our playerbar in global_container

			set_titlebar(header);
			add(global_container);

			destroy.connect(method_destroy);

			playerbar.disable(); // Disable until we start playback

			if (kotodb.is_first_run) { // If this is our first run
				getting_started = new KotoGettingStartedView(); // Create the Getting Started view
				global_container.add(getting_started);

				// Only show what is absolutely necessary
				getting_started.show();
				header.show();
				global_container.show();
				show();
			} else {
				show_all();
			}
		}

		// create_views is responsible for the creation of our Gtk.Stack
		public void create_views() {
			// Create our primary views
			global_views = new Gtk.Stack();

			// Library Container and Views
			library_view = new LibraryView(); // Construct our Library View

			// Devices View
			var devices_view = new KotoDevicesView();

			// Stacks Setting and Global Push
			global_views.set_transition_duration(250); // 250ms
			global_views.set_transition_type(Gtk.StackTransitionType.SLIDE_UP_DOWN); // Slide Up or Down based on current global view

			global_views.add_named(library_view, "library"); // Have Library sit above Devices
			global_views.add_named(devices_view, "devices");
		}

		// method_destroy will handle our destroy method
		void method_destroy() {
			Koto.playback.stop(); // Set the state to null so it stops buffering any existing tracks and allows deinit
			Gst.deinit(); // Ensure we de-initialize Gst
		}
	}
}