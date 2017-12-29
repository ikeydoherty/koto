// This file contains our Koto Playback Engine for playback of media

namespace Koto {
	public class PlaybackEngine {
		private string _file_uri; // Our file URI
		private Gst.Element source;

		public PlaybackEngine(string? e_file_uri) {
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

		public bool get_is_playing() {
			Gst.State current_state;
			source.get_state(out current_state, null, Gst.CLOCK_TIME_NONE);

			return current_state == Gst.State.PLAYING;
		}

		// load_file_uri will load our file URI 
		public void load_file_uri() {
			if (_file_uri != "") { // If we have a file_uri set
				if (source != null) { // If source is already set
					source.set_state(Gst.State.NULL);
				}

				source = Gst.ElementFactory.make("playbin", "source");
				source.set("uri", file_uri);
			} else {
				stdout.printf("No file_uri set during load_file_uri call.\n");
			}
		}

		// Start playback of the current source
		public void play() {
			if (source != null) {
				Gst.StateChangeReturn state_change = source.set_state(Gst.State.PLAYING);

				if (state_change == Gst.StateChangeReturn.FAILURE) {
					stdout.printf("Failed to start playing audio.\n");
				}
			} else {
				stdout.printf("Source is null.\n");
			}
		}

		// Pause playback of current source
		public void pause() {
			if (source != null) {
				Gst.StateChangeReturn state_change = source.set_state(Gst.State.PAUSED);

				if (state_change == Gst.StateChangeReturn.FAILURE) {
					stdout.printf("Failed to pause audio.\n");
				}
			}
		}
	} 
}