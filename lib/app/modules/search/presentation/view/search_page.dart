import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:walpy/app/core/Widgets/error_retry_widget.dart';
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

  Widget _buildSearchBar(bool darkMode) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
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
            setState(() {});
          }
        },
        style: TextStyle(
          color: darkMode ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
        cursorColor: darkMode ? Colors.white : Colors.black87,
        decoration: InputDecoration(
          hintText: 'Search here...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchBloc>().add(
                      const SearchQueryChanged(''),
                    );
                    _focusNode.requestFocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesRow(bool darkMode) {
    final categories = [
      'Minimalist',
      'Nature',
      'Aesthetic',
      'Abstract',
      'Anime',
      'Space',
      'Animals',
      'Textures',
      'Dark',
    ];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              _searchController.text.toLowerCase() == category.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? (darkMode ? Colors.black : Colors.white)
                      : (darkMode ? Colors.white70 : Colors.black87),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? (darkMode ? Colors.white : Colors.black)
                  : (darkMode ? Colors.grey.shade900 : Colors.grey.shade100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Colors.transparent),
              ),
              onPressed: () {
                _searchController.text = category;
                _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: category.length),
                );
                _triggerSearch(category);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = AppConst.isDarkMode(context);

    return Scaffold(
      backgroundColor: darkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // sticky search bar
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: false,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: darkMode ? Colors.black : Colors.white,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  toolbarHeight: 64,
                  expandedHeight: 120,
                  stretch: true,
                  onStretchTrigger: () async {
                    context.read<SearchBloc>().add(
                      SearchQueryChanged(_searchController.text.trim()),
                    );
                  },
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [_buildCategoriesRow(darkMode)],
                    ),
                  ),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: darkMode ? Colors.white70 : Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildSearchBar(darkMode)),
                      ],
                    ),
                  ),
                ),

                // Render slivers depending on search state
                if (state is SearchLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  )
                else if (state is SearchError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorRetryWidget(
                      errorMessage: state.message,
                      onRetry: () => context.read<SearchBloc>().add(
                        SearchQueryChanged(_searchController.text.trim()),
                      ),
                    ),
                  )
                else if (state is SearchLoaded) ...[
                  if (state.walls.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 54,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No wallpapers found for "${state.query}"',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 4.0,
                      ),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppConst.yAxisSpacing,
                        crossAxisSpacing: AppConst.xAxisSpacing,
                        childCount:
                            state.walls.length +
                            (state.isLoadingNext || state.hasPaginationError
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.walls.length) {
                            if (state.isLoadingNext) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: darkMode ? Colors.white : Colors.black,
                                ),
                              );
                            }
                            if (state.hasPaginationError) {
                              return ErrorRetryWidget(
                                isMini: true,
                                errorMessage: state.errorNotification ?? "",
                                onRetry: () => context.read<SearchBloc>().add(
                                  SearchQueryChanged(
                                    _searchController.text.trim(),
                                  ),
                                ),
                              );
                            }
                          }
                          return Wall(index, wallInfo: state.walls[index]);
                        },
                      ),
                    ),
                ] else ...[
                  ..._buildHistorySlivers(state, darkMode),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHistorySlivers(SearchState state, bool darkMode) {
    final List<String> history = [];
    if (state is SearchInitial) {
      history.addAll(state.history);
    }

    if (history.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Search history is empty',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: darkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<SearchBloc>().add(ClearSearchHistory());
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final queryItem = history[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<SearchBloc>().add(
                  DeleteSearchHistoryItem(queryItem),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.close, color: Colors.grey.shade500, size: 16),
              ),
            ),
            title: Text(
              queryItem,
              style: TextStyle(
                color: darkMode ? Colors.white70 : Colors.black87,
                fontSize: 15,
              ),
            ),
            trailing: Icon(
              Icons.arrow_outward,
              color: Colors.grey.shade600,
              size: 18,
            ),
            onTap: () {
              _searchController.text = queryItem;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: queryItem.length),
              );
              _triggerSearch(queryItem);
            },
          );
        }, childCount: history.length),
      ),
    ];
  }
}
