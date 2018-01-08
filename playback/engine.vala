// This file contains our Koto Playback Engine for playback of media

namespace Koto {
	public class PlaybackEngine {
		public dynamic Gst.Element audio;
		public Koto.Playlist playlist; // Our Playlist
		public dynamic Gst.Pipeline player;
		public dynamic Gst.Element playbin;
		public Gst.Bus player_monitor;

		private double current_position;
		private bool is_playing;
		private bool requesting_play;
		
		public const int64 NS = 1000000000;

		// Signals
		public signal void position_changed(double current_position);
		public signal void state_changed(Gst.State new_state);

		public PlaybackEngine() {
			player = new Gst.Pipeline("player");
			playbin = Gst.ElementFactory.make("playbin", "play"); // Create a new player
			audio = Gst.ElementFactory.make("autoaudiosink", "sink");
			Gst.Element suppress_video = Gst.ElementFactory.make("fakesink", "suppress-video");

			playbin.audio_sink = audio;
			playbin.video_sink = suppress_video; // Try suppressing video
			playbin.volume = 0.5; // Set a default volume
			player.add(playbin); // Add our playbin to the pipeline

			player_monitor = new Gst.Bus(); // Create a bus
			player_monitor.add_watch(0, bus_message_handler); // Add our bus message handler to our player monitor
			playbin.set_bus(player_monitor); // Set our playbin bus to the monitor

			playlist = new Koto.Playlist(null); // Create a new Playlist
			playlist.track_changed.connect(load_file); // On the Playlist's track_changed, load the file
		}

		private bool bus_message_handler(Gst.Bus bus, Gst.Message message) {
			switch (message.type) {
				case Gst.MessageType.ASYNC_DONE: // If a state change is done
					if (requesting_play) {
						play();
					}
					break;
				case Gst.MessageType.STATE_CHANGED: // When it's done changing state
					Gst.State old_state;
					Gst. State new_state;
					message.parse_state_changed(out old_state, out new_state, null);

					is_playing = (new_state == Gst.State.PLAYING); // Update our is_playing for internal clock / progress usage

					if ((old_state == Gst.State.NULL) && (new_state == Gst.State.READY)) { // If we're ready to play
						update_duration(); // Update our duration info


					} else if (((old_state == Gst.State.NULL) || (old_state == Gst.State.PAUSED)) && (new_state == Gst.State.PLAYING)) { // If we're starting playback
						requesting_play = false; // No longer requesting play
						Timeout.add(50, update_progress, Priority.HIGH); // Create a new timeout that triggers every 50ms to update progress at high priority
					} else if (((old_state == Gst.State.PLAYING) || (old_state == Gst.State.PAUSED)) && (new_state == Gst.State.NULL)) { // If we're freeing resources
						Koto.app.playerbar.reset_progressbar(); // Reset our progressbar
						player_monitor.post(new Gst.Message.reset_time(playbin, 0));
					}

					state_changed(new_state); // Send the state_changed signal with this state
					break;
				case Gst.MessageType.EOS: // If we reached the end of the file
					if (!playlist.on_last_track) { // If we're not on the last track
						playlist.next_track(); // Go to the next track
					} else {
						Koto.app.header.subtitle = "Secret thing goes here."; // Reset headerbar subtitle
					}
					break;
				case Gst.MessageType.ERROR: // If there was an error
					GLib.Error error;
					string debug_info;
					message.parse_error(out error, out debug_info);

					stdout.printf("An error has occured during playback: %s\n", error.message);
					break;
			}

			return true;
		}

		// update_duration will attempt to fetch and update our duration info
		private void update_duration() {
			int64 current_duration = 0;

			if (playbin.query_duration(Gst.Format.TIME, out current_duration)) { // If we successfully fetched duration
				double track_duration = (current_duration / NS); // Get the total number of seconds for the track, which is the duration (in nanoseconds) divided by 1 billion

				if (track_duration > 0) { // If we have valid times
					Koto.app.playerbar.reset_progressbar(); // Reset our progressbar
					Koto.app.playerbar.progressbar.set_range(0, track_duration); // Set the new range from 0 to the duration of the track
				}
			}
		}

		// update_progress is our timeout function for triggering position changes
		private bool update_progress() {
			if (is_playing) { // If we're playing
				int64 current_pos = 0;

				if (audio.query_position(Gst.Format.TIME, out current_pos)) { // If we successfully fetched the current position
					double new_position = (current_pos / NS); // Get the total number of seconds in our current position

					if (new_position != current_position) { // If the new position is different from the old
						current_position = new_position;
						position_changed(new_position);
					}
				} else {
					current_position = 0;
					position_changed(0);
				}

				return true;
			} else { // If we're not playing
				return false; // Stop triggering the timeout
			}
		}

		// load_file will load the respective track's file
		public void load_file(KotoTrack track) {
			try {
				stop(); // Free any resources
				playbin.set("uri", Gst.filename_to_uri(Uri.unescape_string(playlist.current_track.path))); // Set uri to the filename_to_uri, unescaped form of the KotoTrack path value and set it to the player.uri
				play();

				string artist = track.album->artist->name;
				string album_uri =  track.album->artwork_uri;

				var notification = new Koto.KotoNotification(artist, album_uri, track.title); // Create a new notification
				notification.show();

				Koto.app.header.subtitle = "%s - %s".printf(track.title, artist);
			} catch (Error e) {
				stdout.printf("Failed to convert filename to uri with Gst: %s\n", e.message);
			}
		}

		// start_playlist will start the playback of the playlist
		public void start_playlist() {
			KotoTrack track = playlist.get_first_track(); // Get the first track
			playlist.change_track(track); // "Change" to the first track
		}

		// play will attempt to start playing any current source
		public void play() {
			requesting_play = true;
			playbin.set_state(Gst.State.PLAYING);
		}

		// pause will attempt to pause any current playing source
		public void pause() {
			playbin.set_state(Gst.State.PAUSED);
		}

		// seek will attempt to seek to the designated timestamp
		public void seek(int64 timestamp) {
			player.seek_simple(Gst.Format.TIME, Gst.SeekFlags.FLUSH, timestamp);
		}

		// stop will attempt to stop / reset our playbin
		public void stop() {
			playbin.set_state(Gst.State.NULL);
			Gst.Pad audio_pad = audio.get_static_pad("sink");
			audio_pad.offset = 0; // Reset offset
		}
	} 
}