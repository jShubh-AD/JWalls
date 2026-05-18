import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<AssetPathEntity> albums = [];
  List<AssetEntity> images = [];
  AssetPathEntity? selectedAlbum;

  @override
  void initState() {
    super.initState();
    PhotoManager.addChangeCallback(onGalleryChanged);
    PhotoManager.startChangeNotify();
    requestAndLoadAlbums();
  }

  Future<void> requestAndLoadAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      PhotoManager.openSetting(); // Open settings if denied
      return;
    }

    final fetchedAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    setState(() {
      albums = fetchedAlbums;
      if (selectedAlbum != null) loadImagesFrom(selectedAlbum!);
    });

    // Debug print
    for (var album in fetchedAlbums) {
    //  debugPrint('📁 Album: ${album.name} - ${album.assetCount} items');
    }
  }

  void onGalleryChanged([MethodCall? _]) {
    if (selectedAlbum != null) loadImagesFrom(selectedAlbum!);
    requestAndLoadAlbums();
  }

  Future<void> loadImagesFrom(AssetPathEntity album) async {
    final media = await album.getAssetListPaged(page: 0, size: 100);
    setState(() {
      selectedAlbum = album;
      images = media;
    });
  }

  @override
  void dispose() {
    PhotoManager.removeChangeCallback(onGalleryChanged);
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedAlbum == null ? 'Albums' : selectedAlbum!.name),
        leading: selectedAlbum != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedAlbum = null;
              images = [];
            });
          },
        )
            : null,
      ),
      body: selectedAlbum == null ? _buildAlbumList() : _buildImageGrid(),
    );
  }

  Widget _buildAlbumList() {
    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (_, index) {
        final album = albums[index];
        return ListTile(
          title: Text(album.name),
          //subtitle: Text('${album.assetCountAsync} photos'),
          onTap: () => loadImagesFrom(album),
        );
      },
    );
  }

  Widget _buildImageGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: images.length,
      itemBuilder: (_, index) {
        return FutureBuilder<Uint8List?>(
          future: images[index].thumbnailDataWithSize(const ThumbnailSize(200, 200)),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(snapshot.data!, fit: BoxFit.cover),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}
