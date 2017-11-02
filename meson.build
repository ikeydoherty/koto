project('koto', 'vala', 'c')

# Dependencies
glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.22.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

files = files(
	'controls/headerbar.vala',
	'controls/menu_popover.vala',
	'views/view_cover.vala',
	'views/view_list.vala'
)

files += 'koto.vala'

executable(
	'koto',
	files,
	dependencies: [glib_dep, gobject_dep, gtk_dep]
)