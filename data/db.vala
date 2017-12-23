// This file contains functionality related to our database

public class KotoDatabase : Object {
	public Sqlite.Database db; // Our Sqlite3 Database
	public Gee.HashMap<string,KotoArtist> data; // Our HashMap of artist, album, track data
	public bool allow_writes = false;
	public bool is_first_run = false;
	private string location;
	private double version;

	private string[] acceptable_artwork_filenames = {
		"cover.jpg",
		"cover.png",
		"Folder.jpg",
		"Folder.png",
		"folder.jpg",
		"folder.png"
	};

	public KotoDatabase() {
		data = new Gee.HashMap<string,KotoArtist>(); // Create our data HashMap
		version = 1;
		location = (Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_user_config_dir(), "koto", "koto-%s.db".printf(version.to_string())));

		int open_err = Sqlite.Database.open_v2(location, out db, Sqlite.OPEN_READWRITE);
		allow_writes = true;

		if (open_err != Sqlite.OK) { // If we failed to open database
			stderr.printf("%s\n", get_failure_string(open_err));
			is_first_run = true;
			allow_writes = create_new_database(); // Create a new database
		} else { // If we already have a database and sucessfully opened it
			load_data();
		}
	}

	// create_new_database will create a new versioned database. Returns a bool on success
	public bool create_new_database() {
		File kotodir = File.new_for_path(Path.get_dirname(location)); // Get the directory

		if (!kotodir.query_exists()) { // If the directory does not exist
			try {
				kotodir.make_directory(); // Make the directory
			} catch (Error err) {
				stderr.printf("Failed to create directory: %s\n", err.message);
			}
		}

		int open_err = Sqlite.Database.open_v2(location, out db, Sqlite.OPEN_READWRITE | Sqlite.OPEN_CREATE);  

		if (open_err == Sqlite.OK) { // If we successfully created the database
			 string create_tables = """
				CREATE TABLE library (
					id             TEXT    PRIMARY KEY    NOT NULL,
					artist      TEXT                                   NOT NULL,
					album    TEXT                                  NOT NULL,
					genre      TEXT                                  NOT NULL,
					path        TEXT                                  NOT NULL,
					title         TEXT                                  NOT NULL,
					track       INT                                     NOT NULL
				);

				CREATE TABLE artwork (
					artist    TEXT    NOT NULL,
					album  TEXT   NOT NULL,
					art         TEXT   NOT NULL
				);

				CREATE TABLE playlists (
					id            TEXT    NOT NULL,
					name    TEXT    NOT NULL
				);

				CREATE TABLE playlist_files (
					id          TEXT    NOT NULL,
					hash    TEXT    NOT NULL
				);
			""";

			int create_err = db.exec(create_tables);

			if (create_err != Sqlite.OK) {
				stderr.printf("Failed to create the database: %s\n", get_failure_string(create_err));
				return false;
			} else { // Successfully created table
				return true;
			}
		} else { // If we failed
			stderr.printf("Failed to open the database in CREATE mode: %s (%d)\n", get_failure_string(open_err), open_err);
			return false;
		}
	}

	// get_failure_string will get the respective failure string for a particular Sqlite error
	public string get_failure_string(int err) {
		string message = "Unknown error.";

		switch (err) {
			case Sqlite.PERM: // Access permission denied
				message = "Permission denied.";
				break;
			case Sqlite.BUSY:
				message = "Database is busy.";
				break;
			case Sqlite.LOCKED:
				message = "Database is locked.";
				break;
			case Sqlite.NOMEM: // Out of memory
				message = "Out of memory.";
				break;
			case Sqlite.CANTOPEN: // Can't open DB
				message = "Can't open the database.";
				break;
		}

		return message;
	}

	// load_data is responsible for loading our data and creating the necessary HashMap(s)
	public void load_data() {
		load_library(); // Load our library (files)
		load_artwork(); // Load associated artwork for files - By load really it's "make sure artwork is properly indexed"
	}

	// load_artwork will check for artwork associated with an artist and their album
	public void load_artwork() {
		foreach (string artist in data.keys) { // For each artist in our HashMap
			foreach (KotoAlbum album in data[artist].albums.values) { // For each album associated with this artist
				Sqlite.Statement get_artwork_query;
				var album_name = album.name;

				var escaped_artist = Uri.escape_string(artist); // Oh noes the artist escaped
				var escaped_album = Uri.escape_string(album_name);

				string albumEntrySelection = @"SELECT art FROM artwork WHERE artist='$escaped_artist' AND album='$escaped_album'";
				db.prepare_v2(albumEntrySelection, albumEntrySelection.length, out get_artwork_query);

				string artwork = ""; // Set artwork to an empty string

				while (get_artwork_query.step() == Sqlite.ROW) { // For each result returned
					artwork = Uri.unescape_string(get_artwork_query.column_text(0)); // Get any existing artwork
				}

				if (artwork == "") { // If there is no artwork for this artist
					foreach (KotoTrack track in album.tracks.values) { // For each track (only get first)
						string album_path = Path.get_dirname(track.path); // Get the album path based on the path of the first track

						File album_directory =  File.parse_name(album_path); // Create a new File based on the album path

						if (album_directory != null) {
							foreach (string artwork_filename in acceptable_artwork_filenames) { // For each artwork filename in our acceptable list
								File artwork_file = album_directory.get_child(Uri.unescape_string(artwork_filename)); // Get the potential file

								if (artwork_file.query_exists()) { // If the file exists
									try {
										FileInfo artwork_fileinfo = artwork_file.query_info("standard::*", 0); // Get the file info

										if (artwork_fileinfo.get_content_type().has_prefix("image/")) { // If this is an image
											artwork = Uri.escape_string(Path.build_path(Path.DIR_SEPARATOR_S, album_path, artwork_filename));
											break;
										}
									} catch (Error err) {
										stdout.printf("Failed to get the artwork info for %s in %s: %s\n", artwork_filename, album_path, err.message);
									}
								}
							}
						}

						break;
					}

					if (artwork != "") { // If we found artwork
						string insert_artwork_query = @"INSERT INTO artwork (artist, album, art) VALUES('$escaped_artist', '$escaped_album', '$artwork')";
						string err_msg;
						int insert_err = db.exec(insert_artwork_query, null, out err_msg);

						if (insert_err != Sqlite.OK) {
							stdout.printf("Failed to add our artwork: %s (%s) \n", get_failure_string(insert_err), err_msg);
						}
					}
				}

				album.artwork_uri = artwork; // Set this album's artwork_uri
			}
		}
	}

	// load_library will load our library contents (artists, albums, artwork, tracks);
	public void load_library() {
		Sqlite.Statement query;
		const string librarySelection = "SELECT * FROM library";
		db.prepare_v2(librarySelection, librarySelection.length, out query);

		int cols = query.column_count(); // Number of columns
		while (query.step() == Sqlite.ROW) { // For each row
			var rowData = new Gee.HashMap<string, string>(); // Create a hashmap to hold our row data, where first string is column name and value is the column text

			for (int i = 0; i < cols; i++) {
				string column_name = query.column_name(i);
				column_name = Uri.unescape_string(column_name);
				string column_value = query.column_text(i);
				column_value = Uri.unescape_string(column_value);

				rowData.set(column_name, column_value);
			}

			var artist = rowData["artist"];
			var album = rowData["album"];

			if (!data.has_key(artist)) { // If this artist isn't in the HashMap
				data[artist] = new KotoArtist(artist, null); // Create a new KotoArtist class for this artist. Don't add any albums yet
			}

			var track_num = int.parse(rowData["track"]);

			var track = new KotoTrack(rowData["id"], rowData["path"], track_num, rowData["genre"], rowData["title"]); // Create a new KotoTrack from our row data
			data[artist].add_track(album, track); // Add this track to the album, even if doesn't exist
		}
	}

	// add_track is responsible for adding a track to our library
	public void add_track(string a_path, KotoTrackMetadata metadata) {
		if  (allow_writes) {
			string id = a_path.hash().to_string(); // Create an id based on the hash

			string artist = Uri.escape_string(metadata.artist);
			string album = Uri.escape_string(metadata.album);
			string genre = Uri.escape_string(metadata.genre);
			string title = Uri.escape_string(metadata.title);
			string path = Uri.escape_string(a_path);
			int track = metadata.track;

			string insert_track_sql = @"INSERT INTO library (id, artist, album, genre, path, title, track)	VALUES ('$id', '$artist', '$album', '$genre', '$path', '$title', $track);";
			int exec_err = db.exec(insert_track_sql);

			if (exec_err != Sqlite.OK) {
				stderr.printf("Failed to add our track: %s\n", get_failure_string(exec_err));
			}
		}
	}
}