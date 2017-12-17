// This file contains functionality related to our database

public class KotoDatabase : Object {
	public Sqlite.Database db; // Our Sqlite3 Database
	public Gee.HashMap<string,KotoArtist> data; // Our HashMap of artist, album, track data
	public bool allow_writes = false;
	public bool is_first_run = false;
	private string location;
	private double version;

	public KotoDatabase() {
		version = 1;
		location = (Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_user_config_dir(), "koto", "koto-%s.db".printf(version.to_string())));

		int open_err = Sqlite.Database.open_v2(location, out db, Sqlite.OPEN_READWRITE);
		allow_writes = true;

		if (open_err != Sqlite.OK) { // If we failed to open database
			stderr.printf("%s\n", get_failure_string(open_err));
			is_first_run = true;
			allow_writes = create_new_database(); // Create a new database
		} else { // If we already have a database and sucessfully opened it
			data = new Gee.HashMap<string,KotoArtist>(); // Create our data HashMap
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
					path        TEXT                                  NOT NULL,
					title         TEXT                                  NOT NULL,
					track       INT                                     NOT NULL
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
		load_library();
	}

	// load_library will load our library contents (artists, albums, tracks);
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

			var track = new KotoTrack(rowData["id"], rowData["path"], track_num, rowData["title"]); // Create a new KotoTrack from our row data
			data[artist].add_track(album, track); // Add this track to the album, even if doesn't exist
		}

		foreach (KotoArtist artist in data.values) { // For each artist
			stdout.printf("Artist: %s\n", artist.name);

			foreach (KotoAlbum album in artist.albums.values) { // For each album
				stdout.printf("  Album: %s\n", album.name);

				foreach (KotoTrack track in album.tracks.values) { // For each track
					stdout.printf("    #%d: %s\n", track.num, track.title);
				}
			}

			stdout.printf("----\n");
		}
	}

	// add_track is responsible for adding a track to our library
	public void add_track(string a_path, string a_title, string a_artist, string a_album, int track) {
		if  (allow_writes) {
			string id = a_path.hash().to_string(); // Create an id based on the hash

			string path = Uri.escape_string(a_path);
			string title = Uri.escape_string(a_title);
			string artist = Uri.escape_string(a_artist);
			string album = Uri.escape_string(a_album);

			string insert_track_sql = @"INSERT INTO library (id, artist, album, path, title, track)	VALUES ('$id', '$artist', '$album', '$path', '$title', $track);";
			int exec_err = db.exec(insert_track_sql);

			if (exec_err != Sqlite.OK) {
				stderr.printf("Failed to add our track: %s\n", get_failure_string(exec_err));
			}
		}
	}
}