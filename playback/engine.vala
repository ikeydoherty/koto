// This file contains our Koto Playback Engine for playback of media

namespace Koto {
	public class PlaybackEngine {
		private bool _playing; // Playback is occurring
		private KotoTrack _current_track; // The URI of the file we're currently playing back
		public Gee.ArrayList<KotoTrack> playlist; // A list of KotoTracks to play
		public Gst.Player player;

		public PlaybackEngine(KotoTrack? current_track) {
			player = new Gst.Player(null, null); // Create a new player
			player.set_video_track_enabled(false); // This isn't a video player, don't randomly spawn video tracks
			playlist = new Gee.ArrayList<KotoTrack>(); // Create a new playlist Array

			if (current_track != null) {
				track = current_track;
				load_file(track);
			}

			player.duration_changed.connect(on_duration_change); // On duration change, trigger on_duration_change
			player.uri_loaded.connect(on_file_load); // On media_info_updated, trigger update_current_track
			player.position_updated.connect(on_update_track_position); // On position_updated, trigger update_track_position
		}

		// track is our getter / setter for changing the track
		public KotoTrack track {
			get { return _current_track; }
			set {
				_current_track = value; // Set the _current_track to the KotoTrack provided
				playlist.clear(); // Clear the playlist if it exists since we're going to set it to only this track
				playlist.add(value);
			}
		}

		// add_track will add a track to our playlist
		public void add_track(KotoTrack track) {
			if (!playlist.contains(track)) { // If the playlist does not already contain this track
				playlist.add(track); // Append track to the playlist
			}
		}

		// remove_track will remove a track from our playlist
		public void remove_track(KotoTrack track) {
			if (playlist.contains(track)) { // If the playlist contains the track
				playlist.remove(track); // Remove the track
			}
		}

		// on_file_load will handle when our file is loaded and is responsible for updating any internal or UX info for the file
		public void on_file_load(string uri_loaded) {
			return;
		}

		// on_duration_change will handle if the file's duration change (like during file load)
		public void on_duration_change(uint64 duration) {
			uint64 track_duration = player.duration / 1000000000; // Get the total number of seconds for the track, which is the duration (in nanoseconds) divided by 1 billion
			uint64 current_position = player.position / 1000000000; // Get the current position in seconds, which is the position (in nanoseconds) divided by 1 billion

			Koto.app.playerbar.progressbar.set_range(0, track_duration); // Set the new range from 0 to the duration of the track
			Koto.app.playerbar.progressbar.set_value(current_position); // Set the current position
		}

		// on_update_track_position is responsible for updating the current track position
		public void on_update_track_position(uint64 pos) {
			if (!Koto.app.playerbar.user_seeking) { // If we're allowed to update the progress bar
				Koto.app.playerbar.progressbar.set_value(pos / 1000000000); // Set the current position (position in nanoseconds divided by a billion - to get seconds)
			}
		}

		public bool playing {
			get { return _playing; }
		}

		// load_file will load the respective track's file
		public void load_file(KotoTrack track) {
			try {
				player.uri = Gst.filename_to_uri(Uri.unescape_string(track.path)); // Set file_uri to the filename_to_uri, unescaped form of the KotoTrack path value and set it to the player.uri
			} catch (Error e) {
				stdout.printf("Failed to convert filename to uri with Gst: %s\n", e.message);
			}
		}

		// Start playback of the current source
		public void play() {
			_playing = true;
			player.play(); // Play file
			Koto.app.playerbar.enable(); // Enable our playerbar (if it isn't enabled already)
			Koto.app.playerbar.volume.value = player.volume; // Set the VolumeButton scale value to the player volume
		}

		// Pause playback of current source
		public void pause() {
			_playing = false;
			player.pause(); // Pause playback
		}
	} 
}