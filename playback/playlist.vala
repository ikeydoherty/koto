// This file contains our Playlist functionality

namespace Koto {
	public class Playlist {
		private int _current_track_index; // The current track index
		private Gee.ConcurrentList<KotoTrack> _tracks; // A list of KotoTracks to play

		// Signals
		public signal void is_empty(); // is_empty is used to indicate when a playlist is empty.
		public signal void track_changed(KotoTrack track); // changed is used when we change the track

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

		private KotoTrack _current_track; // The current track
		public KotoTrack current_track {
			get { return _current_track; }
		}

		public KotoTrack get_first_track() {
			return _tracks.get(0);
		}

		public KotoTrack get_last_track (){
			return _tracks.get(_tracks.size - 1);
		}

		private bool _on_first_track; // Whether or not we are on first track
		public bool on_first_track {
			get { return _on_first_track; }
		}

		private bool _on_last_track; // Whether or not we are on last track
		public bool on_last_track {
			get { return _on_last_track; }
		}

		// add_tracks will add a list of tracks
		public void add_tracks(Gee.ConcurrentList<KotoTrack> tracks) {
			foreach (KotoTrack track in tracks) {
				_tracks.add(track);
			}

			_on_last_track = false; // No longer on last track
		}

		// add_track will add a track to our tracks
		public void add_track(KotoTrack track) {
			_tracks.add(track);
			_on_last_track = false; // No longer on last track
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
				} else if (track_index == (_tracks.size - 1)) { // If this is the last track
					_on_first_track = (_tracks.size == 1);
					_on_last_track = true;
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

				if (_tracks.is_empty) { // If the playlist is now empty
					is_empty(); // Trigger our is_empty signal
				}
			}
		}
	}
}