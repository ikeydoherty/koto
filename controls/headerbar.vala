namespace Koto {
	// KotoHeaderBar is our custom HeaderBar control
	public class KotoHeaderBar : Gtk.HeaderBar {
		private KotoFlatIconButton menu_button;
		public KotoFlatIconButton toggle_view_button;

		public KotoHeaderBar() {
			// Set HeaderBar attributes
			title = "Koto";
			subtitle = "Secret thing goes here.";
			show_close_button = true;

			// Create HeaderBar Objects
			menu_button = new KotoFlatIconButton("audio-headphones-symbolic", Gtk.IconSize.MENU); // Create our Menu button. Temporarily use audio-headphones-symbolic as the logo
			toggle_view_button = new KotoFlatIconButton("view-list-symbolic", Gtk.IconSize.MENU); // Create our toggle-view button
			toggle_view_button.tooltip_text = _("List View");
			pack_start(menu_button);
			pack_end(toggle_view_button);

			menu_button.clicked.connect(() => { // On button click
				app.menu_popover.relative_to = this.menu_button;
				app.menu_popover.popdown(); // Show the Popover, have it appear from the top
				app.menu_popover.show();
			});

			toggle_view_button.clicked.connect(() => { // On Toggle View click
				app.toggle_library_view(); // Toggle our current view
				toggle_view_button.set_icon("view-" + app.current_library_view + "-symbolic"); // Update the symbolic
				toggle_view_button.tooltip_text = (app.current_library_view == "list") ? _("List View") : _("Grid View");
			});
		}
	}
}