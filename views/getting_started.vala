// This file contains the Getting Started view

namespace Koto {
	public int64 last_index_check;

	public class KotoGettingStartedView : Gtk.Box  {
		public Gtk.Button start_indexing;
		public Gtk.Button start_listening;
		public Gtk.ProgressBar progress;

		public KotoGettingStartedView() {
			Object(orientation: Gtk.Orientation.VERTICAL, spacing: 20);

			set_size_request(400, -1); // Maximum of 400px
			halign = Gtk.Align.CENTER; // Ensure we align in center of parent container
			valign = Gtk.Align.CENTER; // Ensure we align in center of parent container
			vexpand = true; // Expand as much as necessary

			Gtk.Label welcome_header = new Gtk.Label(_("Hello there!"));
			welcome_header.justify = Gtk.Justification.CENTER; // Center the welcome header
			welcome_header.get_style_context().add_class("title"); // Give it a title style

			Pango.AttrList header_attributes = new Pango.AttrList();
			header_attributes.insert(Pango.attr_scale_new(2));
			welcome_header.attributes = header_attributes;

			string welcome_message = "Looks like you have launched this for the first time.\nLet's crunch some numbers and index your audio files!";

			Gtk.Label welcome_info = new Gtk.Label(welcome_message);
			welcome_info.justify = Gtk.Justification.CENTER; // Center the text
			welcome_info.use_markup = true; // Use markup for new lines
			welcome_info.wrap_mode = Pango.WrapMode.WORD;

			Pango.AttrList info_attributes = new Pango.AttrList();
			info_attributes.insert(Pango.attr_scale_new(1.2));
			welcome_info.attributes = info_attributes;

			start_indexing = new Gtk.Button.with_label(_("Start Indexing"));
			start_indexing.get_style_context().add_class("suggested-action");

			start_listening = new Gtk.Button.with_label(_("Start Listening"));
			start_listening.get_style_context().add_class("suggested-action");

			progress = new Gtk.ProgressBar();

			start_indexing.button_release_event.connect((e) => {
				if (e.button == 1) { // Left click
					start_indexing.set_size_request(0,0);
					start_indexing.hide(); // Hide the Start Indexing button
					begin_indexing();
				}

				return true;
			});

			pack_start(welcome_header, true, false, 0);
			pack_start(welcome_info, true, false, 0);
			pack_start(start_indexing, false, false, 0);
			pack_start(progress, false, false, 0);
			pack_start(start_listening, false, false);

			welcome_header.show();
			welcome_info.show();
			start_indexing.show();
		}

		// begin_indexing is responsible for getting our initial list of files before starting to index
		public void begin_indexing() {
			Koto.last_index_check = GLib.get_monotonic_time();
			progress.set_text(_("Indexing..."));
			progress.show_text = true;
			progress.set_pulse_step(0.4);
			progress.pulse(); // Pulse back and forth until we get a list
			progress.show_all(); // Show the progress var

			var music_indexer = new Koto.Indexer("dir", kotoio.music_dir); // Create a dir-type indexer for our XDG music directory

			music_indexer.done.connect(() => { // Connect to the done signal
				stdout.printf("Indexing complete.\n");
				progress.set_text(_("Done indexing. Loading library view..."));
			});

			music_indexer.increment.connect((count) => { // Listen to our large file increment signal
				var new_text = "";

				if (count == 2500) {
					new_text = _("Spotify exists. Just saying.");
				} else 	if (count == 5000) {
					new_text = _("Did you actually buy all of this?");
				} else if (count == 10000) {
					new_text = _("I'm not even mad. That's amazing.");
				}

				if (new_text != "") {
					progress.set_text(new_text);
				}
			});

			new Thread<void*>("music-indexer", music_indexer.index);
			new Thread<void*>("indexer-wait", () => {
				while (!music_indexer.indexing_complete) {
					var now = GLib.get_monotonic_time();
					if (now >= (Koto.last_index_check + 250000)) { // If we're 250ms (250k microseconds) in the future
						Koto.last_index_check = now;
						progress.pulse();
					}
				}

				return null;
			});
		}
	}
}