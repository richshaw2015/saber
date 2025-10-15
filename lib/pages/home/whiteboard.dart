import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

class Whiteboard extends StatefulWidget {
  const Whiteboard({super.key});

  static const String filePath = '/_whiteboard';

  static bool needsToAutoClearWhiteboard =
      stows.autoClearWhiteboardOnExit.value;

  static final _whiteboardKey =
      GlobalKey<EditorState>(debugLabel: 'whiteboard');

  static SavingState? get savingState =>
      _whiteboardKey.currentState?.savingState.value;
  static void triggerSave() {
    final editorState = _whiteboardKey.currentState;
    if (editorState == null) return;
    assert(editorState.savingState.value == SavingState.waitingToSave);
    editorState.saveToFile();
    editorState.snackBarNeedsToSaveBeforeExiting();
  }

  @override
  State<Whiteboard> createState() => _WhiteboardState();
}

class _WhiteboardState extends State<Whiteboard> {
  @override
  void initState() {
    super.initState();

    // 监听影响白板显示的设置变化
    stows.editorToolbarAlignment.addListener(_onSettingsChanged);
    stows.editorToolbarShowInFullscreen.addListener(_onSettingsChanged);
    stows.editorFingerDrawing.addListener(_onSettingsChanged);
    stows.editorAutoInvert.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    // 移除监听器
    stows.editorToolbarAlignment.removeListener(_onSettingsChanged);
    stows.editorToolbarShowInFullscreen.removeListener(_onSettingsChanged);
    stows.editorFingerDrawing.removeListener(_onSettingsChanged);
    stows.editorAutoInvert.removeListener(_onSettingsChanged);

    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // 触发重建，应用新的设置
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Editor(
      key: Whiteboard._whiteboardKey,
      path: Whiteboard.filePath,
      customTitle: t.home.titles.whiteboard,
    );
  }
}
