import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walpy/Get_Controller/user_controller.dart';

import 'HomePage.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key, required this.userName});

  final String userName;

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  final FetchUser fetchUser = Get.put(FetchUser());

  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    fetchUser.loadUser(widget.userName);
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = isDarkMode(context);

    return Obx(() {
      print('userName: ${widget.userName}');
      final user = fetchUser.user.value;
      if (user == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.black),
        );
      }

      String imgUrl = user.profileImage?.large ?? '';

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
                          user.name!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          'On Unsplash',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Divider(color: Colors.grey),
                        SizedBox(
                          height: 40,
                          child: Text(
                            (user.bio?.isNotEmpty ?? false)
                                ? user.bio!
                                : 'Hi there,\nI am ${user.name}\nHope you enjoys my work!',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () {
                            _openExternal(user.links!.html!);
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
              child: MasonryGridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: user.photos?.length ?? 0,
                itemBuilder: (context, index) {
                  final photo = user.photos![index];
                  final url = photo.urls;
                  final double ht = index.isEven ? 200 : 250;
                  return Stack(
                    children: [
                      Container(
                        height: ht,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: Homepage.borderRadius24,
                          color: Colors.grey,
                        ),
                        child: ClipRRect(
                          borderRadius: Homepage.borderRadius24,
                          child: GestureDetector(
                            onTap: () {},
                            // Get.to(() {
                            /* ViewImage(
                                    imageUrl: url!.full!,
                                    id: portfolio!.id!,
                                  ));*/
                            child: CachedNetworkImage(
                              fadeInDuration: const Duration(milliseconds: 0),
                              fadeOutDuration: const Duration(milliseconds: 0),
                              imageUrl: url!.smallS3!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
    // return
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
