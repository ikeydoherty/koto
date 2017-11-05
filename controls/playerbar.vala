// This file contains the code related to the playback controls

public class KotoPlayerBar : Gtk.Box {
	// Left Side Controls
	public Gtk.Button backward;
	public Gtk.Button playpause;
	public Gtk.Button forward;

	// Middle Controls
	public Gtk.Scale progressbar;

	// Right Side Controls
	public Gtk.Button repeat;
	public Gtk.Button shuffle;
	public Gtk.Button playlist;
	public Gtk.VolumeButton volume; 

	public KotoPlayerBar() {
		Object(orientation: Gtk.Orientation.HORIZONTAL);

		// Have the playerbar look the same as the CSD / titlebar
		get_style_context().add_class("csd");
		get_style_context().add_class("titlebar");

		// Create all our controls
		backward = new KotoFlatIconButton("media-skip-backward-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		playpause = new KotoFlatIconButton("media-playback-start-symbolic", Gtk.IconSize.SMALL_TOOLBAR); // Default to Play button
		forward = new KotoFlatIconButton("media-skip-forward-symbolic", Gtk.IconSize.SMALL_TOOLBAR);

		progressbar = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL, 0, 120, 1); // Default to a GTK Scale with a minimum of zero and max of 120, with increments of 1. This will be changed on media load
		progressbar.set_draw_value(false); // Don't draw the value next to the bar
		progressbar.set_digits(0); // Default to 0

		repeat = new KotoFlatIconButton("media-playlist-repeat-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		shuffle = new KotoFlatIconButton("media-playlist-shuffle-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		playlist = new KotoFlatIconButton("list-add-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
		volume = new Gtk.VolumeButton();
		volume.use_symbolic = true; // Ensure we use the symbolic icon

		// Add all the controls
		var left_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10); // Create Left Controls section
		left_controls.margin_top = 5;
		left_controls.margin_bottom = 5;
		left_controls.margin_left = 10;
		left_controls.margin_right = 10;

		left_controls.pack_start(backward, false, false, 0); // Add backward button to Left controls
		left_controls.pack_start(playpause, false, false, 0); // Add playpause button to Left controls
		left_controls.pack_start(forward, false, false, 0); // Add forward button to Left controls

		var middle_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0); // Create our Middle Controls section
		middle_controls.pack_start(progressbar, true, true, 0); // Add our progressbar as the center width

		var right_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0); // Create our Right Controls section
		right_controls.margin_left = 10;
		right_controls.margin_right = 10;

		right_controls.pack_start(repeat, false, false, 0); // Add repeat button to Right controls
		right_controls.pack_start(shuffle, false, false, 0); // Add shuffle button to Right controls
		right_controls.pack_start(playlist, false, false, 0); // Add playlist button to Right controls
		right_controls.pack_start(volume, false, false, 0); // Add volume volumebutton to Right controls

		pack_start(left_controls, false, false, 0); // Add Left Controls
		pack_start(middle_controls, true, true, 0); // Add Middle Controls and ensure it sits in center
		pack_start(right_controls, false, false, 0); // Add Right Controls
	}
}