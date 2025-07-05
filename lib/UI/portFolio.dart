import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walpy/data/Models/UserModel.dart';
import 'package:walpy/data/Models/Wallpapers.dart';
import 'package:get/get.dart';

import 'HomePage.dart';
import 'ViewImage.dart';

class Portfolio extends StatelessWidget {
  const Portfolio({super.key, required this.portfolio});

  bool isDarkMode(BuildContext context) {
    return Theme
        .of(context)
        .brightness == Brightness.dark;
  }

  final UserModel? portfolio;

  @override
  Widget build(BuildContext context) {
    final darkMode = isDarkMode(context);

    String imgUrl = portfolio!.profileImage!.large!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Vibe Creator!',
          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── author card ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey,
                  foregroundImage: (imgUrl.isNotEmpty || imgUrl != Null)
                      ? CachedNetworkImageProvider(imgUrl)
                      : null,
                  child: Icon(
                    Icons.person,
                    size: 55, // same as radius so it fits nicely
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (portfolio!.bio?.isNotEmpty ?? false)
                            ? portfolio!.bio!
                            : 'Hi there,\nI am ${portfolio!
                            .name!}\nHope you enjoys my work!',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          _openExternal(portfolio!.links!.html!);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'VIEW PROFILE',
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 0.5,
                                color: darkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.link,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: Divider(
              indent: Get.width * 0.02,
              color: Colors.grey,
              endIndent: Get.width * 0.02,
            ),
          ),
          // ── wallpapers grid (fills the rest) ────────────────
          Expanded(
            child:
                  MasonryGridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: portfolio!.photos!.length,
                    itemBuilder: (context, index) {
                      double ht = index.isEven ? 200 : 250;
                     /* if (index == portfolio.links!.photos!.length) {
                        return fetchWalls.isPagination.value
                            ? Container(
                            height: ht,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: Homepage.borderRadius24),
                            child: Center(child: CircularProgressIndicator(color: Colors.black,)))
                            : SizedBox.shrink();
                      }*/
                     // final wallpaper = fetchWalls.photos[index];
                      //final url = wallpaper.urls!.small!;
                      return Stack(
                        children: [
                        Container(
                        height: ht,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            //borderRadius: Homepage.borderRadius24,
                            color: Colors.grey
                        ),
                        child: ClipRRect(
                         // borderRadius: Homepage.borderRadius24,
                          child: GestureDetector(
                            onTap: () {},
                             // Get.to(() {
                                 /* ViewImage(
                                    blurHash: '',
                                    imageUrl: portfolio!.photos.toString(),
                                    id: portfolio!.id!,
                                  ));*/
                            child: Hero(
                              tag: portfolio!.id!,
                              child: CachedNetworkImage(
                                fadeInDuration: const Duration(milliseconds: 0),
                                fadeOutDuration: const Duration(
                                    milliseconds: 0),
                                imageUrl: portfolio!.photos!.toString(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )]);},
                  ),
            ),
        ],
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    // one call – launch in external browser
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // optional toast / snackbar / print
      throw Exception('Could not open $url');
    }
  }
}
