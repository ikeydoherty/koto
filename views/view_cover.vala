// This contains the code for our Cover view of this secret app

public class KotoCoverView : Gtk.Box {
	public Gtk.FlowBox flow;

	public KotoCoverView() {
		Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
		this.flow = new Gtk.FlowBox();
		pack_start(flow, true, true, 0); // Ensure flow covers the entire box
	}
}