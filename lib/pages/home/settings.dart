import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/components/settings/app_info.dart';
import 'package:saber/components/settings/settings_color.dart';
import 'package:saber/components/settings/settings_dropdown.dart';
import 'package:saber/components/settings/settings_selection.dart';
import 'package:saber/components/settings/settings_subtitle.dart';
import 'package:saber/components/settings/settings_switch.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_toggle_buttons.dart';
import 'package:saber/data/editor/pencil_sound.dart';
import 'package:saber/data/locales.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/packages/stow/stow.dart';

import '../../common/config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  static Future<bool?> showResetDialog({
    required BuildContext context,
    required Stow pref,
    required String prefTitle,
  }) async {
    if (pref.value == pref.defaultValue) return null;
    return await showDialog(
      context: context,
      builder: (context) => AdaptiveAlertDialog(
        title: Text(t.settings.reset.title),
        content: Text(prefTitle),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text(t.common.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              pref.value = pref.defaultValue;
              Get.back(result: true);
            },
            child: Text(t.settings.reset.button),
          ),
        ],
      ),
    );
  }
}

abstract class _SettingsStows {
  static final appTheme = TransformedStow(
    stows.appTheme,
    (ThemeMode value) => value.index,
    (int value) => ThemeMode.values[value],
  );

  static final layoutSize = TransformedStow(
    stows.layoutSize,
    (LayoutSize value) => value.index,
    (int value) => LayoutSize.values[value],
  );

  static final editorToolbarAlignment = TransformedStow(
    stows.editorToolbarAlignment,
    (AxisDirection value) => value.index,
    (int value) => AxisDirection.values[value],
  );

  static final pencilSoundEffect = stows.pencilSoundEffect;
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    stows.locale.addListener(onChanged);

