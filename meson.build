project('koto', 'vala', 'c')

# Dependencies
gee_dep = dependency('gee-0.8', version: '>=0.20.0')
gdk_dep = dependency('gdk-3.0', version: '>=3.22.26')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gst_dep = dependency('gstreamer-1.0', version: '>=1.12.0')
gst_player_dep = dependency('gstreamer-player-1.0', version: '>=1.12.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.22.26')
libnotify_dep = dependency('libnotify', version: '>=0.7.7')
pango_dep = dependency('pango', version: '>=1.40.0')
sqlite_dep = dependency('sqlite3', version: '>=3.20.0')
taglib_dep = dependency('taglib_c', version: '>=1.11.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

path_prefix = get_option('prefix')
path_datadir = join_paths(path_prefix, get_option('datadir'), meson.project_name())

cdata = configuration_data()

cdata.set_quoted('GETTEXT_PACKAGE', 'koto')

# Namespaced with KOTO to match vapi Koto namespace
cdata.set_quoted('KOTO_DATADIR', path_datadir)
cdata.set_quoted('KOTO_VERSION', meson.project_version())

# Write config.h now
config_h = configure_file(
        configuration: cdata,
        output: 'config.h',
)

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
	'misc/utils.vala',
	'playback/engine.vala',
	'playback/keyboard.vala',
	'playback/notification.vala',
	'playback/playlist.vala',
	'views/devices.vala',
	'views/getting_started.vala',
	'views/library.vala',
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
		libnotify_dep,
		pango_dep,
		sqlite_dep,
		taglib_dep
	],
        vala_args: [
                '--vapidir', meson.current_source_dir(),
                '--pkg', 'config',
        ],
        include_directories: [
                include_directories('.'),
        ],
	link_args: '-lm'
)
