// This contains the code for our Menu Popover

namespace Koto {
	public class KotoMenuPopover : Gtk.Popover {
		// Containers
		public Gtk.Stack popover_stack;

		// Buttons
		public Gtk.Button show_preferences_button;
		public KotoMenuItem update_music_button;

		protected Gtk.Button show_extras_button;
		protected KotoMenuItem back_from_extras_button;

		public KotoMenuPopover() {
			Object();

			popover_stack = new Gtk.Stack();
			popover_stack.set_transition_duration(250); // 250ms
			popover_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT); // Slide to the left or right
			popover_stack.margin_top = 10;
			popover_stack.margin_bottom = 10;

			var main_stack = create_main_stack(); // Create our main items stack
			var extras_stack = create_extras_stack(); // Create our extras items stack

			popover_stack.add_named(main_stack, "main");
			popover_stack.add_named(extras_stack, "extras");

			popover_stack.show_all();

			add(popover_stack);

			closed.connect(() => { // When we close the popover
				popover_stack.set_visible_child_name("main"); // Ensure we switch back to main stack
			});
		}

		// create_main_stack will create our main stack consisting of the majority of popover functionality
		Gtk.Box create_main_stack() {
			var stack = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

			var items = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			items.expand = true;
			items.get_style_context().add_class("flat");

			show_extras_button = new KotoMenuItem(_("Extras"), "", "right"); // Extras Button
			show_extras_button.margin_bottom = 5;

			show_preferences_button = new KotoMenuItem(_("Preferences")); // Preferences Button

			items.add(show_extras_button);
			items.add(show_preferences_button);

			show_extras_button.clicked.connect(() => { // On connect, go to our extras stack
				this.popover_stack.set_visible_child_name("extras");
			});

			stack.pack_start(items, false, true, 0);
			return stack;
		}

		// create_extras_stack will create our extras stack consisting of extra functionality we don't want to shove in the menu
		Gtk.Box create_extras_stack() {
			var stack = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

			var items = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
			items.expand = true;
			items.get_style_context().add_class("flat");

			back_from_extras_button = new KotoMenuItem(_("Back"), "go-previous-symbolic");
			items.add(back_from_extras_button);

			var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL); // Create a separator to put between our back button and the rest of the items
			separator.margin_bottom = 5;
			items.add(separator);

			update_music_button = new KotoMenuItem(_("Update Library"), "view-refresh-symbolic");
			items.add(update_music_button);
			
			back_from_extras_button.button_release_event.connect((e) => { // On connect, go back to our main stack
				if (e.button != 1) {
					return Gdk.EVENT_PROPAGATE; 
				}
				popover_stack.set_visible_child_name("main");
				return Gdk.EVENT_STOP;
			});

			stack.pack_start(items, false, true, 0);
			return stack;
		}
	}
}