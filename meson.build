project('koto', 'vala', 'c')

# Dependencies
gee_dep = dependency('gee-0.8', version: '>=0.20.0')
gdk_dep = dependency('gdk-3.0', version: '>=3.22.26')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gst_dep = dependency('gstreamer-1.0', version: '>=1.12.0')
gst_player_dep = dependency('gstreamer-player-1.0', version: '>=1.12.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.22.26')
pango_dep = dependency('pango', version: '>=1.40.0')
sqlite_dep = dependency('sqlite3', version: '>=3.20.0')
taglib_dep = dependency('taglib_c', version: '>=1.11.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

cdata = configuration_data()
cdata.set_quoted('GETTEXT_PACKAGE', 'koto')
add_global_arguments('-DGETTEXT_PACKAGE="koto"', language: 'c')

files = files(
	'controls/album_item.vala',
	'controls/flat_icon_button.vala',
	'controls/headerbar.vala',
	'controls/list.vala',
	'controls/menu_item.vala',
	'controls/menu_popover.vala',
	'controls/playerbar.vala',
	'controls/text_list_item.vala',
	'controls/track_item.vala',
	'controls/views_list.vala',
	'data/artist.vala',
	'data/indexer.vala',
	'data/db.vala',
	'data/metadata.vala',
	'playback/engine.vala',
	'views/devices.vala',
	'views/getting_started.vala',
	'views/library_grid.vala',
	'views/library_list.vala',
	'koto.vala',
)

executable(
	'koto',
	files,
	dependencies: [
		gee_dep,
		gdk_dep,
		glib_dep,
		gobject_dep,
		gst_dep,
		gst_player_dep,
		gtk_dep,
		pango_dep,
		sqlite_dep,
		taglib_dep
	],
	link_args: '-lm'
)