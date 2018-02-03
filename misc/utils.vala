// This file contains our misc. utils class

namespace Koto {
	public class Utils {
		// format_seconds will format the seconds provided into %H:%M:%S, %M:%S, or just %S.
		// Additionally it can format the string relative to any provided duration, to ensure formatted duration and passed seconds match
		public string format_seconds(double seconds, string? relative_duration_s) {
			string time_string = "";
			double hours = Math.floor(seconds / 3600);
			double minutes = Math.floor(seconds / 60);

			if (seconds < 60) { // If seconds passed is less than 60
				time_string = "00:%s".printf(pad_num(seconds)); // Set time to 00:%s, where %s is padded string seconds
			} else if ((minutes >= 1) && (hours == 0)) { // If this is 1-59 minutes
				if (seconds == 60) { // If this is exactly 1 minute
					time_string = "01:00";
				} else {
					double remaining_seconds = (seconds - (minutes * 60)); // Get the remaining seconds based on seconds minus total minutes * 60s
					time_string = "%s:%s".printf(pad_num(minutes), pad_num(remaining_seconds));
				}
			} else if (hours >= 1) { // 1 hour or more
				if (seconds == 3600) { // If this is exactly one hour
					time_string = "01:00:00";
				} else {
					double seconds_excluding_hours = (seconds - (hours * 3600)); // Get the number of seconds remaining after excluding hours
					double remaining_minutes = Math.floor(seconds_excluding_hours / 60); // Get remaining minutes, lowering to nearest integer
					double remaining_seconds = Math.floor(seconds_excluding_hours - (remaining_minutes * 60)); // Get the remaining seconds, which is our seconds (calculating our hours) minus our rounded down minutes * 60
					time_string = "%s:%s:%s".printf(pad_num(hours), pad_num(remaining_minutes), pad_num(remaining_seconds));
				}
			}

			if (relative_duration_s != "") { // If a relative duration string is provided
				if (time_string.length != relative_duration_s.length) { // If the time string and relative duration length do not match
					time_string = "00:%s".printf(time_string); // Prepend 00: to string
				}
			}

			return time_string;
		}

		// pad_num will simply pad / prefix num with 0 if it's less than 9 or do nothing if 10+
		public string pad_num(double seconds) {
			string seconds_conv = seconds.to_string();
			return (seconds > 9) ? seconds_conv : "0" + seconds_conv;
		}
	}
}