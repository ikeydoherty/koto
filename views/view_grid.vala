// This contains the code for our Grid view of this secret app

public class KotoGridView : Gtk.Box {
	public Gtk.FlowBox flow;

	public KotoGridView() {
		Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
		this.flow = new Gtk.FlowBox();
		pack_start(flow, true, true, 0); // Ensure flow covers the entire box
	}
}