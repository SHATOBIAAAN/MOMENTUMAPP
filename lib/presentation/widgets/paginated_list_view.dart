import 'package:flutter/material.dart';

/// Paginated list view widget for efficient loading of large lists
/// Supports lazy loading, pull-to-refresh, and error handling
class PaginatedListView<T> extends StatefulWidget {
  /// Items to display
  final List<T> items;

  /// Builder for individual items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Callback when more items need to be loaded
  final Future<List<T>> Function(int page)? onLoadMore;

  /// Callback for pull-to-refresh
  final Future<void> Function()? onRefresh;

  /// Whether there are more items to load
  final bool hasMore;

  /// Whether currently loading
  final bool isLoading;

  /// Error message if any
  final String? errorMessage;

  /// Callback when load more fails
  final VoidCallback? onRetry;

  /// Items per page
  final int itemsPerPage;

  /// Scroll controller
  final ScrollController? scrollController;

  /// Padding for the list
  final EdgeInsetsGeometry? padding;

  /// Separator between items
  final Widget? separator;

  /// Empty state widget
  final Widget? emptyWidget;

  /// Loading widget
  final Widget? loadingWidget;

  /// Error widget builder
  final Widget Function(String error, VoidCallback? onRetry)? errorBuilder;

  /// Physics for the scroll view
  final ScrollPhysics? physics;

  /// Whether to show loading indicator at bottom
  final bool showBottomLoader;

  /// Threshold for loading more (0.0 - 1.0)
  final double loadMoreThreshold;

  /// Whether to shrink wrap the list
  final bool shrinkWrap;

  /// Primary scroll view
  final bool primary;

  const PaginatedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.itemsPerPage = 20,
    this.scrollController,
    this.padding,
    this.separator,
    this.emptyWidget,
    this.loadingWidget,
    this.errorBuilder,
    this.physics,
    this.showBottomLoader = true,
    this.loadMoreThreshold = 0.8,
    this.shrinkWrap = false,
    this.primary = true,
  }) : super(key: key);

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String? _loadMoreError;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  /// Listen to scroll position and trigger load more
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold) {
      _loadMoreItems();
    }
  }

  /// Load more items
  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      _currentPage++;
      await widget.onLoadMore!(_currentPage);
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _loadMoreError = e.toString();
          _currentPage--; // Revert page increment
        });
      }
    }
  }

  /// Handle refresh
  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;

    setState(() {
      _currentPage = 1;
      _loadMoreError = null;
    });

    try {
      await widget.onRefresh!();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Refresh failed: $e')));
      }
    }
  }

  /// Build empty state
  Widget _buildEmptyState() {
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(String error, VoidCallback? onRetry) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(error, onRetry);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build bottom loader
  Widget _buildBottomLoader() {
    if (!widget.showBottomLoader) return const SizedBox.shrink();

    if (_loadMoreError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load more items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadMoreItems,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Build list item with separator
  Widget _buildListItem(int index) {
    if (index >= widget.items.length) {
      return _buildBottomLoader();
    }

    final item = widget.items[index];
    final itemWidget = widget.itemBuilder(context, item, index);

    if (widget.separator != null && index < widget.items.length - 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [itemWidget, widget.separator!],
      );
    }

    return itemWidget;
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (widget.errorMessage != null && widget.items.isEmpty) {
      return _buildErrorWidget(widget.errorMessage!, widget.onRetry);
    }

    // Show loading state
    if (widget.isLoading && widget.items.isEmpty) {
      return _buildLoadingWidget();
    }

    // Show empty state
    if (widget.items.isEmpty) {
      if (widget.onRefresh != null) {
        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildEmptyState(),
            ),
          ),
        );
      }
      return _buildEmptyState();
    }

    // Build list view
    final listView = ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      primary: widget.primary,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) => _buildListItem(index),
    );

    // Wrap with refresh indicator if onRefresh is provided
    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: _handleRefresh, child: listView);
    }

    return listView;
  }
}

/// Grid variant of paginated view
class PaginatedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<List<T>> Function(int page)? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoading;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final Widget? emptyWidget;
  final ScrollController? scrollController;

  const PaginatedGridView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoading = false,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.padding,
    this.emptyWidget,
    this.scrollController,
  }) : super(key: key);

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      _currentPage++;
      await widget.onLoadMore!(_currentPage);
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh == null) return;
    setState(() => _currentPage = 1);
    await widget.onRefresh!();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('No items'));
    }

    final gridView = GridView.builder(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: _handleRefresh, child: gridView);
    }

    return gridView;
  }
}
