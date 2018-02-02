// This file contains the code related to the playback controls

namespace Koto {
	public class PlayerBar : Gtk.Box {
		private bool _user_seeking = false;

		// Left Side Controls
		public FlatIconButton backward;
		public FlatIconButton playpause;
		public FlatIconButton forward;

		// Middle Controls
		public Gtk.Scale progressbar;

		// Right Side Controls
		public FlatIconButton repeat;
		public FlatIconButton shuffle;
		public FlatIconButton playlist;
		public Gtk.VolumeButton volume; 

		public PlayerBar() {
			Object(orientation: Gtk.Orientation.HORIZONTAL);

			// Have the playerbar look the same as the CSD / titlebar
			get_style_context().add_class("csd");
			get_style_context().add_class("titlebar");

			// Create all our controls
			backward = new FlatIconButton("media-skip-backward-symbolic", 22);
			forward = new FlatIconButton("media-skip-forward-symbolic", 22);

			playpause = new FlatIconButton("media-playback-start-symbolic", 22); // Default to Play button
			playpause.width_request = 26; // Set to a width larger than our default, since our pause button is set to 24 instead of 22 and we don't want it shifting around

			progressbar = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL, 0, 120, 1); // Default to a GTK Scale with a minimum of zero and max of 120, with increments of 1. This will be changed on media load
			progressbar.set_draw_value(false); // Don't draw the value next to the bar
			progressbar.set_digits(0); // Default to 0
			progressbar.set_increments(1,1);

			repeat = new FlatIconButton("media-playlist-repeat-symbolic", 22);
			shuffle = new FlatIconButton("media-playlist-shuffle-symbolic", 22);
			playlist = new FlatIconButton("emblem-favorite-symbolic", 22);
			volume = new Gtk.VolumeButton();
			volume.use_symbolic = true; // Ensure we use the symbolic icon

			// Add all the controls
			var left_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10); // Create Left Controls section
			left_controls.margin_top = 10;
			left_controls.margin_bottom = 10;
			left_controls.margin_left = 15;
			left_controls.margin_right = 15;

			left_controls.pack_start(backward, false, false, 0); // Add backward button to Left controls
			left_controls.pack_start(playpause, false, false, 0); // Add playpause button to Left controls
			left_controls.pack_start(forward, false, false, 0); // Add forward button to Left controls

			var middle_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0); // Create our Middle Controls section
			middle_controls.pack_start(progressbar, true, true, 0); // Add our progressbar as the center width

			var right_controls = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10); // Create our Right Controls section
			right_controls.margin_top = 10;
			right_controls.margin_bottom = 10;
			right_controls.margin_left = 15;
			right_controls.margin_right = 15;

			right_controls.pack_start(repeat, false, false, 0); // Add repeat button to Right controls
			right_controls.pack_start(shuffle, false, false, 0); // Add shuffle button to Right controls
			right_controls.pack_start(playlist, false, false, 0); // Add playlist button to Right controls
			right_controls.pack_start(volume, false, false, 0); // Add volume volumebutton to Right controls

			pack_start(left_controls, false, false, 0); // Add Left Controls
			pack_start(middle_controls, true, true, 0); // Add Middle Controls and ensure it sits in center
			pack_start(right_controls, false, false, 0); // Add Right Controls

			// Add event listeners

			backward.clicked.connect(on_previous_track);
			forward.clicked.connect(on_next_track);
			playpause.clicked.connect(on_toggle_playback);
			progressbar.button_press_event.connect(on_progressbar_press);
			progressbar.button_release_event.connect(on_progressbar_release);
			progressbar.value_changed.connect(on_progressbar_move);
			volume.value_changed.connect(on_change_volume);

			// Add Playback Engine Event Handling
			Koto.playback.position_changed.connect(on_player_position_updated); // On position_updated, trigger on_player_position_updated
			Koto.playback.state_changed.connect(on_player_state_change); // On Player State change, call on_player_state_change

			// Add Playlist Event Handling

			Koto.playback.playlist.track_changed.connect((track) => { // If the Playlist changes track
				backward.sensitive = !Koto.playback.playlist.on_first_track; // Set backward button sensitivity to whether or not we're on first track
				forward.sensitive = !Koto.playback.playlist.on_last_track; // Set forward button sensitivity to whether or not we're on last track
			});
		}

		// enabled will return if the PlayerBar is enabled
		private bool _enabled = false;
		public bool enabled {
			get { return _enabled; }
		}

		// Enable the PlayerBar
		public void enable() {
			if (!_enabled) { // If the PlayerBar is not already enabled, set a limited set of controls to sensitive
				_enabled = true;
				volume.value = 0.5; // Set in the middle after enabling

				foreach (Gtk.Widget widget in get_children()){
					widget.sensitive = true;
				}

				shuffle.sensitive = false; // Set shuffle to not be sensitive immediately, since it'll only be used for playlists
			}
		}

		// Disable the PlayerBar
		public void disable() {
			_enabled = false;

			foreach (Gtk.Widget widget in get_children()){
				widget.sensitive = false;
			}
		}

		// This function will attempt to reset our progressbar
		public void reset_progressbar() {
			Koto.app.playerbar.progressbar.set_value(0);
			Koto.app.playerbar.progressbar.set_range(0,0);
			Koto.app.playerbar.queue_draw(); // Redraw
		}

		// on_change_volume will handle the value change on our VolumeButton scale
		public void on_change_volume(double volume) {
			Koto.playback.playbin.mute = (volume == 0);
			Koto.playback.playbin.volume = volume;
		}

		// on_next_track will handle the clicking of the forward button
		public void on_next_track() {
			Koto.playback.playlist.next_track(); // Go to next track
		}

		// on_previous_track will handle the clicking of the backward button
		public void on_previous_track() {
			Koto.playback.playlist.previous_track(); // Go to previous track
		}

		// on_progressbar_move will handle the changing of the progressbar value
		public void on_progressbar_move() {
			if (_user_seeking) { // If the Playback Engine has been instructed not to update the value, meaning this is a user change
				var new_value = Math.floor(progressbar.get_value());
				Koto.playback.seek((int64) new_value * Koto.PlaybackEngine.NS);
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
			Koto.playback.play();

			return false;
		}

		// on_player_position_updated is responsible for updating the current track position
		public void on_player_position_updated(double pos) {
			if (!_user_seeking) { // If we're allowed to update the progress bar and we're playing content
				progressbar.set_value(pos); // Set the current position
			}
		}

		public void on_player_state_change(Gst.State state) {
			enable(); // Enable our playerbar (if it isn't enabled already)

			if (state == Gst.State.PLAYING) { // If we're currently playing
				playpause.set_icon("media-playback-pause-symbolic", 24); // Change icon to pause since that is the intended future action (have icon size be slightly larger, looks off otherwise)
			} else if ((state == Gst.State.PAUSED) || (state == Gst.State.NULL)) { // If we're currently paused, stopped, or ready to play
				playpause.set_icon("media-playback-start-symbolic", null); // Change icon to start / play since that is the intended future action
			}
		}

		public void on_toggle_playback() {
			Gst.State current_state;
			Koto.playback.playbin.get_state(out current_state, null, 0);

			if (current_state == Gst.State.PLAYING) { // If we're currently playing
				Koto.playback.pause(); // Set to pause
			} else { // If we're currently paused
				Koto.playback.play(); // Set to playing
			}
		}
	}
}