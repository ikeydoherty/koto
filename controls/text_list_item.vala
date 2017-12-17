// KotoTextListItem is a GTK ListBoxRow with a label in it. I know, groundbreaking.

public class KotoTextListItem : Gtk.ListBoxRow {
	private Gtk.Label _label;
	private string _text;

	public KotoTextListItem(string text) {
		Object();
		height_request = 40;
		width_request = 300;
		_label = new Gtk.Label(text);
		_label.ellipsize = Pango.EllipsizeMode.END;
		_label.halign = Gtk.Align.START; // Align horizontally to the start of the item (left for LTR)
		_label.justify = Gtk.Justification.LEFT;
		_label.max_width_chars = 280; // Keey it at a maximum of 280px
		_label.xpad = 20; // 20px horizontal padding

		this.add(label);
	}

	public Gtk.Label label {
		get { return _label; }
		set {
			_label.label = value.label; // Only replace label
		}
	}

	public string text {
		get { return _text; }
		set {
			_label.label = value;
		}
	}
}