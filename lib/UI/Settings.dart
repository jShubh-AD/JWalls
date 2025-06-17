import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walpy/Widgets/Conditions.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) {
    final selectedTime = '1 hour';
    final source = 'Wallpaper';
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
              Switch(value: false, onChanged: (bool value) {  },
              ),
            ],
          ),
          Divider().paddingSymmetric(vertical: 10),
          Conditions(condition: 'Only on Wi-Fi', explanation: 'Wallpaper will only change when  Wi-Fi is on.', tickBox: Switch(value: false, onChanged: (bool value) {})),
          Conditions(condition: 'charging', explanation: 'Wallpaper will change during charge.', tickBox: Switch(value: false, onChanged: (bool value) {  })),
          Conditions(condition: 'Inactive', explanation: 'Device should be inactive to change the wallpaper.', tickBox: Switch(value: false, onChanged: (bool value) {})),

          InkWell(onTap: (){intervalDialog(context);},child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Interval',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 18),
              ),
              Text(
                'Each wallpaper will last for at least $selectedTime.',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14),
              ),
            ],
          )).paddingOnly(top: 10),
          InkWell(onTap: (){sourceDialog(context);},child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Source',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 18),
              ),
              Text(
                'Next wallpaper will be from $source collections.',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14),
              ),
            ],
          )).paddingOnly(top: 10),


        ],
      ).paddingSymmetric(horizontal: 20)

    );
  }
  void intervalDialog(BuildContext context){
    showDialog(context: context, builder: (context){
      return SizedBox(
        width: double.infinity,
        child: AlertDialog(
          title:Align(alignment: Alignment.topCenter,child: Text('Intervals')),
          actions: [
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('30 minutes') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('1 hour') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('2 hours') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('4 hours') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('6 hours') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('12 hours') )),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('24 hours') )),
          ],
        ),
      );
    });
  }
  void sourceDialog(BuildContext context){
    showDialog(context: context, builder: (context){
      return SizedBox(
        width: double.infinity,
        child: AlertDialog(
          title:Align(alignment: Alignment.topCenter,child: Text('Sources')),
          actions: [
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('WALLPAPER'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () { Get.back(); }, child: Text('FAVOURITES'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('NATURE'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () { Get.back(); }, child: Text('PATTERNS'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () { Get.back(); }, child: Text('FILM'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('STREET'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('EXPERIMENTAL'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('TRAVEL'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('ANIMAL'))),
            SizedBox(width: double.infinity,child: TextButton(onPressed: () {  Get.back();}, child: Text('ANIME'))),
          ],
        ),
      );
    });
  }
}
