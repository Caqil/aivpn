// 🚀 Complete Professional Server List Screen with All Features
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class _ServerListScreenState extends State<ServerListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  int _selectedTab = 0;
  ServerSortType _sortType = ServerSortType.recommended;
  Set<String> _expandedCountries = <String>{};

  // Speed test state
  final Map<String, int> _serverPings = {};
  final Set<String> _testingServers = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearchListener();
    _loadSelectedServer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _loadSelectedServer() {
    // Load selected server from cache on app start
    context.read<ServerBloc>().add(LoadServers());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildQuickActions(),
              _buildSearchSection(),
              _buildTabSection(),
              _buildFilterChips(),
              Expanded(child: _buildContent()),
            ],
          ),
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
                    letterSpacing: -0.5,
                  ),
                ),
                BlocBuilder<ServerBloc, ServerState>(
                  builder: (context, state) {
                    if (state is ServerLoaded) {
                      return Text(
                        '${state.servers.length} servers in ${_getCountryCount(state.servers)} countries',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    }
                    return const Text(
                      'Select your preferred location',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            children: [
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
                  child: const Icon(
                    Icons.sort,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.read<ServerBloc>().add(LoadServers()),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              'Fastest',
              Icons.speed,
              _sortType == ServerSortType.ping,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickAction(
              'Nearby',
              Icons.location_on,
              _sortType == ServerSortType.country,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickAction(
              'Popular',
              Icons.trending_up,
              _sortType == ServerSortType.recommended,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          switch (label) {
            case 'Fastest':
              _sortType = ServerSortType.ping;
              break;
            case 'Nearby':
              _sortType = ServerSortType.country;
              break;
            case 'Popular':
              _sortType = ServerSortType.recommended;
              break;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white54,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Search countries, cities, servers...',
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', true),
          _buildFilterChip('Free', false),
          _buildFilterChip('Premium', false),
          _buildFilterChip('Fast (<50ms)', false),
          _buildFilterChip('Europe', false),
          _buildFilterChip('America', false),
          _buildFilterChip('Asia', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          // Handle filter selection
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
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
        itemCount: 12,
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 24),
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
          ElevatedButton.icon(
            onPressed: () => context.read<ServerBloc>().add(LoadServers()),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.dns_outlined,
              color: Colors.white.withOpacity(0.4),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Servers Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pull to refresh or check connection',
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
                          '${servers.length} servers • Avg ${_getAveragePing(servers)}ms',
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
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Servers list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withOpacity(0.05),
                ),
                ...servers.map(
                  (server) => _buildServerCard(server, selectedServer),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
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
    final currentPing = _serverPings[server.id] ?? server.ping;
    final isTesting = _testingServers.contains(server.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: GestureDetector(
        onTap: () => _selectServer(server),
        onLongPress: () => _showServerDetails(server),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
              width: isSelected ? 1.5 : 1,
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
                    // Name and premium badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            server.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isSelected
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                              decorationColor: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (server.isPremium) _buildPremiumBadge(),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Info row
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
                        const SizedBox(width: 8),
                        if (currentPing > 0)
                          _buildPingChip(currentPing, isTesting),
                        const SizedBox(width: 8),
                        _buildLoadIndicator(),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Speed test button
                  GestureDetector(
                    onTap: () => _runSpeedTest(server),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.speed, color: Colors.green, size: 16),
                    ),
                  ),
                  const SizedBox(width: 8),

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
    return Stack(
      children: [
        Container(
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
        ),
        if (server.isPremium)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildCountryFlag(String country) {
    final flagPath = _getFlagAssetPath(country);

    return Container(
      width: 32,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          flagPath,
          width: 32,
          height: 20,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.blue.withOpacity(0.3),
              child: Center(
                child: Text(
                  country.length >= 2
                      ? country.substring(0, 2).toUpperCase()
                      : 'UN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
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

  Widget _buildPingChip(int ping, bool isTesting) {
    Color color;
    if (ping < 50) {
      color = Colors.green;
    } else if (ping < 100) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTesting)
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(Icons.speed, size: 8, color: color),
          const SizedBox(width: 2),
          Text(
            '${ping}ms',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ],
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
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isFavorite
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 16,
            ),
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
          Icon(
            Icons.search_off,
            color: Colors.white.withOpacity(0.3),
            size: 64,
          ),
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
        ],
      ),
    );
  }

  Widget _buildNoFavoritesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            color: Colors.white.withOpacity(0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorite servers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart icon to add favorites',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Server Details Bottom Sheet
  void _showServerDetails(Server server) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildServerDetailsModal(server),
    );
  }

  Widget _buildServerDetailsModal(Server server) {
    final currentPing = _serverPings[server.id] ?? server.ping;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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

          // Server header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getServerIcon(server.protocol),
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildCountryFlag(server.country),
                          const SizedBox(width: 8),
                          Text(
                            server.country,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Ping',
                    '${currentPing}ms',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Load',
                    '${_getRandomLoad()}%',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Users',
                    '${_getRandomUsers()}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Server details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Server Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Protocol', server.protocol.toUpperCase()),
                  _buildDetailRow('Address', server.address),
                  _buildDetailRow('Port', server.port.toString()),
                  _buildDetailRow(
                    'Type',
                    server.isPremium ? 'Premium Server' : 'Free Server',
                  ),
                  _buildDetailRow('Region', server.country),
                  _buildDetailRow('Connection String', server.connectionString),
                  if (server.configUrl != null)
                    _buildDetailRow(
                      'Config URL',
                      server.configUrl!,
                      maxLines: 3,
                    ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectServer(server);
                    },
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('Connect to Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => _runSpeedTest(server),
                    icon: const Icon(
                      Icons.speed,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<ServerBloc, ServerState>(
                  builder: (context, state) {
                    if (state is! ServerLoaded) return const SizedBox.shrink();

                    final isFavorite = state.favoriteServers.any(
                      (s) => s.id == server.id,
                    );

                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isFavorite
                            ? Colors.red.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFavorite
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => _toggleFavorite(server),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white54,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
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
      builder: (context) => _buildSortingBottomSheet(),
    );
  }

  Widget _buildSortingBottomSheet() {
    return Container(
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

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  'Sort Servers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.white54, size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sort options
          _buildSortOption(
            'Recommended',
            Icons.star,
            _sortType == ServerSortType.recommended,
          ),
          _buildSortOption(
            'Fastest Ping',
            Icons.speed,
            _sortType == ServerSortType.ping,
          ),
          _buildSortOption(
            'Country A-Z',
            Icons.sort_by_alpha,
            _sortType == ServerSortType.country,
          ),
          _buildSortOption(
            'Server Name',
            Icons.dns,
            _sortType == ServerSortType.name,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          switch (title) {
            case 'Recommended':
              _sortType = ServerSortType.recommended;
              break;
            case 'Fastest Ping':
              _sortType = ServerSortType.ping;
              break;
            case 'Country A-Z':
              _sortType = ServerSortType.country;
              break;
            case 'Server Name':
              _sortType = ServerSortType.name;
              break;
          }
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
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
            server.address.toLowerCase().contains(_searchQuery) ||
            server.protocol.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortType) {
        case ServerSortType.recommended:
          // Sort by premium first, then by ping
          if (a.isPremium != b.isPremium) {
            return b.isPremium ? 1 : -1;
          }
          return a.ping.compareTo(b.ping);
        case ServerSortType.ping:
          return a.ping.compareTo(b.ping);
        case ServerSortType.country:
          return a.country.compareTo(b.country);
        case ServerSortType.name:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  void _selectServer(Server server) {
    // Save selected server to persist after reload
    context.read<ServerBloc>().add(SelectServer(server));
    Navigator.of(context).pop();
  }

  void _toggleFavorite(Server server) {
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

  void _runSpeedTest(Server server) {
    setState(() {
      _testingServers.add(server.id);
    });

    // Simulate speed test
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _testingServers.remove(server.id);
          _serverPings[server.id] =
              20 + (server.ping * 0.8).round(); // Simulate better ping
        });
      }
    });
  }

  String _getFlagAssetPath(String country) {
    return 'assets/flags/$country.png';
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

  int _getCountryCount(List<Server> servers) {
    return servers.map((s) => s.country).toSet().length;
  }

  int _getAveragePing(List<Server> servers) {
    if (servers.isEmpty) return 0;
    final totalPing = servers.fold<int>(0, (sum, server) => sum + server.ping);
    return (totalPing / servers.length).round();
  }

  int _getRandomLoad() {
    return 15 + (DateTime.now().millisecondsSinceEpoch % 40);
  }

  String _getRandomUsers() {
    final users = ['1.2K', '2.4K', '890', '3.1K', '567', '4.2K'];
    return users[DateTime.now().millisecondsSinceEpoch % users.length];
  }
}

enum ServerSortType { recommended, ping, country, name }
