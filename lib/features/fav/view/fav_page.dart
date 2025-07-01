import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:walpy/UI/ViewImage.dart';
import 'package:walpy/features/fav/data/hive_service.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  final FavService favService = FavService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: favService.listenable,
      builder: (context, box, _) {
        if (box.isEmpty) {
          return Center(
            child: const Text(
              'No favourites yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          );
        }
        final pics = box.values.toList();
        return MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: pics.length,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          itemBuilder: (BuildContext context, int index) {
            final fav = pics[index];
            double ht = index.isEven ? 200 : 250;
            return Stack(
              children: [
                InkWell(
                  onTap: (){
                    Get.to(ViewImage(
                        imageBytes: fav.bytes,
                        id: fav.id));
                  },
                  child: Container(
                    height: ht,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(fav.bytes, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        favService.remove(fav.id);
                      });
                    },
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
