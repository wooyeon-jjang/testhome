import 'package:lunar/lunar.dart';

class SajuService {
  final List<String> heavenlyStems = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
  final List<String> earthlyBranches = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
  
  Map<String, dynamic> calculateSaju(DateTime birthDate, int birthHour) {
    try {
      // 음력 날짜 계산
      final solar = Solar.fromDate(birthDate);
      final lunar = Lunar.fromSolar(solar);
      
      // 사주 팔자 계산
      final year = lunar.getYear();
      final month = lunar.getMonth();
      
      final yearStem = heavenlyStems[(year - 4) % 10];
      final yearBranch = earthlyBranches[(year - 4) % 12];
      
      final monthStem = heavenlyStems[((year * 2 + month + 1) % 10)];
      final monthBranch = earthlyBranches[(month + 1) % 12];
      
      final dayStem = heavenlyStems[(birthDate.difference(DateTime(1900, 1, 1)).inDays + 10) % 10];
      final dayBranch = earthlyBranches[(birthDate.difference(DateTime(1900, 1, 1)).inDays + 2) % 12];
      
      final hourStem = heavenlyStems[((birthDate.difference(DateTime(1900, 1, 1)).inDays * 2) + (birthHour ~/ 2) + 1) % 10];
      final hourBranch = earthlyBranches[birthHour ~/ 2];

      return {
        'success': true,
        'data': {
          'year': '$yearStem$yearBranch',
          'month': '$monthStem$monthBranch',
          'day': '$dayStem$dayBranch',
          'hour': '$hourStem$hourBranch',
        },
        'interpretation': _interpretSaju('$yearStem$yearBranch', '$monthStem$monthBranch', 
                                      '$dayStem$dayBranch', '$hourStem$hourBranch'),
      };
    } catch (e) {
      return {
        'success': false,
        'error': '사주 계산 중 오류가 발생했습니다: $e',
      };
    }
  }

  String _interpretSaju(String year, String month, String day, String hour) {
    // 기본적인 사주 해석
    return '''
사주팔자 분석 결과:
년주: $year - ${_interpretPillar(year)}
월주: $month - ${_interpretPillar(month)}
일주: $day - ${_interpretPillar(day)}
시주: $hour - ${_interpretPillar(hour)}

종합 해석:
• 당신의 기본 성향과 타고난 기질을 나타내는 년주는 $year입니다.
• 성장 과정과 배움의 성향을 나타내는 월주는 $month입니다.
• 현재의 모습과 의식을 나타내는 일주는 $day입니다.
• 숨겨진 잠재력과 미래의 방향성을 나타내는 시주는 $hour입니다.

''';
  }

  String _interpretPillar(String pillar) {
    // 각 기둥별 기본 해석
    final stem = pillar[0];
    final branch = pillar[1];
    
    return '''이 기둥은 ${_getStemMeaning(stem)}의 기운과 ${_getBranchMeaning(branch)}의 특성을 가지고 있어, 
${_getCombinedMeaning(stem, branch)}의 성향을 나타냅니다.''';
  }

  String _getStemMeaning(String stem) {
    final meanings = {
      '갑': '진취적이고 창의적인',
      '을': '유연하고 포용력 있는',
      '병': '밝고 활기찬',
      '정': '정직하고 올바른',
      '무': '침착하고 안정적인',
      '기': '신중하고 성실한',
      '경': '예술적이고 섬세한',
      '신': '실용적이고 현실적인',
      '임': '지도력 있고 카리스마 있는',
      '계': '지혜롭고 통찰력 있는',
    };
    return meanings[stem] ?? '독특한';
  }

  String _getBranchMeaning(String branch) {
    final meanings = {
      '자': '지혜로운',
      '축': '안정적인',
      '인': '활동적인',
      '묘': '창의적인',
      '진': '진취적인',
      '사': '적응력 있는',
      '오': '열정적인',
      '미': '섬세한',
      '신': '변화무쌍한',
      '유': '우아한',
      '술': '결단력 있는',
      '해': '포용력 있는',
    };
    return meanings[branch] ?? '특별한';
  }

  String _getCombinedMeaning(String stem, String branch) {
    return '${_getStemMeaning(stem)}과 ${_getBranchMeaning(branch)}이 조화를 이루는';
  }

  String _getGeneralInterpretation(String year, String month, String day, String hour) {
    return '''
종합적으로 볼 때, 당신은:
• 타고난 재능과 잠재력이 풍부한 사람입니다.
• 주변 사람들과의 관계에서 조화를 이루며 살아갈 수 있는 기운을 가지고 있습니다.
• 현재의 어려움은 미래의 성공을 위한 밑거름이 될 것입니다.
• 자신의 직관과 통찰력을 믿고 나아간다면 좋은 결과를 얻을 수 있습니다.

''';
  }
}
