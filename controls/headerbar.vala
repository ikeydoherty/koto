namespace Koto {
	// KotoHeaderBar is our custom HeaderBar control
	public class KotoHeaderBar : Gtk.HeaderBar {
		private FlatIconButton menu_button;
		public FlatIconButton toggle_view_button;

		public KotoHeaderBar() {
			// Set HeaderBar attributes
			title = "Koto";
			subtitle = "Secret thing goes here.";
			show_close_button = true;

			// Create HeaderBar Objects
			menu_button = new FlatIconButton("audio-headphones-symbolic", 16); // Create our Menu button. Temporarily use audio-headphones-symbolic as the logo
			menu_button.margin_left = 10;

			toggle_view_button = new FlatIconButton("view-list-symbolic", 16); // Create our toggle-view button
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
				toggle_view_button.set_icon("view-" + app.current_library_view + "-symbolic", null); // Update the symbolic (with no change in size)
				toggle_view_button.tooltip_text = (app.current_library_view == "list") ? _("List View") : _("Grid View");
			});
		}
	}
}