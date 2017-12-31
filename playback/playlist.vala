// This file contains our Playlist functionality

namespace Koto {
	public class Playlist {
		private bool _on_first_track; // Whether or not we are on first track
		private bool _on_last_track; // Whether or not we are on last track
		private KotoTrack _current_track; // The current track
		private int _current_track_index; // The current track index
		private Gee.ConcurrentList<KotoTrack> _tracks; // A list of KotoTracks to play

		// Signals
		public signal void is_empty(); // is_empty is used to indicate when a playlist is empty.
		public signal void track_is_first(KotoTrack track); // is_first is used to indicate that the current track is the first track in the Playlist
		public signal void track_is_last(KotoTrack track); // is_last is used to indicate that the current track is the last track in the Playlist
		public signal void track_added(KotoTrack track); // added is used for when a track is added, typically via add_track
		public signal void track_changed(KotoTrack track); // changed is used when we change the track
		public signal void track_removed(KotoTrack track); // removed is used for when a track is removed, typically via remove_track

		public Playlist(Gee.ConcurrentList<KotoTrack>? tracks) {
			if (tracks != null) { // If we have tracks defined
				_tracks = tracks;

				_on_first_track = (_tracks.size == 1); // If there is only one track, set that we're on the first track
				_on_last_track = (_tracks.size == 1); // If there is only one track, set that we're on the last track
			} else { // If no tracks are defined
				_tracks = new Gee.ConcurrentList<KotoTrack>();
				_on_first_track = false;
				_on_last_track = false;
			}

			_current_track = null;
			_current_track_index = 0;
		}

		public KotoTrack current_track {
			get { return _current_track; }
		}

		public KotoTrack get_first_track() {
			return _tracks.get(0);
		}

		public KotoTrack get_last_track (){
			return _tracks.get(_tracks.size - 1);
		}

		public bool on_first_track {
			get { return _on_first_track; }
		}

		public bool on_last_track {
			get { return _on_last_track; }
		}

		// add_track will add a track to our tracks
		public void add_track(KotoTrack track) {
			if (!_tracks.contains(track)) { // If the Playlist does not already contain this track
				_tracks.add(track);
				_on_last_track = false; // No longer on last track
				track_added(track);
			}
		}

		// change_track is responsible for all the logic for actually changing the current track in our playlist
		public void change_track(KotoTrack track) {
			int track_index = _tracks.index_of(track);

			if (track_index != -1) { // If this track exists in tracks and we're not trying to "change" the current track to the same track
				_current_track = track; // Change our current track
				_current_track_index = track_index; // Change our current track index

				if (track_index == 0) { // If this is the first track
					_on_first_track = true;
					_on_last_track = (_tracks.size == 1);
					track_is_first(track); // Trigger is_first to indicate we're now on the first track
				} else if (track_index == (_tracks.size - 1)) { // If this is the last track
					_on_first_track = (_tracks.size == 1);
					_on_last_track = true;
					track_is_last(track); // Trigger is_last to indicate we're not on the last track
				} else { // If this is neither the first or last track
					_on_first_track = false;
					_on_last_track = false;
				}

				track_changed(track); // Trigger track_changed to indicate we're changing tracks
			}
		}

		// clear will clear our Playlist contents
		public void clear() {
			_tracks.clear();
			_on_first_track = true;
			_on_last_track = true;

			if (_current_track != null) { // If there is a currently playing track
				track_is_first(_current_track); // Trigger is_first since the current playing track is now the first / only item
				track_is_last(_current_track); // Trigger is_last since the current playing track is now the last
			}

			is_empty(); // Trigger empty since the playlist is empty
		}

		// next_track will attempt to go to the next track, if one exists
		public void next_track() {
			if (!_on_last_track) { // If we're not already on last track
				if (_current_track_index != -1) {
					KotoTrack new_track = _tracks.get(_current_track_index + 1); // Get the next track
					change_track(new_track);
				}
			}
		}

		// previous_track will attempt to go to the previous track, if one exists
		public void previous_track() {
			if (!_on_first_track) { // If we're not already on the first track
				KotoTrack new_track = _tracks.get(_current_track_index - 1); // Get the previous track
				change_track(new_track);
			}
		}

		// remove_track will remove a track from our tracks
		public void remove_track(KotoTrack track) {
			if (_tracks.contains(track)) { // If the Playlist contains this track
				_tracks.remove(track);
				track_removed(track); // Trigger removed to indicate the track has been removed

				if (_tracks.size == 0) { // If the playlist is now empty
					is_empty(); // Trigger our is_empty signal
				}
			}
		}
	}
}