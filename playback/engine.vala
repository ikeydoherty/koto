// This file contains our Koto Playback Engine for playback of media

namespace Koto {
	public class PlaybackEngine {
		public Koto.Playlist playlist; // Our Playlist
		public Gst.Player player;

		public PlaybackEngine() {
			player = new Gst.Player(null, null); // Create a new player
			player.set_video_track_enabled(false); // This isn't a video player, don't randomly spawn video tracks
			playlist = new Koto.Playlist(null); // Create a new Playlist

			playlist.track_changed.connect(load_file); // On the Playlist's track_changed, load the file

			player.duration_changed.connect(on_duration_change); // On duration change, trigger on_duration_change
			player.end_of_stream.connect(on_file_end); // On end_of_stream, trigger on_file_end
		}

		// on_duration_change will handle if the file's duration change (like during file load)
		public void on_duration_change(uint64 duration) {
			double track_duration = Math.floor(player.duration / 1000000000); // Get the total number of seconds for the track, which is the duration (in nanoseconds) divided by 1 billion

			if (track_duration > 0) { // If we have valid times 
				Koto.app.playerbar.progressbar.set_range(0, track_duration); // Set the new range from 0 to the duration of the track
			}
		}

		// on_file_end handles when we have reached the end of the file stream
		public void on_file_end() {
			playlist.next_track(); // Go to next track
		}

		// load_file will load the respective track's file
		public void load_file(KotoTrack track) {
			try {
				player.set_uri(Gst.filename_to_uri(Uri.unescape_string(playlist.current_track.path))); // Set file_uri to the filename_to_uri, unescaped form of the KotoTrack path value and set it to the player.uri
				player.play();
			} catch (Error e) {
				stdout.printf("Failed to convert filename to uri with Gst: %s\n", e.message);
			}
		}

		// start_playlist will start the playback of the playlist
		public void start_playlist() {
			KotoTrack track = playlist.get_first_track(); // Get the first track
			playlist.change_track(track); // "Change" to the first track
		}
	} 
}