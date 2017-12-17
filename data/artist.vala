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
	public string name;
	public Gee.HashMap<string,KotoTrack> tracks;

	public KotoAlbum(string a_name, KotoTrack[]? a_tracks) {
		name = a_name;
		tracks = new Gee.HashMap<string,KotoTrack>(); // Create an empty HashMap of tracks

		if (a_tracks != null) { // If we were provided a HashMap of KotoTracks
			add_tracks(a_tracks);
		}
	}

	// add_tracks will add all the tracks provided, only updating 
	// TODO: Make this not suck.
	public void add_tracks(KotoTrack[]? added_tracks) {
		foreach (KotoTrack track in added_tracks) { // For reach track in tracks
			tracks.set(track.id, track); // Set in tracks this track, with the key being the track ID
		}
	}
}

public class KotoTrack : Object {
	public string id; // Unique track ID
	public string path; // File path to track
	public int num; // Track number
	public string title; // Track title

	public KotoTrack(string t_id, string t_path, int t_num, string t_title) {
		id = t_id;
		path = t_path;
		num = t_num;
		title = t_title;
	}
}

public class KotoTrackMetadata : Object {
	public string artist;
	public string album;
	public string title;
	public int track;

	public KotoTrackMetadata(string t_artist, string t_album, string t_title, int t_track) {
		artist = t_artist;
		album = t_album;
		title = t_title;
		track = t_track;
	}
}