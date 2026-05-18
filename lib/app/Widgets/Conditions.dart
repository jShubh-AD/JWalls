import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Conditions extends StatelessWidget {
  const Conditions({super.key, required this.condition, required this.explanation, required this.tickBox});
  final String condition ;
  final String explanation ;
  final Widget tickBox;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: SizedBox(
        height: Get.height*0.12,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(condition, style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 18),),
                    Text(explanation, style: Theme.of(context).textTheme.displaySmall!.copyWith(fontSize: 14),)
                  ],
              ),
            ),
            tickBox,
          ],
        ),
      ),
    );
  }
}
