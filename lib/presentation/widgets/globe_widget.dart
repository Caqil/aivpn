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
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';

class GlobeWidget extends StatefulWidget {
  const GlobeWidget({Key? key}) : super(key: key);

  @override
  State<GlobeWidget> createState() => _GlobeWidgetState();
}

class _GlobeWidgetState extends State<GlobeWidget> {
  late FlutterEarthGlobeController _controller;
  List<Point> points = [];
  List<PointConnection> connections = [];

  @override
  void initState() {
    super.initState();
    _initializeGlobe();
  }

  void _initializeGlobe() {
    _controller = FlutterEarthGlobeController(
      maxZoom: 0.5,
      sphereStyle: const SphereStyle(
        shadowColor: CupertinoColors.systemCyan,
        shadowBlurSigma: 30,
      ),
      rotationSpeed: 0.05,
      zoom: 0.5,
      minZoom: 0.48,
      isRotating: false,
      isBackgroundFollowingSphereRotation: true,
      background: Image.asset('assets/2k_stars.jpg').image,
      surface: Image.asset('assets/day.jpg').image,
    );
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
            ? CupertinoColors.systemRed.withOpacity(0.8)
            : CupertinoColors.systemRed.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        point.label ?? '',
        style: CupertinoTheme.of(
          context,
        ).textTheme.textStyle.copyWith(color: CupertinoColors.white),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHovering
            ? CupertinoColors.systemBlue.withOpacity(0.8)
            : CupertinoColors.systemBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        connection.label ?? '',
        style: CupertinoTheme.of(
          context,
        ).textTheme.textStyle.copyWith(color: CupertinoColors.white),
      ),
    );
  }

  void _updateGlobePoints() {
    try {
      final serverState = context.read<ServerBloc>().state;
      final vpnState = context.read<VpnBloc>().state;

      // Try to get UserBloc state, but don't fail if it's not available
      UserState? userState;
      try {
        userState = context.read<UserBloc>().state;
      } catch (e) {
        print('UserBloc not available: $e');
      }

      if (serverState is! ServerLoaded) {
        return;
      }

      // Clear existing points and connections
      for (var point in points) {
        _controller.removePoint(point.id);
      }
      for (var connection in connections) {
        _controller.removePointConnection(connection.id);
      }

      points.clear();
      connections.clear();

      // User location point (static for now, you can implement geolocation)
      final userPoint = Point(
        id: '1',
        coordinates: const GlobeCoordinates(
          40.7128,
          -74.0060,
        ), // New York as default
        label: 'Your Location',
        labelBuilder: _buildPointLabel,
        style: const PointStyle(color: CupertinoColors.systemRed, size: 6),
      );
      points.add(userPoint);

      // Server point (if selected)
      if (serverState.selectedServer != null) {
        final serverPoint = Point(
          id: '2',
          coordinates: GlobeCoordinates(
            _parseCoordinate(
              serverState.selectedServer!.address,
            ), // Use address as latitude for demo
            _parseCoordinate(
              serverState.selectedServer!.port.toString(),
            ), // Use port as longitude for demo
          ),
          label: serverState.selectedServer!.displayName,
          labelBuilder: _buildPointLabel,
          style: const PointStyle(color: CupertinoColors.systemGreen, size: 6),
        );
        points.add(serverPoint);

        // Add connection if VPN is connected
        if (vpnState is VpnConnected) {
          final connection = PointConnection(
            id: '1',
            start: userPoint.coordinates,
            end: serverPoint.coordinates,
            isMoving: true,
            labelBuilder: _buildConnectionLabel,
            isLabelVisible: false,
            style: const PointConnectionStyle(
              type: PointConnectionType.solid,
              color: CupertinoColors.systemRed,
              lineWidth: 3,
              dashSize: 4,
              spacing: 10,
            ),
            label: 'Connected to ${serverState.selectedServer!.name}',
          );
          connections.add(connection);
        }
      }

      // Update globe with new points and connections
      _controller.onLoaded = () {
        for (var point in points) {
          _controller.addPoint(point);
        }
        for (var connection in connections) {
          _controller.addPointConnection(connection, animateDraw: true);
        }

        // Focus on appropriate location
        if (vpnState is VpnConnected && points.length > 1) {
          _controller.focusOnCoordinates(points[1].coordinates, animate: true);
        } else {
          _controller.focusOnCoordinates(points[0].coordinates, animate: true);
        }
      };
    } catch (e) {
      print('Error updating globe points: $e');
    }
  }

  double _parseCoordinate(String value) {
    // Simple coordinate parsing - in real app, you'd have proper coordinates
    // This is just for demonstration
    try {
      final hash = value.hashCode;
      return (hash % 180).toDouble() - 90; // Range: -90 to 90
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ServerBloc, ServerState>(
          listener: (context, serverState) {
            _updateGlobePoints();
          },
        ),
        BlocListener<VpnBloc, VpnState>(
          listener: (context, vpnState) {
            _updateGlobePoints();
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, userState) {
            _updateGlobePoints();
          },
        ),
      ],
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: FlutterEarthGlobe(controller: _controller, radius: 120),
      ),
    );
  }
}
