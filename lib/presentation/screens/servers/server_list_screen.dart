// 🚀 Simple and Clean Server List Screen
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../bloc/server/server_bloc.dart';
import '../../bloc/server/server_event.dart';
import '../../bloc/server/server_state.dart';
import '../../../domain/entities/server.dart';

class ServerListScreen extends StatefulWidget {
  @override
  _ServerListScreenState createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  int _selectedTab = 0;
  ServerSortType _sortType = ServerSortType.recommended;
  Set<String> _expandedCountries = <String>{};
  Set<ServerFilter> _activeFilters = <ServerFilter>{ServerFilter.all};

  @override
  void initState() {
    super.initState();
    _setupSearchListener();
    _loadServers();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _loadServers() {
    context.read<ServerBloc>().add(LoadServers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildTabSection(),
            _buildFilterChips(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Server',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                BlocBuilder<ServerBloc, ServerState>(
                  builder: (context, state) {
                    if (state is ServerLoaded) {
                      final filteredServers = _filterAndSortServers(
                        state.servers,
                      );
                      return Text(
                        '${filteredServers.length} servers available',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      );
                    }
                    return const Text(
                      'Select your preferred location',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    );
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSortingOptions,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.sort, color: Colors.white70, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search servers...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.4),
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.4),
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildTab('All Servers', 0)),
          const SizedBox(width: 12),
          Expanded(child: _buildTab('Favorites', 1)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', ServerFilter.all),
          _buildFilterChip('Free', ServerFilter.free),
          _buildFilterChip('Premium', ServerFilter.premium),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ServerFilter filter) {
    final isSelected = _activeFilters.contains(filter);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (filter == ServerFilter.all) {
              _activeFilters.clear();
              _activeFilters.add(ServerFilter.all);
            } else {
              _activeFilters.remove(ServerFilter.all);
              if (isSelected) {
                _activeFilters.remove(filter);
                if (_activeFilters.isEmpty) {
                  _activeFilters.add(ServerFilter.all);
                }
              } else {
                _activeFilters.add(filter);
              }
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.4)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        if (state is ServerLoading) {
          return _buildShimmerLoading();
        }

        if (state is ServerError) {
          return _buildErrorState(state.message);
        }

        if (state is ServerLoaded) {
          return _selectedTab == 0
              ? _buildServerList(state.servers, state.selectedServer)
              : _buildFavoritesList(
                  state.favoriteServers,
                  state.selectedServer,
                );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.03),
      highlightColor: Colors.white.withOpacity(0.06),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Connection Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ServerBloc>().add(LoadServers()),
            child: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'No Servers Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check your connection and try again',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildServerList(List<Server> servers, Server? selectedServer) {
    final filteredServers = _filterAndSortServers(servers);

    if (filteredServers.isEmpty) {
      return _buildNoResultsState();
    }

    // Group by country
    final groupedServers = <String, List<Server>>{};
    for (final server in filteredServers) {
      groupedServers.putIfAbsent(server.country, () => []).add(server);
    }

    final sortedCountries = groupedServers.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ServerBloc>().add(LoadServers());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sortedCountries.length,
        itemBuilder: (context, index) {
          final country = sortedCountries[index];
          final countryServers = groupedServers[country]!;
          return _buildCountryGroup(country, countryServers, selectedServer);
        },
      ),
    );
  }

  Widget _buildFavoritesList(List<Server> favorites, Server? selectedServer) {
    final filteredFavorites = _filterAndSortServers(favorites);

    if (filteredFavorites.isEmpty) {
      return _buildNoFavoritesState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ServerBloc>().add(LoadServers());
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredFavorites.length,
        itemBuilder: (context, index) {
          final server = filteredFavorites[index];
          return _buildServerCard(server, selectedServer, showCountry: true);
        },
      ),
    );
  }

