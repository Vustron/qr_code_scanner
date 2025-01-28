String getRelativeTime(DateTime dateTime) {
  final Duration difference = DateTime.now().difference(dateTime);
  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

String formatLabel(String isoDateWithUuid) {
  try {
    final List<String> parts = isoDateWithUuid.split('Z');
    if (parts.length < 2) return isoDateWithUuid;

    final DateTime date = DateTime.parse('${parts[0]}Z').toLocal();
    final String formattedDate = '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.year}';

    final String uuid = parts[1].substring(0, 10);

    return '$formattedDate-$uuid';
  } catch (_) {
    return isoDateWithUuid;
  }
}
