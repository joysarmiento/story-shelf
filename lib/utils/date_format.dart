/// A minimal "August 16, 2020" formatter, so screens don't need to add the
/// intl package just for this one format. Swap this for package:intl's
/// DateFormat later if you end up needing locale-aware formatting elsewhere.
String formatLongDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
