// This file contains IO related functionality used by Koto
// NOTE: Some of this is temporary and only used for testing purposes. So don't flip out, k? Kthx.

public class KotoFileIO : Object {
	public string music_dir; // User Music Directory

	public KotoFileIO() {
		music_dir = GLib.Environment.get_user_special_dir(GLib.UserDirectory.MUSIC); // Get the user's Music directory, using XDG special user directories
		TagLib.ID3v2.set_default_text_encoding (TagLib.ID3v2.Encoding.UTF8);
	}

	// get_directory_content will get a list of content (directories or files)
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
					if ((file_type == GLib.FileType.DIRECTORY) || (file_type == GLib.FileType.SYMBOLIC_LINK)) { // If this is a directory or a symlink (possibly a directory)
						if (type == "directory") {
							contents.append_val(complete_dir + inner_music_file.get_display_name()); // Add the path
						}

						if (recursive) { // If we should do recursion
							var dir_content = get_directory_content(file_full_path, type, recursive);

							if (dir_content.length != 0) { // If there is content to append
								contents.append_vals(dir_content, dir_content.length);
							}
						}
					} else if (file_type == GLib.FileType.REGULAR) { // If we're looking for a file and this is one
						string content_type = inner_music_file.get_content_type(); // Get the content type so we can do some basic content type checking

						if ((type == "file") && (content_type.has_prefix("audio/") || (content_type.has_suffix("+ogg")))) { // If this has an audio mimetype or may be playable (some ogg reports as video/)
							file_full_path = inner_music_file.get_is_symlink() ? inner_music_file.get_symlink_target() : file_full_path;

							contents.append_val(file_full_path);
							get_metadata(inner_music_file, file_full_path);
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

	public void get_metadata(GLib.FileInfo fileinfo, string filepath) {
		TagLib.File file = new TagLib.File(filepath);
		string artist = _("Unknown");
		string album = _("Unknown");
		string title;
		int length = 0;

		if (file != null && file.tag != null) { // If we successfully retrieved id3 information
			artist = (file.tag.artist != "") ? file.tag.artist : _("Unknown");
			album = (file.tag.album != "") ? file.tag.album : _("Unknown");
			title = (file.tag.title != "") ? file.tag.title : _("Unknown");
			length = (file.audioproperties != null) ? file.audioproperties.length : 0;
		} else { // If we failed to fetch id3 information
			title = fileinfo.get_edit_name(); // At least treat the title as the display name

			if (title.index_of(" - ") != -1) { // If there might be some form of Artist - Song Name
				var splitName = title.split(" - ", 2);
				title = splitName[1];

				if (splitName[0].strip().length > 2) { // If the artist string is not likely to just be numbers
					artist = splitName[0].strip();

					try {
						Regex regex = new Regex("^([0-9]+)\\s");
						artist = regex.replace(artist, artist.length, 0, "").strip();
					} catch (RegexError err) {
						stdout.printf("%s", err.message);
					}
				}
			}
		}

		stdout.printf("Artist:%s\nAlbum:%s\nTitle:%s\n", artist, album, title);
	}
}