import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, lowBandwidth, offline }

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  final connectivityResult = ref.watch(connectivityStreamProvider);
  
  return connectivityResult.when(
    data: (results) {
      if (results.contains(ConnectivityResult.none)) {
        return ConnectivityStatus.offline;
      }
      if (results.contains(ConnectivityResult.mobile)) {
        return ConnectivityStatus.lowBandwidth;
      }
      return ConnectivityStatus.online;
    },
    loading: () => ConnectivityStatus.online,
    error: (_, _) => ConnectivityStatus.online,
  );
});
