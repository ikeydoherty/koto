// This contains the code for our HeaderBar control

public class KotoHeaderBar : Gtk.HeaderBar {
	public Gtk.Button menu_button;

	public KotoHeaderBar() {
		// Set HeaderBar attributes
		title = "Koto";
		subtitle = "Secret thing goes here.";
		show_close_button = true;

		// Create HeaderBar Objects
		menu_button = new Gtk.Button.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU); // Create our Menu button
		pack_end(this.menu_button);
	}
}