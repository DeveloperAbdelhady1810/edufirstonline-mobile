/// Some backend responses - particularly anything derived from a raw SQL
/// aggregate (AVG/ROUND/COALESCE, or SUM on a decimal column) - come back as
/// numeric-LOOKING STRINGS instead of real JSON numbers, depending on how
/// the MySQL driver infers the PHP type for that expression. A plain
/// `as num?` cast crashes the moment one of those fields is actually a
/// string (confirmed in production: `/my-courses`' `progress` column, which
/// is `coalesce(round(avg(...)), 0)`). These helpers accept either shape so
/// parsing never depends on that driver-level detail.
int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  return null;
}

num? asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}
