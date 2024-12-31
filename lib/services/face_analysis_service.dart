import 'dart:typed_data';
import 'dart:math' as math;
import '../constants/face_analysis_presets.dart';

class FaceAnalysisService {
  Future<Map<String, dynamic>> analyzeFace(Uint8List imageBytes) async {
    try {
      final random = math.Random();
      final StringBuffer interpretation = StringBuffer();
      
      // 관상 분석 결과 헤더
      interpretation.writeln('🔮 관상 분석 결과\n');
      
      // 각 얼굴 부위별로 랜덤하게 하나의 해석 선택
      FaceAnalysisPresets.facePartTraits.forEach((part, traits) {
        final List<String> traitsList = List<String>.from(traits);
        traitsList.shuffle(random);
        interpretation.writeln('• $part: ${traitsList.first}');
      });
      
      // 운세 해석 (3개 선택)
      interpretation.writeln('\n✨ 운세 분석\n');
      final List<String> fortuneList = List<String>.from(FaceAnalysisPresets.fortuneTraits);
      fortuneList.shuffle(random);
      fortuneList.take(3).forEach((trait) {
        interpretation.writeln('• $trait');
      });
      
      // 조언 (3개 선택)
      interpretation.writeln('\n💫 조언\n');
      final List<String> adviceList = List<String>.from(FaceAnalysisPresets.adviceTraits);
      adviceList.shuffle(random);
      adviceList.take(3).forEach((advice) {
        interpretation.writeln('• $advice');
      });

      return {
        'success': true,
        'analysis': interpretation.toString(),
      };
    } catch (e, stackTrace) {
      print('Face analysis error: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': '관상 분석 중 오류가 발생했습니다: $e',
      };
    }
  }
}
