import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpy/app/core/Widgets/wall.dart';
import 'package:walpy/app/core/utils/const/app_const.dart';
import 'package:walpy/app/modules/search/presentation/bloc/search_bloc.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final isBottom = position.atEdge && position.pixels != 0;
    if (isBottom) {
      final state = context.read<SearchBloc>().state;
      if (state is SearchLoaded && !state.isLoadingNext) {
        context.read<SearchBloc>().add(FetchNextSearchPage());
      }
    }
  }

  void _triggerSearch(String query) {
    if (query.trim().isNotEmpty) {
      _focusNode.unfocus();
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = AppConst.isDarkMode(context);

    return Scaffold(
      backgroundColor: darkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Search Wallpapers',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              key: const ValueKey('search_bar_padding'),
              child: Container(
                decoration: BoxDecoration(
                  color: darkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    if (!darkMode)
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _triggerSearch,
                  onChanged: (val) {
                    if (val.trim().isEmpty) {
                      context.read<SearchBloc>().add(const SearchQueryChanged(''));
                    } else {
                      // Trigger state rebuild to update suffix icon visibility
                      setState(() {});
                    }
                  },
                  style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                  cursorColor: darkMode ? Colors.white : Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Search for high-res wallpapers...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, color: Colors.grey.shade500),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(const SearchQueryChanged(''));
                              _focusNode.requestFocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Content Area
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    );
                  }

                  if (state is SearchError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: darkMode ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkMode ? Colors.white : Colors.black,
                                foregroundColor: darkMode ? Colors.black : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => _triggerSearch(_searchController.text),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is SearchLoaded) {
                    final walls = state.walls;
                    if (walls.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No wallpapers found for "${state.query}"',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4.0),
                          sliver: SliverMasonryGrid.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppConst.yAxisSpacing,
                            crossAxisSpacing: AppConst.xAxisSpacing,
                            childCount: walls.length + (state.isLoadingNext ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= walls.length) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    color: darkMode ? Colors.white : Colors.black,
                                  ),
                                );
                              }
                              return Wall(index, wallInfo: walls[index]);
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // Default / SearchInitial state
                  final List<String> history = [];
                  if (state is SearchInitial) {
                    history.addAll(state.history);
                  }
                  
                  if (history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Search history is empty',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: TextStyle(
                                color: darkMode ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<SearchBloc>().add(ClearSearchHistory());
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: history.length,
                          separatorBuilder: (context, index) => Divider(
                            color: darkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final queryItem = history[index];
                            return ListTile(
                              leading: Icon(
                                Icons.history,
                                color: Colors.grey.shade500,
                              ),
                              title: Text(
                                queryItem,
                                style: TextStyle(
                                  color: darkMode ? Colors.white : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.grey.shade500,
                                  size: 18,
                                ),
                                onPressed: () {
                                  context.read<SearchBloc>().add(DeleteSearchHistoryItem(queryItem));
                                },
                              ),
                              onTap: () {
                                _searchController.text = queryItem;
                                _searchController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: queryItem.length),
                                );
                                _triggerSearch(queryItem);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
