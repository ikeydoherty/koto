// This contains the code for our Library Grid view

namespace Koto {
	public class KotoLibraryGridView : Gtk.Box {
		public Gtk.FlowBox flow;

		public KotoLibraryGridView() {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
			this.flow = new Gtk.FlowBox();
			pack_start(flow, true, true, 0); // Ensure flow covers the entire box
		}
	}
}