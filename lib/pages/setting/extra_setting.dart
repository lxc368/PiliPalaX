import 'dart:math';

import 'package:PiliPalaX/pages/main/controller.dart';
import 'package:PiliPalaX/pages/member/new/controller.dart'
    show MemberTabType, MemberTabTypeExt;
import 'package:PiliPalaX/utils/global_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/models/common/dynamics_type.dart';
import 'package:PiliPalaX/models/common/reply_sort_type.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../home/index.dart';
import 'controller.dart';
import 'widgets/switch_item.dart';

class ExtraSetting extends StatefulWidget {
  const ExtraSetting({super.key});

  @override
  State<ExtraSetting> createState() => _ExtraSettingState();
}

class _ExtraSettingState extends State<ExtraSetting> {
  final SettingController settingController = Get.put(SettingController());
  late dynamic defaultReplySort;
  late dynamic defaultDynamicType;
  late MemberTabType defaultMemberTab;
  late dynamic enableSystemProxy;
  late String defaultSystemProxyHost;
  late String defaultSystemProxyPort;
  late double danmakuLineHeight = GStorage.danmakuLineHeight;
  bool userLogin = false;

  Box get setting => GStorage.setting;

  @override
  void initState() {
    super.initState();
    // 默认优先显示最新评论
    defaultReplySort =
        setting.get(SettingBoxKey.replySortType, defaultValue: 1);
    if (defaultReplySort == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySort = 0;
    }
    // 优先展示全部动态 all
    defaultDynamicType =
        setting.get(SettingBoxKey.defaultDynamicType, defaultValue: 0);
    defaultMemberTab = GStorage.memberTab;
    enableSystemProxy =
        setting.get(SettingBoxKey.enableSystemProxy, defaultValue: false);
    defaultSystemProxyHost =
        setting.get(SettingBoxKey.systemProxyHost, defaultValue: '');
    defaultSystemProxyPort =
        setting.get(SettingBoxKey.systemProxyPort, defaultValue: '');
  }

