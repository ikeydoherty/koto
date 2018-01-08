// KotoTextListItem is a GTK ListBoxRow with a label in it. I know, groundbreaking.

public class KotoTextListItem : Gtk.ListBoxRow {

	public KotoTextListItem(string list_text) {
		Object();
		string text = list_text.strip(); // Strip leading and trailing whitespace

		height_request = 40;
		_label = new Gtk.Label(text);
		_label.ellipsize = Pango.EllipsizeMode.END;
		_label.halign = Gtk.Align.START; // Align horizontally to the start of the item (left for LTR)
		_label.justify = Gtk.Justification.LEFT;
		_label.max_width_chars = 280; // Keey it at a maximum of 280px
		_label.xalign = 0; // Align to start (left for LTR, right for RTL)
		_label.xpad = 20; // 20px horizontal padding
		_text = text;

		this.add(label);
	}

	private Gtk.Label _label;
	public Gtk.Label label {
		get { return _label; }
		set {
			_label.label = value.label; // Only replace label
		}
	}

	private string _text;
	public string text {
		get { return _text; }
		set {
			_label.label = value;
		}
	}
}