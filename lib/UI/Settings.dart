import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walpy/Widgets/Conditions.dart';

import '../Get_Controller/settings_controller.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  final controller = Get.find<WallpaperSettingsController>();
  // Helper method to format duration to readable string
  String formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    }
  }

  // Helper method to get source display name
  String getSourceDisplayName(String source) {
    switch (source.toUpperCase()) {
      case 'WALLPAPER':
        return 'Wallpaper';
      case 'FAVOURITES':
        return 'Favourites';
      case 'NATURE':
        return 'Nature';
      case 'PATTERNS':
        return 'Patterns';
      case 'FILM':
        return 'Film';
      case 'STREET':
        return 'Street';
      case 'EXPERIMENTAL':
        return 'Experimental';
      case 'TRAVEL':
        return 'Travel';
      case 'ANIMAL':
        return 'Animal';
      case 'ANIME':
        return 'Anime';
      default:
        return 'Wallpaper';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto vibe switch',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 18),
          ).paddingOnly(bottom: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your wallpaper changes itself at regular intervals — like magic!',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14),
                ),
              ),
              Obx(() => Switch(
                activeColor: isDark ? Colors.white : Colors.black,           // thumb when ON
                activeTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, // subtle track
                inactiveThumbColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800, // thumb when OFF
                inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                value: controller.constraints.value.autoSwitch,
                onChanged: (val) {
                  controller.toggleAutoSwitch(val);
                },
              )),
            ],
          ),
          Divider().paddingSymmetric(vertical: 10),

          Conditions(
            condition: 'Only on Wi-Fi',
            explanation: 'Wallpaper will only change when Wi-Fi is on.',
            tickBox: Obx(() => Switch(
              activeColor: isDark ? Colors.white : Colors.black,           // thumb when ON
              activeTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, // subtle track
              inactiveThumbColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800, // thumb when OFF
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              value: controller.constraints.value.wifiOnly,
              onChanged: (val) {
                controller.toggleWifiOnly(val);
              },
            )),
          ),

          Conditions(
            condition: 'Charging',
            explanation: 'Wallpaper will change during charge.',
            tickBox: Obx(() => Switch(
              activeColor: isDark ? Colors.white : Colors.black,           // thumb when ON
              activeTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, // subtle track
              inactiveThumbColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800, // thumb when OFF
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              value: controller.constraints.value.chargingOnly,
              onChanged: (val) {
                controller.toggleChargingOnly(val);
              },
            )),
          ),

          Conditions(
            condition: 'Low Battery',
            explanation: 'Wallpaper will change only when there is enough battery.',
            tickBox: Obx(() => Switch(
              activeColor: isDark ? Colors.white : Colors.black,           // thumb when ON
              activeTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, // subtle track
              inactiveThumbColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800, // thumb when OFF
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              value: controller.constraints.value.batteryLow,
              onChanged: (val) {
                controller.toggleBatteryOnly(val);
              },
            )),
          ),

          Conditions(
            condition: 'Inactive',
            explanation: 'Device should be inactive to change the wallpaper.',
            tickBox: Obx(() => Switch(
              activeColor: isDark ? Colors.white : Colors.black,           // thumb when ON
              activeTrackColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300, // subtle track
              inactiveThumbColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800, // thumb when OFF
              inactiveTrackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              value: controller.constraints.value.idleOnly,
              onChanged: (val) {
                controller.toggleIdleOnly(val);
              },
            )),
          ),

          InkWell(
            onTap: () {
              intervalDialog(context);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  'Interval',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 18),
                ),
                Obx(() => Text(
                  'Each wallpaper will last for at least ${formatDuration(controller.constraints.value.interval)}.',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14),
                )),
              ],
            ),
          ).paddingOnly(top: 10),
        ],
      ).paddingSymmetric(horizontal: 20),
    );
  }

  void intervalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: AlertDialog(
            title: Align(
              alignment: Alignment.topCenter,
              child: Text('Intervals'),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(minutes: 30));
                    Get.back();
                  },
                  child: Text('30 minutes'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 1));
                    Get.back();
                  },
                  child: Text('1 hour'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 2));
                    Get.back();
                  },
                  child: Text('2 hours'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 4));
                    Get.back();
                  },
                  child: Text('4 hours'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 6));
                    Get.back();
                  },
                  child: Text('6 hours'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 12));
                    Get.back();
                  },
                  child: Text('12 hours'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    controller.updateInterval(Duration(hours: 24));
                    Get.back();
                  },
                  child: Text('24 hours'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}