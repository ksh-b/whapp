import 'package:intl/intl.dart';

MapEntry<int, String> parseDateString(String timestamp) {
  try {
    int differenceInSeconds = calculateDifferenceInSeconds(timestamp);
    return formatTimeDifference(differenceInSeconds);
  } catch (e) {
    return MapEntry(0, timestamp);
  }
}

MapEntry<int, String> parseUnixTime(int unixTime) {
  try {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime);
    DateTime now = DateTime.now();
    int differenceInSeconds = now.difference(dateTime).inSeconds;
    return formatTimeDifference(differenceInSeconds);
  } catch (e) {
    return MapEntry(0, unixTime.toString());
  }
}

int calculateDifferenceInSeconds(String timestamp) {
  if (timestamp.contains("ago")) {
    if (timestamp.startsWith("a ")) {
      timestamp = timestamp.replaceFirst("a ", "1 ");
    }
    return convertTimeStringToSeconds(timestamp);
  } else {
    DateTime dateTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    return now.difference(dateTime).inSeconds;
  }
}

MapEntry<int, String> formatTimeDifference(int differenceInSeconds) {
  const int minute = 60;
  const int hour = 60 * minute;
  const int day = 24 * hour;
  const int month = 30 * day;

  if (differenceInSeconds < 1) {
    return MapEntry(differenceInSeconds, 'just now');
  } else if (differenceInSeconds < minute) {
    return MapEntry(differenceInSeconds, '$differenceInSeconds seconds ago');
  } else if (differenceInSeconds < hour) {
    int minutes = (differenceInSeconds / minute).floor();
    return MapEntry(differenceInSeconds,
        '$minutes ${(minutes == 1) ? 'minute' : 'minutes'} ago');
  } else if (differenceInSeconds < day) {
    int hours = (differenceInSeconds / hour).floor();
    return MapEntry(
        differenceInSeconds, '$hours ${(hours == 1) ? 'hour' : 'hours'} ago');
  } else if (differenceInSeconds < month) {
    int days = (differenceInSeconds / day).floor();
    if (days == 1) {
      return MapEntry(differenceInSeconds, 'yesterday');
    } else {
      return MapEntry(differenceInSeconds, '$days days ago');
    }
  } else {
    int months = (differenceInSeconds / month).floor();
    return MapEntry(differenceInSeconds,
        '$months ${(months == 1) ? 'month' : 'months'} ago');
  }
}

int convertTimeStringToSeconds(String timeString) {
  List<String> words = timeString.split(' ');
  int value = int.parse(words[0]);
  String unit = words[1].toLowerCase();
  int seconds;
  switch (unit) {
    case 'second':
    case 'seconds':
      seconds = value;
      break;
    case 'minute':
    case 'minutes':
      seconds = value * 60;
      break;
    case 'hour':
    case 'hours':
      seconds = value * 3600;
      break;

    default:
      seconds = 0;
  }

  return seconds;
}

String convertToIso8601(String inputTime, String inputFormatString) {
  try {
    DateFormat inputFormat = DateFormat(inputFormatString);
    DateTime parsedTime = inputFormat.parse(inputTime);
    return parsedTime.toString();
  } catch (e) {
    return inputTime;
  }
}
