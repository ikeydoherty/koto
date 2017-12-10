// This file contains classes used for artists / library tracks.

public class KotoArtist : Object {
	public string name;
	public KotoAlbum[] albums;

	public KotoArtist(string a_name, KotoAlbum[] a_albums) {
		name = a_name;
		albums = a_albums;
	}
}

public class KotoAlbum : Object {
	public string name;
	public KotoTrack[] tracks;

	public KotoAlbum(string a_name, KotoTrack[] a_tracks) {
		name = a_name;
		tracks = a_tracks;
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