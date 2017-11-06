// This file contains functionality related to our database

public class KotoDatabase : Object {
	public Sqlite.Database db; // Our Sqlite3 Database
	public bool allow_writes = false;
	public bool is_first_run = false;
	private string location;
	private string version_s;
	private double version;

	public KotoDatabase() {
		version_s = "0.1";
		version = 0.1;
		location = (Path.build_path(Path.DIR_SEPARATOR_S, Environment.get_user_config_dir(), "koto", "koto-" +  version_s + ".db"));

		int open_err = Sqlite.Database.open_v2(location, out db, Sqlite.OPEN_READWRITE);
		allow_writes = true;

		if (open_err != Sqlite.OK) { // If we failed to open database
			stderr.printf("%s\n", get_failure_string(open_err));
			is_first_run = true;
			allow_writes = create_new_database(); // Create a new database
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