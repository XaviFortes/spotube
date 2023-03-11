import 'package:fl_query/fl_query.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotify/spotify.dart';
import 'package:spotube/hooks/use_spotify_infinite_query.dart';

class CategoryQueries {
  const CategoryQueries();

  InfiniteQuery<Page<Category>, dynamic, int> list(
      WidgetRef ref, String recommendationMarket) {
    final context = useContext();

    return useSpotifyInfiniteQuery<Page<Category>, dynamic, int>(
      "category-playlists",
      (pageParam, spotify) async {
        final categories = await spotify.categories
            .list(country: recommendationMarket)
            .getPage(15, pageParam);

        return categories;
      },
      initialPage: 0,
      nextPage: (lastPage, lastPageData) {
        if (lastPageData.isLast || (lastPageData.items ?? []).length < 15) {
          return null;
        }
        return lastPageData.nextOffset;
      },
      refreshConfig: RefreshConfig.withDefaults(
        context,
        staleDuration: const Duration(minutes: 30),
      ),
      ref: ref,
    );
  }

  InfiniteQuery<Page<PlaylistSimple?>, dynamic, int> playlistsOf(
    WidgetRef ref,
    String category,
  ) {
    return useSpotifyInfiniteQuery<Page<PlaylistSimple?>, dynamic, int>(
      "category-playlists/$category",
      (pageParam, spotify) async {
        final playlists = await Pages<PlaylistSimple?>(
          spotify,
          "v1/browse/categories/$category/playlists",
          (json) => json == null ? null : PlaylistSimple.fromJson(json),
          'playlists',
          (json) => PlaylistsFeatured.fromJson(json),
        ).getPage(5, pageParam);

        return playlists;
      },
      initialPage: 0,
      nextPage: (lastPage, lastPageData) {
        if (lastPageData.isLast || (lastPageData.items ?? []).length < 5) {
          return null;
        }
        return lastPageData.nextOffset;
      },
      ref: ref,
    );
  }
}