    // UpdateManager.status.addListener(onChanged);
    super.initState();
  }

  void onChanged() {
    setState(() {});
  }

  static const cupertinoDirectionIcons = [
    CupertinoIcons.arrow_up_to_line,
    CupertinoIcons.arrow_right_to_line,
    CupertinoIcons.arrow_down_to_line,
    CupertinoIcons.arrow_left_to_line,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final toggleBtnTextStyle = const TextStyle(
      fontSize: Cfg.fontBodySmall,
    );
    // final bool requiresManualUpdates = FlavorConfig.appStore.isEmpty;

    // final IconData materialIcon = switch (defaultTargetPlatform) {
    //   TargetPlatform.windows => FontAwesomeIcons.windows,
    //   _ => Icons.android,
    // };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              bottom: 8,
            ),
            sliver: SliverAppBar(
              expandedHeight: kToolbarHeight, // 固定为标准高度，去掉展开效果
              pinned: true,
              scrolledUnderElevation: 1,
              title: Text(
                t.home.titles.settings,
                style: TextStyle(color: colorScheme.onSurface),
              ),
              centerTitle: true,
              actions: [
                // if (UpdateManager.status.value != UpdateStatus.upToDate)
                //   IconButton(
                //     tooltip: t.home.tooltips.showUpdateDialog,
                //     icon: const Icon(Icons.system_update),
                //     onPressed: () {
                //       UpdateManager.showUpdateDialog(context,
                //           userTriggered: true);
                //     },
                //   ),
              ],
            ),
          ),
          SliverSafeArea(
              sliver: SliverList.list(
            children: [
              // disable nextcloud profile for now
              // const NextcloudProfile(),
              // const Padding(
              //   padding: EdgeInsets.all(8),
              //   child: AppInfo(),
              // ),
              // const AppInfo(),
              SettingsSubtitle(
                subtitle: t.settings.prefCategories.general,
                topPadding: false,
              ),
              SettingsDropdown(
                title: t.settings.prefLabels.locale,
                icon: CupertinoIcons.globe,
                pref: stows.locale,
                options: [
                  ToggleButtonsOption('', Text(t.settings.systemLanguage, style: toggleBtnTextStyle,)),
                  ...AppLocaleUtils.supportedLocales.map((locale) {
                    final String localeCode = locale.toLanguageTag();
                    String? localeName = localeNames[localeCode];
                    assert(localeName != null,
                        'Missing locale name for $localeCode');
                    return ToggleButtonsOption(
                      localeCode,
                      Text(localeName ?? localeCode, style: toggleBtnTextStyle),
                    );
                  }),
                ],
              ),
              SettingsSelection(
                title: t.settings.prefLabels.appTheme,
                iconBuilder: (i) {
                  if (i == ThemeMode.system.index) return Icons.brightness_auto;
                  if (i == ThemeMode.light.index) return Icons.light_mode;
                  if (i == ThemeMode.dark.index) return Icons.dark_mode;
                  return null;
                },
                pref: _SettingsStows.appTheme,
                optionsWidth: 60,
                options: [
                  ToggleButtonsOption(
                      ThemeMode.system.index,
                      Icon(Icons.brightness_auto,
                          semanticLabel: t.settings.themeModes.system)),
                  ToggleButtonsOption(
                      ThemeMode.light.index,
                      Icon(Icons.light_mode,
                          semanticLabel: t.settings.themeModes.light)),
                  ToggleButtonsOption(
                      ThemeMode.dark.index,
                      Icon(Icons.dark_mode,
                          semanticLabel: t.settings.themeModes.dark)),
                ],
              ),

              // SettingsSelection(
              //   title: t.settings.prefLabels.platform,
              //   iconBuilder: (i) => switch (stows.platform.value) {
              //     TargetPlatform.iOS || TargetPlatform.macOS => Icons.apple,
              //     TargetPlatform.linux => FontAwesomeIcons.ubuntu,
              //     _ => materialIcon,
              //   },
              //   pref: _SettingsStows.platform,
              //   optionsWidth: 60,
              //   options: [
              //     ToggleButtonsOption(
              //       () {
              //         if (usesMaterialByDefault)
              //           return defaultTargetPlatform.index;
              //         return TargetPlatform.android.index;
              //       }(),
              //       Icon(materialIcon, semanticLabel: 'Material'),
              //     ),
              //     ToggleButtonsOption(
              //       () {
              //         // Hack to allow screenshot golden tests
              //         if (kDebugMode &&
              //             (stows.platform.value == TargetPlatform.iOS ||
              //                 stows.platform.value == TargetPlatform.macOS))
              //           return stows.platform.value.index;
              //         if (usesCupertinoByDefault)
              //           return defaultTargetPlatform.index;
              //         return TargetPlatform.iOS.index;
              //       }(),
              //       const Icon(Icons.apple, semanticLabel: 'Cupertino'),
              //     ),
              //     ToggleButtonsOption(
              //       () {
              //         if (usesYaruByDefault) return defaultTargetPlatform.index;
              //         return TargetPlatform.linux.index;
              //       }(),
              //       const Icon(FontAwesomeIcons.ubuntu, semanticLabel: 'Yaru'),
              //     ),
              //   ],
              // ),

              SettingsSelection(
                title: t.settings.prefLabels.layoutSize,
                subtitle: switch (stows.layoutSize.value) {
                  LayoutSize.auto => t.settings.layoutSizes.auto,
                  LayoutSize.phone => t.settings.layoutSizes.phone,
                  LayoutSize.tablet => t.settings.layoutSizes.tablet,
                },
                afterChange: (_) => setState(() {}),
                iconBuilder: (i) => switch (LayoutSize.values[i]) {
                  LayoutSize.auto => Icons.aspect_ratio,
                  LayoutSize.phone => Icons.smartphone,
                  LayoutSize.tablet => Icons.tablet,
                },
                pref: _SettingsStows.layoutSize,
                optionsWidth: 60,
                options: [
                  ToggleButtonsOption(
                      LayoutSize.auto.index,
                      Icon(Icons.aspect_ratio,
                          semanticLabel: t.settings.layoutSizes.auto)),
                  ToggleButtonsOption(
                      LayoutSize.phone.index,
                      Icon(Icons.smartphone,
                          semanticLabel: t.settings.layoutSizes.phone)),
                  ToggleButtonsOption(
                      LayoutSize.tablet.index,
                      Icon(Icons.tablet,
                          semanticLabel: t.settings.layoutSizes.tablet)),
                ],
              ),
              SettingsColor(
                title: t.settings.prefLabels.customAccentColor,
                icon: Icons.colorize,
                pref: stows.accentColor,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.hyperlegibleFont,
                subtitle: t.settings.prefDescriptions.hyperlegibleFont,
                iconBuilder: (b) {
                  if (b)
                    return CupertinoIcons.textformat;
                  return CupertinoIcons.textformat_alt;
                },
                pref: stows.hyperlegibleFont,
              ),
              SettingsSubtitle(subtitle: t.settings.prefCategories.writing),
              SettingsSwitch(
                title: t.settings.prefLabels.preferGreyscale,
                subtitle: t.settings.prefDescriptions.preferGreyscale,
                iconBuilder: (b) {
                  return b
                      ? Icons.monochrome_photos
                      : Icons.enhance_photo_translate;
                },
                pref: stows.preferGreyscale,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.autoClearWhiteboardOnExit,
                subtitle: t.settings.prefDescriptions.autoClearWhiteboardOnExit,
                icon: Icons.cleaning_services,
                pref: stows.autoClearWhiteboardOnExit,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.disableEraserAfterUse,
                subtitle: t.settings.prefDescriptions.disableEraserAfterUse,
                icon: FontAwesomeIcons.eraser,
                pref: stows.disableEraserAfterUse,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.hideFingerDrawingToggle,
                subtitle: () {
                  if (!stows.hideFingerDrawingToggle.value) {
                    return t.settings.prefDescriptions.hideFingerDrawing.shown;
                  } else if (stows.editorFingerDrawing.value) {
                    return t
                        .settings.prefDescriptions.hideFingerDrawing.fixedOn;
                  } else {
                    return t
                        .settings.prefDescriptions.hideFingerDrawing.fixedOff;
                  }
                }(),
                icon: CupertinoIcons.hand_draw,
                pref: stows.hideFingerDrawingToggle,
                afterChange: (_) => setState(() {}),
              ),
              SettingsSubtitle(subtitle: t.settings.prefCategories.editor),
              SettingsSelection(
                title: t.settings.prefLabels.editorToolbarAlignment,
                subtitle: t.settings.axisDirections[
                    _SettingsStows.editorToolbarAlignment.value],
                iconBuilder: (num i) {
                  if (i is! int || i >= cupertinoDirectionIcons.length)
                    return null;
                  return cupertinoDirectionIcons[i];
                },
                pref: _SettingsStows.editorToolbarAlignment,
                optionsWidth: 60,
                options: [
                  for (final AxisDirection direction in AxisDirection.values)
                    ToggleButtonsOption(
                      direction.index,
                      Icon(
                        cupertinoDirectionIcons[direction.index],
                        semanticLabel:
                            t.settings.axisDirections[direction.index],
                      ),
                    ),
                ],
                afterChange: (_) => setState(() {}),
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorToolbarShowInFullscreen,
                icon: CupertinoIcons.fullscreen,
                pref: stows.editorToolbarShowInFullscreen,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorAutoInvert,
                iconBuilder: (b) {
                  return b ? Icons.invert_colors_on : Icons.invert_colors_off;
                },
                pref: stows.editorAutoInvert,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.editorPromptRename,
                subtitle: t.settings.prefDescriptions.editorPromptRename,
                iconBuilder: (b) {
                  if (b)
                    return CupertinoIcons.keyboard;
                  return CupertinoIcons.keyboard_chevron_compact_down;
                },
                pref: stows.editorPromptRename,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.hideHomeBackgrounds,
                subtitle: t.settings.prefDescriptions.hideHomeBackgrounds,
                iconBuilder: (b) {
                  if (b) return CupertinoIcons.photo;
                  return CupertinoIcons.photo_fill;
                },
                pref: stows.hideHomeBackgrounds,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.recentColorsDontSavePresets,
                icon: Icons.palette,
                pref: stows.recentColorsDontSavePresets,
              ),
              SettingsSelection(
                title: t.settings.prefLabels.recentColorsLength,
                icon: Icons.history,
                pref: stows.recentColorsLength,
                options: [
                  ToggleButtonsOption(5, Text('5', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(10, Text('10', style: toggleBtnTextStyle)),
                ],
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.printPageIndicators,
                subtitle: t.settings.prefDescriptions.printPageIndicators,
                icon: Icons.numbers,
                pref: stows.printPageIndicators,
              ),

              SettingsSwitch(
                title: t.settings.prefLabels.pencilSoundSetting,
                // subtitle: stows.pencilSoundEffect.value
                //     ? t.settings.prefDescriptions.pencilSoundSetting.onAlways
                //     : t.settings.prefDescriptions.pencilSoundSetting.off,
                icon: stows.pencilSoundEffect.value 
                    ? FontAwesomeIcons.solidBell
                    : FontAwesomeIcons.bellSlash,
                pref: _SettingsStows.pencilSoundEffect,
                afterChange: (_) {
                  PencilSound.setAudioContext();
                  setState(() {});
                },
              ),
              SettingsSubtitle(subtitle: t.settings.prefCategories.performance),
              SettingsSelection(
                title: t.settings.prefLabels.maxImageSize,
                subtitle: t.settings.prefDescriptions.maxImageSize,
                icon: Icons.photo_size_select_large,
                pref: stows.maxImageSize,
                options: <ToggleButtonsOption<double>>[
                  ToggleButtonsOption(500, Text('500', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(1000, Text('1000', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(2000, Text('2000', style: toggleBtnTextStyle)),
                ],
              ),
              SettingsSelection(
                title: t.settings.prefLabels.autosave,
                subtitle: t.settings.prefDescriptions.autosave,
                icon: Icons.save,
                pref: stows.autosaveDelay,
                options: [
                  ToggleButtonsOption(5000, Text('5s', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(10000, Text('10s', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(-1, Text(t.settings.autosaveDisabled, style: toggleBtnTextStyle)),
                ],
              ),
              SettingsSelection(
                title: t.settings.prefLabels.shapeRecognitionDelay,
                subtitle: t.settings.prefDescriptions.shapeRecognitionDelay,
                icon: FontAwesomeIcons.shapes,
                pref: stows.shapeRecognitionDelay,
                options: [
                  ToggleButtonsOption(500, Text('0.5s', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(1000, Text('1s', style: toggleBtnTextStyle)),
                  ToggleButtonsOption(
                      -1, Text(t.settings.shapeRecognitionDisabled, style: toggleBtnTextStyle)),
                ],
                afterChange: (ms) {
                  ShapePen.debounceDuration = ShapePen.getDebounceFromPref();
                },
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.autoStraightenLines,
                subtitle: t.settings.prefDescriptions.autoStraightenLines,
                icon: Icons.straighten,
                pref: stows.autoStraightenLines,
              ),
              SettingsSwitch(
                title: t.settings.prefLabels.simplifiedHomeLayout,
                subtitle: t.settings.prefDescriptions.simplifiedHomeLayout,
                iconBuilder: (simplified) =>
                    simplified ? Icons.grid_view : Symbols.browse,
                pref: stows.simplifiedHomeLayout,
              ),

              // TODO 通用 -》用户隐私 / 服务协议
              // SettingsSubtitle(subtitle: t.settings.prefCategories.advanced),

              // if (isSentryAvailable) const SettingsSentryConsent(),
              // disable data directory setting
              // if (Platform.isAndroid)
              //   SettingsDirectorySelector(
              //     title: t.settings.prefLabels.customDataDir,
              //     icon: Icons.folder,
              //   ),
              // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              //   SettingsButton(
              //     title: t.settings.openDataDir,
              //     icon: Icons.folder_open,
              //     onPressed: () {
              //       if (Platform.isWindows) {
              //         Process.run('explorer', [FileManager.documentsDirectory]);
              //       } else if (Platform.isLinux) {
              //         Process.run('xdg-open', [FileManager.documentsDirectory]);
              //       } else if (Platform.isMacOS) {
              //         Process.run('open', [FileManager.documentsDirectory]);
              //       }
              //     },
              //   ),
              // if (requiresManualUpdates ||
              //     stows.shouldCheckForUpdates.value !=
              //         stows.shouldCheckForUpdates.defaultValue) ...[
              //   SettingsSwitch(
              //     title: t.settings.prefLabels.shouldCheckForUpdates,
              //     icon: Icons.system_update,
              //     pref: stows.shouldCheckForUpdates,
              //     afterChange: (_) => setState(() {}),
              //   ),
              //   Collapsible(
              //     collapsed: !stows.shouldCheckForUpdates.value,
              //     axis: CollapsibleAxis.vertical,
              //     child: SettingsSwitch(
              //       title: t.settings.prefLabels.shouldAlwaysAlertForUpdates,
              //       subtitle:
              //           t.settings.prefDescriptions.shouldAlwaysAlertForUpdates,
              //       icon: Icons.system_security_update_warning,
              //       pref: stows.shouldAlwaysAlertForUpdates,
              //     ),
              //   ),
              // ],
              // TODO disable for now, re-enable when supporting server
              // SettingsSwitch(
              //   title: t.settings.prefLabels.allowInsecureConnections,
              //   subtitle: t.settings.prefDescriptions.allowInsecureConnections,
              //   icon: Icons.private_connectivity,
              //   pref: stows.allowInsecureConnections,
              // ),
              // do not show logs for now
              // SettingsButton(
              //   title: t.logs.viewLogs,
              //   subtitle: t.logs.debuggingInfo,
              //   icon: Icons.receipt_long,
              //   onPressed: () => context.push(RoutePaths.logs),
              // ),
            ],
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stows.locale.removeListener(onChanged);
    // UpdateManager.status.removeListener(onChanged);
    super.dispose();
  }
}
