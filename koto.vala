public class Koto : Gtk.Window {
	public Gtk.HeaderBar header;

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
		this.set_default_size(800,600); // Set a default of 800px width by 600 height
		this.title = "Koto";

		this.header = create_headerbar();
		var container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		this.set_titlebar(header);
		this.add(container);

		this.destroy.connect(method_destroy);
	}

	// create_headerbar is responsible for the creation of our Gtk.HeaderBar
	Gtk.HeaderBar create_headerbar() {
		Gtk.HeaderBar bar = new Gtk.HeaderBar();
		bar.title = "Koto";
		bar.subtitle = "Secret thing goes here.";
		bar.show_close_button = true;

		return bar;
	}

	// method_destroy will handle our destroy method
	void method_destroy() {
		Gtk.main_quit();
	}
}