// lib/presentation/widgets/globe_widget.dart - Fixed version
import 'package:aivpn/data/services/location_service.dart';
import 'package:aivpn/data/services/server_coordinates_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:flutter_earth_globe/point_connection_style.dart';
import 'package:flutter_earth_globe/sphere_style.dart';
import '../bloc/vpn/vpn_bloc.dart';
import '../bloc/vpn/vpn_state.dart';
import '../bloc/server/server_bloc.dart';
import '../bloc/server/server_state.dart';

class GlobeWidget extends StatefulWidget {
  const GlobeWidget({Key? key}) : super(key: key);

  @override
  State<GlobeWidget> createState() => _GlobeWidgetState();
}

class _GlobeWidgetState extends State<GlobeWidget> {
  late FlutterEarthGlobeController _controller;
  List<Point> _points = [];
  List<PointConnection> _connections = [];

  GlobeCoordinates? _userCoordinates;
  bool _isLoadingLocation = true;
  String _userLocationName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeGlobe();
    _loadUserLocation();
  }

  void _initializeGlobe() {
    _controller = FlutterEarthGlobeController(
      maxZoom: 0.5,
      sphereStyle: const SphereStyle(
        shadowColor: CupertinoColors.systemCyan,
        shadowBlurSigma: 30,
      ),
      rotationSpeed: 0.02,
      zoom: 0.5,
      minZoom: 0.48,
      isRotating: true,
      isBackgroundFollowingSphereRotation: true,
      background: Image.asset('assets/2k_stars.jpg').image,
      surface: Image.asset('assets/day.jpg').image,
    );

    // Set up controller callback
    _controller.onLoaded = () {
      _updateGlobePoints();
    };
  }

  Future<void> _loadUserLocation() async {
    try {
      final coordinates = await LocationService.instance.getUserCoordinates();
      final location = await LocationService.instance.getCurrentLocation();

      if (mounted) {
        setState(() {
          _userCoordinates = coordinates;
          _userLocationName = location.displayName;
          _isLoadingLocation = false;
        });
        _updateGlobePoints();
      }
    } catch (e) {
      print('Error loading user location: $e');
      if (mounted) {
        setState(() {
          _userCoordinates = const GlobeCoordinates(
            51.5072,
            -0.1276,
          ); // London fallback
          _userLocationName = 'London, UK';
          _isLoadingLocation = false;
        });
        _updateGlobePoints();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPointLabel(
    BuildContext context,
    Point point,
    bool isHovering,
    bool visible,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHovering
            ? CupertinoColors.systemBlue.withOpacity(0.9)
            : CupertinoColors.systemBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        point.label ?? '',
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConnectionLabel(
    BuildContext context,
    PointConnection connection,
    bool isHovering,
    bool visible,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isHovering
            ? CupertinoColors.systemGreen.withOpacity(0.9)
            : CupertinoColors.systemGreen.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        connection.label ?? '',
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _updateGlobePoints() {
    if (_userCoordinates == null) return;

    try {
      final serverState = context.read<ServerBloc>().state;
      final vpnState = context.read<VpnBloc>().state;

      // Clear existing points and connections
      for (var point in _points) {
        _controller.removePoint(point.id);
      }
      for (var connection in _connections) {
        _controller.removePointConnection(connection.id);
      }

      _points.clear();
      _connections.clear();

      // Add user location point
      final userPoint = Point(
        id: 'user_location',
        coordinates: _userCoordinates!,
        label: _userLocationName,
        labelBuilder: _buildPointLabel,
        isLabelVisible: true,
        style: const PointStyle(color: CupertinoColors.systemBlue, size: 8),
        onTap: () {
          print('User location tapped');
        },
      );
      _points.add(userPoint);

      // Add server point if selected
      if (serverState is ServerLoaded && serverState.selectedServer != null) {
        final server = serverState.selectedServer!;
        final serverCoordinates = ServerCoordinatesService.instance
            .getServerCoordinates(server);

        final serverPoint = Point(
          id: 'server_location',
          coordinates: serverCoordinates,
          label: server.displayName,
          labelBuilder: _buildPointLabel,
          isLabelVisible: true,
          style: PointStyle(
            color: vpnState is VpnConnected
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemOrange,
            size: 8,
          ),
          onTap: () {
            print('Server location tapped: ${server.name}');
          },
        );
        _points.add(serverPoint);

        // Add connection if VPN is connected
        if (vpnState is VpnConnected) {
          final connection = PointConnection(
            id: 'vpn_connection',
            start: _userCoordinates!,
            end: serverCoordinates,
            isMoving: true,
            labelBuilder: _buildConnectionLabel,
            isLabelVisible: false,
            style: const PointConnectionStyle(
              type: PointConnectionType.solid,
              color: CupertinoColors.systemGreen,
              lineWidth: 3,
              dashSize: 6,
              spacing: 12,
            ),
            label: 'Connected to ${server.name}',
          );
          _connections.add(connection);
        }
      }

      // Add points and connections to the globe
      for (var point in _points) {
        _controller.addPoint(point);
      }

      for (var connection in _connections) {
        _controller.addPointConnection(connection, animateDraw: true);
      }

      // Focus on appropriate location
      _focusOnRelevantLocation(vpnState, serverState);
    } catch (e) {
      print('Error updating globe points: $e');
    }
  }

  void _focusOnRelevantLocation(VpnState vpnState, ServerState serverState) {
    if (vpnState is VpnConnected &&
        serverState is ServerLoaded &&
        serverState.selectedServer != null) {
      // Focus on server when connected
      final serverCoordinates = ServerCoordinatesService.instance
          .getServerCoordinates(serverState.selectedServer!);
      _controller.focusOnCoordinates(serverCoordinates, animate: true);
    } else if (_userCoordinates != null) {
      // Focus on user location when disconnected
      _controller.focusOnCoordinates(_userCoordinates!, animate: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ServerBloc, ServerState>(
          listener: (context, serverState) {
            if (!_isLoadingLocation) {
              _updateGlobePoints();
            }
          },
        ),
        BlocListener<VpnBloc, VpnState>(
          listener: (context, vpnState) {
            if (!_isLoadingLocation) {
              _updateGlobePoints();

              // Update rotation based on connection state
              if (vpnState is VpnConnected) {
                _controller.isRotating = false; // Stop rotation when connected
              } else {
                _controller.isRotating =
                    true; // Resume rotation when disconnected
              }
            }
          },
        ),
      ],
      child: Stack(
        children: [
          // Globe
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: FlutterEarthGlobe(controller: _controller, radius: 120),
          ),
          // Loading indicator
          if (_isLoadingLocation)
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(color: CupertinoColors.white),
                    SizedBox(width: 12),
                    Text(
                      'Loading your location...',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Connection status indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: BlocBuilder<VpnBloc, VpnState>(
              builder: (context, vpnState) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          vpnState is VpnConnected
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.xmark_circle_fill,
                          color: vpnState is VpnConnected
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          vpnState is VpnConnected
                              ? 'Connected'
                              : 'Disconnected',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
