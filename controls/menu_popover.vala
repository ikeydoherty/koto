// This contains the code for our Menu Popover

public class KotoMenuPopover : Gtk.Popover {
	// Containers
	public Gtk.Stack popover_stack;

	// Buttons
	public Gtk.Button show_cover_button;
	public Gtk.Button show_list_button;
	public Gtk.Button show_settings_button;
	public KotoMenuItem update_music_button;

	protected Gtk.Button show_extras_button;
	protected KotoMenuItem back_from_extras_button;

	public KotoMenuPopover() {
		Object();
		set_size_request(180, 280); // Default to 200px width by 300 height (after accounting for inner Stack margin)

		popover_stack = new Gtk.Stack();
		popover_stack.set_transition_duration(250); // 250ms
		popover_stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT); // Slide to the left or right

		var main_stack = create_main_stack();
		var extras_stack = create_extras_stack();

		popover_stack.add_named(main_stack, "main");
		popover_stack.add_named(extras_stack, "extras");

		popover_stack.show_all();

		add(popover_stack);

		closed.connect(() => {
			popover_stack.set_visible_child_name("main");
		});
	}

	// create_main_stack will create our main stack consisting of the majority of popover functionality
	Gtk.Box create_main_stack() {
		var stack = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		stack.margin = 10;

		var items = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		items.expand = true;
		items.get_style_context().add_class("flat");

		show_cover_button = new Gtk.Button.from_icon_name("view-grid-symbolic", Gtk.IconSize.MENU);
		show_list_button = new Gtk.Button.from_icon_name("view-list-symbolic", Gtk.IconSize.MENU);

		var view_buttons_box = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
		view_buttons_box.set_layout(Gtk.ButtonBoxStyle.EXPAND); // Have the buttons expand
		view_buttons_box.set_spacing(0); // Have some spacing between the buttons
		view_buttons_box.add(show_cover_button); // Add Cover Button
		view_buttons_box.add(show_list_button); // Add List Button
		view_buttons_box.margin_bottom = 5;

		items.pack_start(view_buttons_box, false, true, 0); // Add View Buttons box to items

		show_extras_button = new KotoMenuItem(_("Extras"), "", "right"); // Extras Button
		show_extras_button.margin_bottom = 5;

		show_settings_button = new KotoMenuItem(_("Settings")); // Settings Button

		items.add(show_extras_button);
		items.add(show_settings_button);

		show_extras_button.clicked.connect(() => { // On connect, go to our extras stack
			this.popover_stack.set_visible_child_name("extras");
		});

		stack.pack_start(items, false, true, 0);
		return stack;
	}

	// create_extras_stack will create our extras stack consisting of extra functionality we don't want to shove in the menu
	Gtk.Box create_extras_stack() {
		var stack = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		stack.margin = 10;

		var items = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		items.expand = true;
		items.get_style_context().add_class("flat");

		back_from_extras_button = new KotoMenuItem(_("Back"), "go-previous-symbolic");
		items.add(back_from_extras_button);

		var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
		separator.margin_top = 10;
		separator.margin_bottom = 10;
		items.add(separator);

		update_music_button = new KotoMenuItem(_("Update Library"), "view-refresh-symbolic");
		items.add(update_music_button);
		
		back_from_extras_button.button_press_event.connect((e) => { // On connect, go back to our main stack
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