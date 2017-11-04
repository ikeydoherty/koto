// This contains the code for our HeaderBar control

public class KotoHeaderBar : Gtk.HeaderBar {
	private Gtk.Button menu_button;

	public KotoHeaderBar(Koto app) {
		// Set HeaderBar attributes
		title = "Koto";
		subtitle = "Secret thing goes here.";
		show_close_button = true;

		// Create HeaderBar Objects
		menu_button = new Gtk.Button.from_icon_name("open-menu-symbolic", Gtk.IconSize.MENU); // Create our Menu button
		pack_end(this.menu_button);

		menu_button.clicked.connect(() => { // On button click
			app.menu_popover.relative_to = this.menu_button;
			app.menu_popover.popdown(); // Show the Popover, have it appear from the top
			app.menu_popover.show();
		});
	}
}