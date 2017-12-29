// Track Item is an individual item for Koto Tracks in an album view

namespace Koto {
	public class TrackItem : Gtk.Box {
		public Gtk.Label item_label;
		public KotoTrack track;

		public TrackItem(KotoTrack i_track) {
			Object(orientation : Gtk.Orientation.HORIZONTAL, spacing: 0);

			track = i_track;
			width_request = 150; // Set minimum width to 150

			item_label = new Gtk.Label(track.title); // Create a new Label
			item_label.justify = Gtk.Justification.LEFT;
			item_label.xalign = 0; // Align to left (or right for RTL)

			pack_start(item_label, false, true, 0);
		}
	}
}