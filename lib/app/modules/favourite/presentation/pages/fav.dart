import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../view_image/presentation/pages/view_image.dart';
import '../../data/local_datasource.dart';
class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  // final FavService favService = FavService();/

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueNotifier(context) ,// favService.listenable,
      builder: (context, box, _) {
        // if (box.isEmpty) {
        //   return Center(
        //     child: const Text(
        //       'No favourites yet.',
        //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        //     ),
        //   );
        // }
        // final pics = box.values.toList();
        return MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: 0, //pics.length,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          itemBuilder: (BuildContext context, int index) {
            // final fav = pics[index];
            double ht = index.isEven ? 200 : 250;
            return Stack(
              children: [
                // InkWell(
                //   // onTap: (){
                //   //   Get.to(()=> ViewImage(
                //   //       profileImage: fav.avtar,
                //   //       imageBytes: fav.bytes,
                //   //       id: fav.id
                //   //   ),
                //   //     transition: Transition.rightToLeft
                //   //   );
                //   // },
                //   child: Container(
                //     height: ht,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       color: Colors.grey,
                //       borderRadius: BorderRadius.circular(24),
                //     ),
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(24),
                //       child: Image.memory(fav.bytes, fit: BoxFit.cover),
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: InkWell(
                    // onTap: () async{
                    //     favService.remove(fav.id);
                    // },
                    child: Icon(Icons.favorite, color: Colors.red, size: 26),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
