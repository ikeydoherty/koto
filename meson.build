project('koto', 'vala', 'c')

# Dependencies
gee_dep = dependency('gee-0.8', version: '>=0.20.0')
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.22.0')
sqlite_dep = dependency('sqlite3', version: '>=3.20.0')
taglib_dep = dependency('taglib_c', version: '>=1.11.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

cdata = configuration_data()
cdata.set_quoted('GETTEXT_PACKAGE', 'koto')
add_global_arguments('-DGETTEXT_PACKAGE="koto"', language: 'c')

files = files(
	'controls/flat_icon_button.vala',
	'controls/headerbar.vala',
	'controls/menu_item.vala',
	'controls/menu_popover.vala',
	'controls/playerbar.vala',
	'controls/views_list.vala',
	'data/db.vala',
	'data/io.vala',
	'views/view_devices.vala',
	'views/view_library_grid.vala',
	'views/view_library_list.vala',
	'koto.vala',
)

executable(
	'koto',
	files,
	dependencies: [glib_dep, gobject_dep, gtk_dep, sqlite_dep, taglib_dep]
)