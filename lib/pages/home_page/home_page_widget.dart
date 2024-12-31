import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import '../result_page/result_page.dart';
import '../../services/face_analysis_service.dart';
import '../../services/saju_service.dart';
import 'custom_time_picker.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Uint8List? _selectedImage;
  String? selectedGender;
  bool _isAnalyzing = false;

  final FaceAnalysisService _faceAnalysisService = FaceAnalysisService();
  final SajuService _sajuService = SajuService();

  Future<void> _analyze() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진을 선택해주세요')),
      );
      return;
    }

    if (_model.textController1?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름을 입력해주세요')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생년월일을 선택해주세요')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('출생 시각을 선택해주세요')),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('성별을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // 관상 분석
      final faceAnalysis = await _faceAnalysisService.analyzeFace(_selectedImage!);
      
      // 사주 분석
      final sajuAnalysis = _sajuService.calculateSaju(selectedDate!, selectedTime!.hour);

      if (!mounted) return;

      // 결과 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            faceAnalysis: faceAnalysis,
            sajuAnalysis: sajuAnalysis,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            colorScheme: ColorScheme.light(primary: Colors.black),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _model.textController2?.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay initialTime = selectedTime ?? TimeOfDay.now();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Custom24HourTimePicker(
          initialTime: initialTime,
          onTimeSelected: (TimeOfDay picked) {
            if (mounted) {
              setState(() {
                selectedTime = picked;
                _model.textController3?.text = "${picked.hour.toString().padLeft(2, '0')}시";
                _model.textController3?.selection = TextSelection.fromPosition(
                  TextPosition(offset: _model.textController3?.text.length ?? 0),
                );
              });
            }
          },
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await ImagePickerWeb.getImageAsBytes();
      if (result != null) {
        setState(() {
          _selectedImage = result;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textFieldFocusNode3 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xD9F4F4F4),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Material(
                        color: Colors.transparent,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(75.0),
                        ),
                        child: Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(75.0),
                          ),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(75.0),
                                  child: _selectedImage != null
                                      ? Image.memory(
                                          _selectedImage!,
                                          width: 150.0,
                                          height: 150.0,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          'https://cdn.electimes.com/news/photo/202412/348348_553689_1310.jpg',
                                          width: 150.0,
                                          height: 150.0,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Container(
                                  width: 150.0,
                                  height: 150.0,
                                  decoration: BoxDecoration(
                                    color: Color(0x33000000),
                                    borderRadius: BorderRadius.circular(75.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 40.0,
                                        ),
                                        Text(
                                          '사진 추가',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                20.0, 20.0, 20.0, 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: TextFormField(
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: '이름',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: Color(0xFF606A85),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: Color(0xFF606A85),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFE0E0E0),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF6F61EF),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      contentPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              20.0, 32.0, 20.0, 12.0),
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: Color(0xFF15161E),
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    textAlign: TextAlign.start,
                                    validator: _model.textController1Validator,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.textController2,
                                          focusNode: _model.textFieldFocusNode2,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: '생년월일',
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.0,
                                            ),
                                            hintText: 'YYYY-MM-DD',
                                            hintStyle: TextStyle(
                                              color: Colors.black54,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                Icons.calendar_today,
                                                color: Colors.black,
                                              ),
                                              onPressed: () => _selectDate(context),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xD9F4F4F4),
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        child: TextFormField(
                                          controller: _model.textController3,
                                          focusNode: _model.textFieldFocusNode3,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: '출생 시각',
                                            labelStyle: TextStyle(
                                              color: Colors.black54,
                                            ),
                                            hintText: '시간을 선택하세요',
                                            hintStyle: TextStyle(
                                              color: Colors.black54,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                Icons.access_time,
                                                color: Colors.black54,
                                              ),
                                              onPressed: () => _selectTime(context),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xD9F4F4F4),
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '성별',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: Color(0xFF606A85),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: [
                                      ChoiceChip(
                                        label: Text('남성'),
                                        selected: selectedGender == '남성',
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedGender = selected ? '남성' : null;
                                          });
                                        },
                                      ),
                                      ChoiceChip(
                                        label: Text('여성'),
                                        selected: selectedGender == '여성',
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedGender = selected ? '여성' : null;
                                          });
                                        },
                                      ),
                                      ChoiceChip(
                                        label: Text('MTF'),
                                        selected: selectedGender == 'MTF',
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedGender = selected ? 'MTF' : null;
                                          });
                                        },
                                      ),
                                      ChoiceChip(
                                        label: Text('기타'),
                                        selected: selectedGender == '기타',
                                        onSelected: (bool selected) {
                                          setState(() {
                                            selectedGender = selected ? '기타' : null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 24.0, 0, 0),
                        child: FFButtonWidget(
                          onPressed: _isAnalyzing ? null : _analyze,
                          text: _isAnalyzing ? '분석 중...' : '분석하기',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 50.0,
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: Colors.black,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                            elevation: 2.0,
                            borderRadius: BorderRadius.circular(8.0),
                            disabledColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '해당 시스템은  오행의 상생상극 관계를 고려한 분석, 60갑자를 활용한 딥러닝 모델을 구현하여 제공하고있습니다.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        '.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Inter',
                              letterSpacing: 0.0,
                            ),
                      ),
                      Text(
                        '입력된 데이터는 휘발성 메모리에 저장되어 개인정보보호를 위해 창을 닫는 즉시 폐기됩니다.',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Inter',
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
