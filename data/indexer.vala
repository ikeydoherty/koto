namespace Koto {
	public class Indexer {
		public int64 file_count; 
		public bool indexing_complete;
		public signal void done();
		public signal void increment(int64 count);
		public string loc;
		public string type;

		public Indexer(string t, string l) {
			file_count = 0;
			loc = l;
			type = t;
		}

		public void* index() {
			this.get_directory_contents.begin(this.loc, false, (obj, res) => {
				this.get_directory_contents.end(res);
				this.indexing_complete = true;
				done();
			});

			return null;
		}

		// get_directory_contents will get all available audio files in a directory or its children
		public async void get_directory_contents(string dir, bool child_of_root = false) {
			var dir_file = File.new_for_path(dir); // Create a new File for the path

			try {
				Cancellable cancellable = null;
				FileEnumerator enum = dir_file.enumerate_children("standard::*", FileQueryInfoFlags.NONE, cancellable); // Start enumerating children
				FileInfo inner_music_file = null;

				while (!cancellable.is_cancelled() && ((inner_music_file = enum.next_file(cancellable)) != null)) { // While our IO operation wasn't cancelled and we have a next file 
					FileType file_type = inner_music_file.get_file_type(); // Get the file type
					string file_full_path = Path.build_path(Path.DIR_SEPARATOR_S, dir, inner_music_file.get_name());

					if (!inner_music_file.get_is_hidden()) { // If this is not a hidden file
						if ((file_type == FileType.DIRECTORY) || (file_type == FileType.SYMBOLIC_LINK)) { // If this is a directory or a symlink (possibly a directory)
							get_directory_contents.begin(file_full_path, true);
						} else if (file_type == FileType.REGULAR) { // If we're looking for a file and this is one
							string content_type = inner_music_file.get_content_type(); // Get the content type so we can do some basic content type checking

							if ((content_type.has_prefix("audio/") || (content_type.has_suffix("+ogg")))) { // If this has an audio mimetype or may be playable (some ogg reports as video/)
								file_full_path = inner_music_file.get_is_symlink() ? inner_music_file.get_symlink_target() : file_full_path;
								KotoTrackMetadata metadata = Koto.kotoio.get_metadata(file_full_path); // Get the metadata and add to the index
								Koto.kotodb.add_track(file_full_path, metadata); // Call to the DB to add the track

								this.file_count++; // Add one to our file count
								increment(this.file_count);
							}
						}
					}
				}
			} catch (Error e) {
				stderr.printf("Error while enumerating files: %s", e.message);
			}
		}
	}
}