// This file contains functionality for the creation and management of notifications

namespace Koto {
	public class KotoNotification : Notify.Notification {
		public KotoNotification(string artist, string? album_art_uri, string track_title) {
			Object(summary:track_title, body: "%s - %s".printf(artist, track_title), icon_name: "audio-headphones-symbolic"); // Set the title to track title, notification body to artist - track title, default to audio-headphones-symbolic icon
			id = 0; // Set a non-unique ID
			set_app_name("Koto");
			set_artwork(album_art_uri);
			set_category("x-gnome.music"); // Piggyback off x-gnome.music for now
		}

		// set_artwork will set our artwork or reset to audio-headphones-symbolic
		public void set_artwork(string file_uri) {
			if ((file_uri != null) && (file_uri.has_prefix(Path.DIR_SEPARATOR_S))) {
				try {
					Gdk.Pixbuf artwork_pixbuf = new Gdk.Pixbuf.from_file_at_scale(file_uri, 64, 64, true); // Use a Gdk.Pixbuf so we can scale the image up / down depending on its size
					set_image_from_pixbuf(artwork_pixbuf); // Set our notification image to the pixbuf
				} catch (Error e) {
					icon_name = "audio-headphones-symbolic";
				}
			} else {
				icon_name = "audio-headphones-symbolic";
			}
		}
	}
}