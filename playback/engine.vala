// This file contains our Koto Playback Engine for playback of media

namespace Koto {
	public class PlaybackEngine {
		private bool _playing; // Playback is occurring
		private string _file_uri; // Our file URI
		public Gee.ArrayList<KotoTrack> playlist; // A list of KotoTracks to play
		public Gst.Player player;

		public PlaybackEngine(string? e_file_uri) {
			player = new Gst.Player(null, null); // Create a new player

			if (e_file_uri != null) {
				file_uri = e_file_uri;
				load_file_uri();
			}
		}

		// file_uri is our getter / setter for changing or setting the file_uri
		public string file_uri {
			get { return _file_uri; }
			set {
				try {
					_file_uri = Gst.filename_to_uri(Uri.unescape_string(value));
				} catch (Error e) {
					stdout.printf("Failed to convert filename to uri with Gst: %s\n", e.message);
				}
			}
		}

		public bool playing {
			get { return _playing; }
		}

		// load_file_uri will load our file URI 
		public void load_file_uri() {
			if (_file_uri != "") { // If we have a file_uri set
				player.uri = _file_uri; // Change our player uri
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