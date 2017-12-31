// This file contains classes used for artists / library tracks.

public class KotoArtist : Object {
	public string name;
	public Gee.HashMap<string,KotoAlbum> albums;

	public KotoArtist(string a_name, Gee.HashMap<string,KotoAlbum>? a_albums) {
		name = a_name;

		if (albums != null) {
			albums = a_albums;
		} else {
			albums = new Gee.HashMap<string,KotoAlbum>(); // Create an empty HashMap of albums
		}
	}

	// add_album will add an album to our albums
	public void add_album(string album_name, KotoTrack[]? tracks) {
		var album = albums.get(album_name); // Get the album if it exists already

		if (album == null) { // If this album doesn't exist
			album = new KotoAlbum(album_name, tracks); // Create a new KotoAlbum
		} else {
			album.add_tracks(tracks); // Add tracks
		}

		albums[album_name] = album;
	}

	// add_track will add a track to an album
	public void add_track(string album_name, KotoTrack track) {
		KotoTrack[] tracks = { track }; // Create a new tracks array
		add_album(album_name, tracks);
	}
}

public class KotoAlbum : Object {
	private string _artwork_uri;

	public string name;
	public Gee.ConcurrentList<string> genres;
	public Gee.ConcurrentList<KotoTrack> tracks;

	public KotoAlbum(string a_name, KotoTrack[]? a_tracks) {
		name = a_name;
		genres = new Gee.ConcurrentList<string>(); // Set to an empty array
		tracks = new Gee.ConcurrentList<KotoTrack>(); // Create an empty HashMap of tracks

		if (a_tracks != null) { // If we were provided a HashMap of KotoTracks
			add_tracks(a_tracks);
		}
	}

	public string artwork_uri {
		get { return _artwork_uri; }
		set { _artwork_uri = Uri.unescape_string(value); }
	}

	// add_tracks will add all the tracks provided, only updating 
	// TODO: Make this not suck.
	public void add_tracks(KotoTrack[]? added_tracks) {
		foreach (KotoTrack track in added_tracks) { // For reach track in tracks
			tracks.add(track);
			string[] track_genres = track.genre.split(";"); // Split the genres based on the semi-colon delimiter, which is what TagLib presents genres as

			foreach (string genre in track_genres) { // For each genre specified
				if (!genres.contains(genre)) { // If genres does not contain this genre
					genres.add(genre); // Add this genre
				}
			}
		}

		tracks.sort(compare_tracks); // Ensure we sort items when added
	}

	// compare_tracks provides a sort result for which track should be ordered first
	public int compare_tracks(KotoTrack first_track, KotoTrack second_track) {
		string first_child_text = first_track.title;
		string second_child_text = second_track.title;

		if (first_child_text.has_prefix(_("Chapter"))) { // If this is an audiobook, has the string Chapter, do some special comparison because strcmp isn't good with numbers
			int first_chapter_num = int.parse(first_child_text.replace(_("Chapter") + " ", "")); // Strip out Chapter # (or the locale string) for the first chapter
			int second_chapter_num = int.parse(second_child_text.replace(_("Chapter") + " ", "")); // Strip out Chapter # (or the locale string) for the second chapter

			return (first_chapter_num <= second_chapter_num) ? -1 : 1; // If the first chapter is a lower number than the second chapter, place it first
		} else {
			return (strcmp(first_child_text, second_child_text) <= 0) ? -1 : 1;
		}
	}
}

public class KotoTrack : Object {
	public string id; // Unique track ID
	public string path; // File path to track
	public string genre; // Genre for track
	public int num; // Track number
	public string title; // Track title

	public KotoTrack(string t_id, string t_path, int t_num, string t_genre, string t_title) {
		id = t_id;
		path = t_path;
		num = t_num;
		genre = t_genre;
		title = t_title;
	}
}