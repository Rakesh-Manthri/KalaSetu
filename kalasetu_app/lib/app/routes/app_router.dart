import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kalasetu_app/features/home/presentation/screens/home_screen.dart';
import 'package:kalasetu_app/features/capture/presentation/screens/camera_screen.dart';
import 'package:kalasetu_app/features/capture/presentation/screens/voice_screen.dart';
import 'package:kalasetu_app/features/listing_preview/presentation/screens/listing_preview_screen.dart';
import 'package:kalasetu_app/features/my_listings/presentation/screens/my_listings_screen.dart';
import 'package:kalasetu_app/features/craft_passport/presentation/screens/craft_passport_screen.dart';
import 'package:kalasetu_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:kalasetu_app/features/profile/presentation/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/voice',
        redirect: (context, state) {
          if (state.extra == null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) {
          final imagePaths = state.extra as List<String>;
          return VoiceScreen(imagePaths: imagePaths);
        },
      ),
      GoRoute(
        path: '/preview',
        redirect: (context, state) {
          if (state.extra == null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final imagePaths = (extra['imagePaths'] as List).cast<String>();
          final audioPath = extra['audioPath'] as String;
          return ListingPreviewScreen(
            imagePaths: imagePaths,
            audioPath: audioPath,
          );
        },
      ),
      GoRoute(
        path: '/listings',
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/passport/:id',
        redirect: (context, state) {
          if (state.pathParameters['id'] == null) {
            return '/';
          }
          return null;
        },
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CraftPassportScreen(listingId: id);
        },
      ),
    ],
  );
});
