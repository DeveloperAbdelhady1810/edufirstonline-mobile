/// Mirrors the backend's `config/education.php` exactly (stage/grade keys and
/// subject keys are not exposed by any API endpoint, so this is a deliberate
/// client-side mirror of existing config data for dropdowns/labels - not a
/// new backend concept). Keep in sync if that config file ever changes.
class EducationGrade {
  const EducationGrade({required this.key, required this.nameAr});

  final String key;
  final String nameAr;
}

class EducationStage {
  const EducationStage({
    required this.key,
    required this.nameAr,
    required this.grades,
  });

  final String key;
  final String nameAr;
  final List<EducationGrade> grades;
}

class EducationData {
  EducationData._();

  static const List<EducationStage> stages = [
    EducationStage(
      key: 'preparatory',
      nameAr: 'اعدادي',
      grades: [
        EducationGrade(key: 'grade_1', nameAr: 'اولى اعدادي'),
        EducationGrade(key: 'grade_2', nameAr: 'تانية اعدادي'),
        EducationGrade(key: 'grade_3', nameAr: 'تالتة اعدادي'),
      ],
    ),
    EducationStage(
      key: 'secondary',
      nameAr: 'ثانوي',
      grades: [
        EducationGrade(key: 'grade_1', nameAr: 'اولى ثانوي'),
        EducationGrade(key: 'grade_2', nameAr: 'تانية ثانوي'),
        EducationGrade(key: 'grade_3', nameAr: 'تالتة ثانوي'),
      ],
    ),
  ];

  static const Map<String, String> subjects = {
    'mathematics': 'رياضيات',
    'physics': 'فيزياء',
    'chemistry': 'كيمياء',
    'biology': 'أحياء',
    'arabic': 'عربي',
    'english': 'إنجليزي',
    'french': 'فرنساوي',
    'history': 'تاريخ',
    'geography': 'جغرافيا',
    'philosophy': 'فلسفة',
    'geology': 'جيولوجيا',
    'psychology': 'علم نفس',
    'computer_science': 'حاسب آلي',
    'economics': 'اقتصاد',
    'accounting': 'محاسبة',
    'statistics': 'إحصاء',
  };

  /// Falls back to the raw key when a subject isn't in the map, so an
  /// unexpected/new backend value never crashes the UI - it just shows
  /// slightly less pretty text instead of an error.
  static String subjectLabel(String? key) {
    if (key == null) return '';
    return subjects[key] ?? key;
  }
}
