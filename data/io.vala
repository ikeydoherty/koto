// This file contains IO related functionality used by Koto
// NOTE: Some of this is temporary and only used for testing purposes. So don't flip out, k? Kthx.

namespace Koto {
	public class KotoFileIO : Object {
		public string music_dir; // User Music Directory

		public KotoFileIO() {
			music_dir = Environment.get_user_special_dir(UserDirectory.MUSIC); // Get the user's Music directory, using XDG special user directories
			TagLib.ID3v2.set_default_text_encoding (TagLib.ID3v2.Encoding.UTF8);
		}

		public KotoTrackMetadata get_metadata(string filepath) {
			TagLib.File file = new TagLib.File(filepath);
			string artist = _("Unknown");
			string album = _("Unknown");
			string title;
			int length = 0;
			int track = 0;

			if (file != null && file.tag != null) { // If we successfully retrieved id3 information
				artist = (file.tag.artist != "") ? file.tag.artist : _("Unknown");
				album = (file.tag.album != "") ? file.tag.album : _("Unknown");
				title = (file.tag.title != "") ? file.tag.title : _("Unknown");
				length = (file.audioproperties != null) ? file.audioproperties.length : 0;
				track = (int) file.tag.track;
			} else { // If we failed to fetch id3 information
				title = Path.get_basename(filepath); // At least treat the title as the display name
				int last_index_of_dot = title.last_index_of("."); // Get the last index
				title = title.substring(0, last_index_of_dot);

				if (title.index_of(" - ") != -1) { // If there might be some form of Artist - Song Name
					var splitName = title.split(" - ", 2);
					var potential_artist = splitName[0].strip();
					title = splitName[1];

					if (potential_artist.length > 2) { // If the artist string is not likely to just be numbers
						artist = potential_artist;

						try {
							Regex regex = new Regex("^([0-9]+)"); // Attempt a regex where we strip out any prefixed numbers
							var artist_name = regex.replace(artist, artist.length, 0, "").strip(); // Replace the prefixed numbers and trim whitespace
							var track_s = artist.replace(artist_name, "").strip(); // Do the inverse, strip out the likely artist so we get the numbers, and trim

							Regex strip_invalid_chars = new Regex("[^A-Za-zÄ-Öä-öåµø]"); // Attempt to strip out any odd characters
							artist_name = strip_invalid_chars.replace(artist_name, artist_name.length, 0, "").strip();

							artist = artist_name;
							track = int.parse(track_s);
						} catch (RegexError err) {
							stdout.printf("%s", err.message);
						}
					} else { // If the artist string is likely to just be numbers
						if (potential_artist.index_of("0") == 0) {
							potential_artist = potential_artist.substring(1);
						}

						track = int.parse(potential_artist); // Parse as an int and set to track
					}
				}
			}

			return new KotoTrackMetadata(artist, album, title, track); // Return a new KotoTrackMetadata Object
		}
	}
}