  Widget _buildCountryGroup(
    String country,
    List<Server> servers,
    Server? selectedServer,
  ) {
    final isExpanded = _expandedCountries.contains(country);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        children: [
          // Country header
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCountries.remove(country);
                } else {
                  _expandedCountries.add(country);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCountryFlag(country),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          country,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${servers.length} servers',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${servers.length}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Servers list
          if (isExpanded) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white.withOpacity(0.05),
            ),
            ...servers.map(
              (server) => _buildServerCard(server, selectedServer),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServerCard(
    Server server,
    Server? selectedServer, {
    bool showCountry = false,
  }) {
    final isSelected = selectedServer?.id == server.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: () => _selectServer(server),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Server icon
              _buildServerIcon(server),
              const SizedBox(width: 16),

              // Server info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            server.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (server.isPremium) _buildPremiumBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showCountry) ...[
                          Text(
                            server.country,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildProtocolChip(server.protocol),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite button
                  _buildFavoriteButton(server),
                  const SizedBox(width: 8),
                  // Selection indicator
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Colors.blue
                        : Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerIcon(Server server) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Icon(
        _getServerIcon(server.protocol),
        color: Colors.blue,
        size: 20,
      ),
    );
  }

  Widget _buildCountryFlag(String country) {
    return Container(
      width: 32,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
        color: Colors.blue.withOpacity(0.3),
      ),
      child: Center(
        child: Text(
          country.length >= 2 ? country.substring(0, 2).toUpperCase() : 'UN',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 0.5),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.amber,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProtocolChip(String protocol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        protocol.toUpperCase(),
        style: const TextStyle(
          color: Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(Server server) {
    return BlocBuilder<ServerBloc, ServerState>(
      builder: (context, state) {
        if (state is! ServerLoaded) return const SizedBox.shrink();

        final isFavorite = state.favoriteServers.any((s) => s.id == server.id);

        return GestureDetector(
          onTap: () => _toggleFavorite(server),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.white.withOpacity(0.5),
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No servers found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different search terms',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _activeFilters.clear();
                _activeFilters.add(ServerFilter.all);
              });
            },
            child: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFavoritesState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'No favorite servers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon to add favorites',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Sorting Bottom Sheet
  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Sort Servers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSortOption(
              'Recommended',
              Icons.star,
              ServerSortType.recommended,
            ),
            _buildSortOption(
              'Country A-Z',
              Icons.sort_by_alpha,
              ServerSortType.country,
            ),
            _buildSortOption('Server Name', Icons.dns, ServerSortType.name),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String title,
    IconData icon,
    ServerSortType sortType,
  ) {
    final isSelected = _sortType == sortType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortType = sortType;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  List<Server> _filterAndSortServers(List<Server> servers) {
    var filtered = servers;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = servers.where((server) {
        return server.name.toLowerCase().contains(_searchQuery) ||
            server.country.toLowerCase().contains(_searchQuery) ||
            server.protocol.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply filters
    if (!_activeFilters.contains(ServerFilter.all)) {
      filtered = filtered.where((server) {
        return _activeFilters.any((filter) => _matchesFilter(server, filter));
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortType) {
        case ServerSortType.recommended:
          if (a.isPremium != b.isPremium) {
            return b.isPremium ? 1 : -1;
          }
          return a.name.compareTo(b.name);
        case ServerSortType.country:
          return a.country.compareTo(b.country);
        case ServerSortType.name:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  bool _matchesFilter(Server server, ServerFilter filter) {
    switch (filter) {
      case ServerFilter.all:
        return true;
      case ServerFilter.free:
        return !server.isPremium;
      case ServerFilter.premium:
        return server.isPremium;
    }
  }

  void _selectServer(Server server) {
    HapticFeedback.selectionClick();
    context.read<ServerBloc>().add(SelectServer(server));
    Navigator.of(context).pop();
  }

  void _toggleFavorite(Server server) {
    HapticFeedback.lightImpact();
    final serverBloc = context.read<ServerBloc>();
    final state = serverBloc.state;

    if (state is ServerLoaded) {
      final isFavorite = state.favoriteServers.any((s) => s.id == server.id);
      if (isFavorite) {
        serverBloc.add(RemoveFromFavorites(server.id));
      } else {
        serverBloc.add(AddToFavorites(server));
      }
    }
  }

  IconData _getServerIcon(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'vmess':
        return Icons.security;
      case 'vless':
        return Icons.shield;
      case 'trojan':
        return Icons.vpn_lock;
      case 'shadowsocks':
        return Icons.privacy_tip;
      default:
        return Icons.dns;
    }
  }
}

enum ServerSortType { recommended, country, name }

enum ServerFilter { all, free, premium }