  // 设置代理
  void twoFADialog() {
    var systemProxyHost = '';
    var systemProxyPort = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置代理'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  isDense: true,
                  labelText: defaultSystemProxyHost != ''
                      ? defaultSystemProxyHost
                      : '请输入Host，使用 . 分割',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  hintText: defaultSystemProxyHost,
                ),
                onChanged: (e) {
                  systemProxyHost = e;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: defaultSystemProxyPort != ''
                      ? defaultSystemProxyPort
                      : '请输入Port',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  hintText: defaultSystemProxyPort,
                ),
                onChanged: (e) {
                  systemProxyPort = e;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
              },
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                setting.put(SettingBoxKey.systemProxyHost, systemProxyHost);
                setting.put(SettingBoxKey.systemProxyPort, systemProxyPort);
                Get.back();
                // Request.dio;
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(title: Text('其它设置')),
      body: ListView(
        children: [
          SetSwitchItem(
            title: '空降助手',
            subTitle: '点击配置',
            leading: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.shield_outlined),
                Icon(
                  Icons.play_arrow_rounded,
                  size: 15,
                ),
              ],
            ),
            setKey: SettingBoxKey.enableSponsorBlock,
            defaultVal: false,
            onTap: () => Get.toNamed('/sponsorBlock'),
          ),
          SetSwitchItem(
            title: '检查未读动态',
            subTitle: '点击设置检查周期(min)',
            leading: const Icon(Icons.notifications_none),
            setKey: SettingBoxKey.checkDynamic,
            defaultVal: true,
            onChanged: (value) {
              Get.find<MainController>().checkDynamic = value;
            },
            onTap: () {
              int dynamicPeriod = GStorage.dynamicPeriod;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('检查周期', style: TextStyle(fontSize: 18)),
                    content: TextFormField(
                      autofocus: true,
                      initialValue: dynamicPeriod.toString(),
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (value) {
                        dynamicPeriod = int.tryParse(value) ?? 5;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d+')),
                      ],
                      decoration: InputDecoration(suffixText: 'min'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          setting.put(
                              SettingBoxKey.dynamicPeriod, dynamicPeriod);
                          Get.find<MainController>().dynamicPeriod =
                              dynamicPeriod;
                        },
                        child: Text('确定'),
                      )
                    ],
                  );
                },
              );
            },
          ),
          SetSwitchItem(
            title: '使用gRPC加载评论',
            subTitle: '如无法加载评论，可关闭\n非gRPC楼中楼无法定位评论、按热度/时间排序、查看对话',
            leading: SizedBox(
              height: 24,
              width: 24,
              child: Icon(MdiIcons.google, size: 20),
            ),
            setKey: SettingBoxKey.grpcReply,
            defaultVal: true,
            onChanged: (value) {
              GlobalData().grpcReply = value;
            },
          ),
          SetSwitchItem(
            title: '显示视频分段信息',
            leading: Transform.rotate(
              angle: pi / 2,
              child: Icon(MdiIcons.viewHeadline),
            ),
            setKey: SettingBoxKey.showViewPoints,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '视频页显示相关视频',
            leading: Icon(MdiIcons.motionPlayOutline),
            setKey: SettingBoxKey.showRelatedVideo,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '显示视频评论',
            leading: Icon(MdiIcons.commentTextOutline),
            setKey: SettingBoxKey.showVideoReply,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '显示番剧评论',
            leading: Icon(MdiIcons.commentTextOutline),
            setKey: SettingBoxKey.showBangumiReply,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '默认展开视频简介',
            leading: const Icon(Icons.expand_more),
            setKey: SettingBoxKey.alwaysExapndIntroPanel,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: '横屏自动展开视频简介',
            leading: const Icon(Icons.expand_more),
            setKey: SettingBoxKey.exapndIntroPanelH,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: '横屏分P/合集列表显示在Tab栏',
            leading: const Icon(Icons.format_list_numbered_rtl_sharp),
            setKey: SettingBoxKey.horizontalSeasonPanel,
            defaultVal: false,
          ),
          SetSwitchItem(
            title: '横屏播放页在侧栏打开UP主页',
            leading: const Icon(Icons.account_circle_outlined),
            setKey: SettingBoxKey.horizontalMemberPage,
            defaultVal: false,
          ),
          ListTile(
            title: Text('评论折叠行数', style: titleStyle),
            subtitle: Text('0行为不折叠', style: subTitleStyle),
            leading: const Icon(Icons.compress),
            trailing: Text(
              '${GlobalData().replyLengthLimit.toString()}行',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: () {
              String replyLengthLimit =
                  GlobalData().replyLengthLimit.toString();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('评论折叠行数', style: TextStyle(fontSize: 18)),
                    content: TextFormField(
                      autofocus: true,
                      initialValue: replyLengthLimit,
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (value) {
                        replyLengthLimit = value;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'\d+')),
                      ],
                      decoration: InputDecoration(suffixText: '行'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.back();
                          GlobalData().replyLengthLimit =
                              int.tryParse(replyLengthLimit) ?? 6;
                          await setting.put(
                            SettingBoxKey.replyLengthLimit,
                            GlobalData().replyLengthLimit,
                          );
                          setState(() {});
                        },
                        child: Text('确定'),
                      )
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('弹幕行高', style: titleStyle),
            subtitle: Text('默认1.6', style: subTitleStyle),
            leading: const Icon(Icons.subtitles_outlined),
            trailing: Text(
              danmakuLineHeight.toString(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: () {
              String danmakuLineHeight = this.danmakuLineHeight.toString();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('弹幕行高', style: TextStyle(fontSize: 18)),
                    content: TextFormField(
                      autofocus: true,
                      initialValue: danmakuLineHeight,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        danmakuLineHeight = value;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d\.]+')),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.back();
                          this.danmakuLineHeight = max(
                            1.0,
                            double.tryParse(danmakuLineHeight) ?? 1.6,
                          );
                          await setting.put(
                            SettingBoxKey.danmakuLineHeight,
                            this.danmakuLineHeight,
                          );
                          setState(() {});
                        },
                        child: Text('确定'),
                      )
                    ],
                  );
                },
              );
            },
          ),
          SetSwitchItem(
            title: '显示视频警告/争议信息',
            leading: const Icon(Icons.warning_amber_rounded),
            setKey: SettingBoxKey.showArgueMsg,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '分P/合集：倒序播放从首集开始播放',
            subTitle: '开启则自动切换为倒序首集，否则保持当前集',
            leading: Icon(MdiIcons.sort),
            setKey: SettingBoxKey.reverseFromFirst,
            defaultVal: true,
          ),
          Obx(
            () => ListTile(
              enableFeedback: true,
              onTap: settingController.onOpenFeedBack,
              leading: const Icon(Icons.vibration_outlined),
              title: Text('震动反馈', style: titleStyle),
              subtitle: Text('请确定手机设置中已开启震动反馈', style: subTitleStyle),
              trailing: Transform.scale(
                alignment: Alignment.centerRight,
                scale: 0.8,
                child: Switch(
                    thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                        (Set<WidgetState> states) {
                      if (states.isNotEmpty &&
                          states.first == WidgetState.selected) {
                        return const Icon(Icons.done);
                      }
                      return null; // All other states will use the default thumbIcon.
                    }),
                    value: settingController.feedBackEnable.value,
                    onChanged: (value) => settingController.onOpenFeedBack()),
              ),
            ),
          ),
          const SetSwitchItem(
            title: '大家都在搜',
            subTitle: '是否展示「大家都在搜」',
            leading: Icon(Icons.data_thresholding_outlined),
            setKey: SettingBoxKey.enableHotKey,
            defaultVal: true,
          ),
          SetSwitchItem(
            title: '搜索默认词',
            subTitle: '是否展示搜索框默认词',
            leading: const Icon(Icons.whatshot_outlined),
            setKey: SettingBoxKey.enableSearchWord,
            defaultVal: true,
            onChanged: (val) {
              Get.find<HomeController>().defaultSearch.value = '';
            },
          ),
          const SetSwitchItem(
            title: '快速收藏',
            subTitle: '点按收藏至默认，长按选择文件夹',
            leading: Icon(Icons.bookmark_add_outlined),
            setKey: SettingBoxKey.enableQuickFav,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '评论区搜索关键词',
            subTitle: '展示评论区搜索关键词',
            leading: Icon(Icons.search_outlined),
            setKey: SettingBoxKey.enableWordRe,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '启用AI总结',
            subTitle: '视频详情页开启AI总结',
            leading: Icon(Icons.engineering_outlined),
            setKey: SettingBoxKey.enableAi,
            defaultVal: true,
          ),
          const SetSwitchItem(
            title: '消息页禁用"收到的赞"功能',
            subTitle: '禁止打开入口，降低网络社交依赖',
            leading: Icon(Icons.beach_access_outlined),
            setKey: SettingBoxKey.disableLikeMsg,
            defaultVal: false,
          ),
          const SetSwitchItem(
            title: '默认展示评论区',
            subTitle: '在视频详情页默认切换至评论区页（仅Tab型布局）',
            leading: Icon(Icons.mode_comment_outlined),
            setKey: SettingBoxKey.defaultShowComment,
            defaultVal: false,
          ),
          ListTile(
            dense: false,
            title: Text('评论展示', style: titleStyle),
            leading: const Icon(Icons.whatshot_outlined),
            subtitle: Text(
              '当前优先展示「${ReplySortType.values[defaultReplySort].titles}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '评论展示',
                      value: defaultReplySort,
                      values: ReplySortType.values.map((e) {
                        return {'title': e.titles, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultReplySort = result;
                setting.put(SettingBoxKey.replySortType, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('动态展示', style: titleStyle),
            leading: const Icon(Icons.dynamic_feed_outlined),
            subtitle: Text(
              '当前优先展示「${DynamicsType.values[defaultDynamicType].labels}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              int? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<int>(
                      title: '动态展示',
                      value: defaultDynamicType,
                      values: DynamicsType.values.sublist(0, 4).map((e) {
                        return {'title': e.labels, 'value': e.index};
                      }).toList());
                },
              );
              if (result != null) {
                defaultDynamicType = result;
                setting.put(SettingBoxKey.defaultDynamicType, result);
                setState(() {});
              }
            },
          ),
          ListTile(
            dense: false,
            title: Text('用户页默认展示TAB', style: titleStyle),
            leading: const Icon(Icons.tab),
            subtitle: Text(
              '当前优先展示「${defaultMemberTab.title}」',
              style: subTitleStyle,
            ),
            onTap: () async {
              MemberTabType? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<MemberTabType>(
                      title: '用户页默认展示TAB',
                      value: defaultMemberTab,
                      values: MemberTabType.values.map((e) {
                        return {'title': e.title, 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                defaultMemberTab = result;
                setting.put(SettingBoxKey.memberTab, result.index);
                setState(() {});
              }
            },
          ),
          ListTile(
            enableFeedback: true,
            onTap: () => twoFADialog(),
            leading: const Icon(Icons.airplane_ticket_outlined),
            title: Text('设置代理', style: titleStyle),
            subtitle: Text('设置代理 host:port', style: subTitleStyle),
            trailing: Transform.scale(
              alignment: Alignment.centerRight,
              scale: 0.8,
              child: Switch(
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                    (Set<WidgetState> states) {
                  if (states.isNotEmpty &&
                      states.first == WidgetState.selected) {
                    return const Icon(Icons.done);
                  }
                  return null; // All other states will use the default thumbIcon.
                }),
                value: enableSystemProxy,
                onChanged: (val) {
                  setting.put(
                      SettingBoxKey.enableSystemProxy, !enableSystemProxy);
                  setState(() {
                    enableSystemProxy = !enableSystemProxy;
                  });
                },
              ),
            ),
          ),
          const SetSwitchItem(
            title: '自动清除缓存',
            subTitle: '每次启动时清除缓存',
            leading: Icon(Icons.auto_delete_outlined),
            setKey: SettingBoxKey.autoClearCache,
            defaultVal: false,
          ),
          // const SetSwitchItem(
          //   title: '检查更新',
          //   subTitle: '每次启动时检查是否需要更新',
          //   leading: Icon(Icons.system_update_alt_outlined),
          //   setKey: SettingBoxKey.autoUpdate,
          //   defaultVal: false,
          // ),
        ],
      ),
    );
  }
}
