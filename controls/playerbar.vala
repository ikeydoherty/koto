// This file contains the code related to the playback controls

namespace Koto {
	public class PlayerBar : Gtk.Box {
		private bool _enabled;
		private bool _user_seeking;

		// Left Side Controls
		public KotoFlatIconButton backward;
		public KotoFlatIconButton playpause;
		public KotoFlatIconButton forward;

		// Middle Controls
		public Gtk.Scale progressbar;

		// Right Side Controls
		public KotoFlatIconButton repeat;
		public KotoFlatIconButton shuffle;
		public KotoFlatIconButton playlist;
		public Gtk.VolumeButton volume; 

		public PlayerBar() {
			Object(orientation: Gtk.Orientation.HORIZONTAL);
			_enabled = false; // Default to PlayerBar not being enabled
			_user_seeking = false; // D efault to allowing progressbar updating

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
			progressbar.set_increments(1,1);

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

			var right_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10); // Create our Right Controls section
			right_controls.margin_left = 10;
			right_controls.margin_right = 10;

			right_controls.pack_start(repeat, false, false, 0); // Add repeat button to Right controls
			right_controls.pack_start(shuffle, false, false, 0); // Add shuffle button to Right controls
			right_controls.pack_start(playlist, false, false, 0); // Add playlist button to Right controls
			right_controls.pack_start(volume, false, false, 0); // Add volume volumebutton to Right controls

			pack_start(left_controls, false, false, 0); // Add Left Controls
			pack_start(middle_controls, true, true, 0); // Add Middle Controls and ensure it sits in center
			pack_start(right_controls, false, false, 0); // Add Right Controls

			// Add event listeners
			playpause.clicked.connect(on_toggle_playback);
			progressbar.button_press_event.connect(on_progressbar_press);
			progressbar.button_release_event.connect(on_progressbar_release);
			progressbar.value_changed.connect(on_progressbar_move);
			volume.value_changed.connect(on_change_volume);
		}

		// enabled will return if the PlayerBar is enabled
		public bool enabled {
			get { return _enabled; }
		}

		// user_seeking will return if the PlayerBar progressbar is currently being seeked by the user
		public bool user_seeking {
			get { return _user_seeking; }
		}

		// Enable the PlayerBar
		public void enable() {
			if (!enabled) { // If the PlayerBar is not already enabled
				_enabled = true;

				foreach (Gtk.Widget widget in get_children()){
					widget.sensitive = true;
				}
			}
		}

		// Disable the PlayerBar
		public void disable() {
			_enabled = false;

			foreach (Gtk.Widget widget in get_children()){
				widget.sensitive = false;
			}
		}

		// on_change_volume will handle the value change on our VolumeButton scale
		public void on_change_volume(double volume) {
			Koto.playback.player.mute = (volume == 0);
			Koto.playback.player.volume = volume;
		}

		// on_progressbar_move will handle the changing of the progressbar value
		public void on_progressbar_move() {
			if (_user_seeking) { // If the Playback Engine has been instructed not to update the value, meaning this is a user change
				var new_value = Math.floor(progressbar.get_value());
				Koto.playback.player.seek(((uint64) new_value * 1000000000)); // Seek to the new position, which is the number of seconds in the new_value * nanoseconds
			}
		}

		// on_progressbar_press will handle our press event
		public bool on_progressbar_press(Gdk.EventButton e) {
			_user_seeking = true; // Should not allow updating by Playback Engine

			return false;
		}

		// on_progressbar_release will handle our release event
		public bool on_progressbar_release(Gdk.EventButton e) {
			_user_seeking = false; // Should allow updating by Playback Engine

			return false;
		}

		public void on_toggle_playback() {
			if (Koto.playback.playing) { // If we are playing media
				Koto.playback.pause(); // Pause media
				playpause.set_icon("media-playback-pause-symbolic"); // Change icon to pause
			} else {
				Koto.playback.play(); // Play media (if possible)
				playpause.set_icon("media-playback-start-symbolic"); // Change icon to play
			}
		}
	}
}