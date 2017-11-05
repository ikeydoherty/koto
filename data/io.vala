// This file contains IO related functionality used by Koto
// NOTE: Some of this is temporary and only used for testing purposes. So don't flip out, k? Kthx.

public class KotoFileIO : Object {
	public string music_dir; // User Music Directory

	public KotoFileIO() {
		music_dir = GLib.Environment.get_user_special_dir(GLib.UserDirectory.MUSIC); // Get the user's Music directory, using XDG special user directories
	}

	public Array<string> get_directory_content(string dir, string type, bool? recursive = false) {
		var complete_dir = dir;

		if (!complete_dir.has_suffix("/")) {
			complete_dir += "/";
		}

		var dir_file = GLib.File.new_for_path(complete_dir); // Create a new File for the path
		Array<string> contents = new Array<string> (); // Create a contents array

		try {
			GLib.Cancellable cancellable = null;
			GLib.FileEnumerator file_enum = dir_file.enumerate_children("standard::*", FileQueryInfoFlags.NONE, cancellable); // Start enumerating children

			GLib.FileInfo inner_music_file = null;
			while (!cancellable.is_cancelled() && ((inner_music_file = file_enum.next_file(cancellable)) != null)) { // While our IO operation wasn't cancelled and we have a next file
				GLib.FileType file_type = inner_music_file.get_file_type(); // Get the file type
				string file_full_path = complete_dir + inner_music_file.get_name();

				if (!inner_music_file.get_is_hidden()) { // If this is not a hidden file
					if ((type == "directory") && ((file_type == GLib.FileType.DIRECTORY) || (file_type == GLib.FileType.SYMBOLIC_LINK))) { // If we're looking for a directory, and this is a directory or a symlink (possibly a directory)
						stdout.printf("%s\n", file_full_path);
						if (recursive) { // If we should do recursion
							var dir_content = get_directory_content(file_full_path, "directory", recursive);
							contents.append_vals(dir_content, dir_content.length);
						} else {
							contents.append_val(complete_dir + inner_music_file.get_display_name()); // Add the file name
						}
					} else if ((type == "file") && (file_type == GLib.FileType.REGULAR)) { // If we're looking for a file and this is one
						string content_type = inner_music_file.get_content_type(); // Get the content type so we can do some basic content type checking

						if (content_type.has_prefix("audio/") || (content_type == "video/x-vorbis+ogg")) { // If this has an audio mimetype or may be playable (some ogg reports as video/)
							contents.append_val(file_full_path);
							stdout.printf("%s", complete_dir + inner_music_file.get_display_name());
						}
					}
				}
			}

			if (cancellable.is_cancelled()) { // If IO was cancelled
				throw new IOError.CANCELLED("Operation was cancelled.");
			} else {
				return contents;
			}
		} catch (Error e) {
			stdout.printf(e.message);
			return contents;
		}
	}
}