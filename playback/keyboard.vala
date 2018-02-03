// This file contains our keyboard support leveraging GNOME SettingsDaemon Media Keys API

namespace Koto {

	/**
	 * Create SettingsDaemon interface to use in our keyboard support class
	 */
	[DBus (name="org.gnome.SettingsDaemon.MediaKeys")]
	public interface MediaKeys : Object {
		public abstract void GrabMediaPlayerKeys(string app, uint32 time) throws GLib.IOError; // GrabMediaPlayerKeys is used to register the app with GNOME Settings Daemon
		public abstract void ReleaseMediaPlayerKeys() throws GLib.IOError;
		public signal void MediaPlayerKeyPressed(string app, string key); // MediaPlayerKeyPressed is the signal from SettingsDaemon on what media player key is pressed (pretty self-explanatory)
	}

	public class MediaKeyHandler {
		public Koto.MediaKeys ikeys;

		public MediaKeyHandler() {
			try {
				ikeys = Bus.get_proxy_sync(BusType.SESSION, "org.gnome.SettingsDaemon.MediaKeys", "/org/gnome/SettingsDaemon/MediaKeys"); // Get our settings daemon proxy
				ikeys.MediaPlayerKeyPressed.connect(handle_mediakey_input);

				try {
					ikeys.GrabMediaPlayerKeys("com.joshstrobl.koto", 0);
				} catch (IOError error) {
					stderr.printf("Failed to grab media keys. %s\n", error.message);
				}
			} catch (Error error) {
				stderr.printf("Failed to connect to GNOME Settings Daemon: %s\n", error.message);
				ikeys = null;
			}
		}

		/**
		 * Destruction of MediaKeyHandler
		 */
		~MediaKeyHandler() {
			if (ikeys != null) {
				ikeys.ReleaseMediaPlayerKeys();
			}
		}

		/**
		 * handle_mediakey_input will handle media key input
		 */
		public void handle_mediakey_input(string app, string key) {
			if (app != "com.joshstrobl.koto") { // If the app receiving the keys isn't koto
				return;
			}

			switch (key) {
				case "Play":
					Koto.playback.toggle();
					break;
				case "Pause":
					Koto.playback.toggle();
					break;
				case "Stop":
					Koto.playback.stop(); // Stop playback
					break;
				case "Previous":
					Koto.playback.playlist.previous_track(); // Go to previous track in playlist
					break;
				case "Next":
					Koto.playback.playlist.next_track(); // Go to next track in playlist
					break;
				default:
					break;
			}
		}

		/**
		 * refcous will attempt to re-grab media player keys
		 */
		public void refocus() {
			if (ikeys != null) {
				try {
					ikeys.GrabMediaPlayerKeys("koto", 0);
				} catch (IOError error) {
					stderr.printf("Failed to grab media keys. %s\n", error.message);
				}
			}
		}
	}
}
