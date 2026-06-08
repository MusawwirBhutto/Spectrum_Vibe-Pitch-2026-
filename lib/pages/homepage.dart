// lib/pages/Homepage.dart

import 'dart:async';
import 'package:baalkatwao/api_services/auth_notifier.dart';
// import 'package:baalkatwao/api_services/auth_services.dart'; // MOCKING KE LIYE REAL API COMMENT KAR DI
import 'package:baalkatwao/models/SalonModel.dart';
import 'package:baalkatwao/pages/SalonDetailPage.dart';
import 'package:baalkatwao/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // --- STATE FOR VERTICAL LIST (DISCOVER ALL) ---
  final ScrollController _mainScrollController = ScrollController();
  final List<Salon> _discoverSalons = [];

  bool _isVerticalLoading = false;
  bool _hasMoreVertical = true;
  late bool _isGlobalError = false;
  late int _verticalPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchVerticalSalons(); // Load Discover All Data
    _mainScrollController.addListener(_onVerticalScroll);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  // --- VERTICAL SCROLL LISTENER ---
  void _onVerticalScroll() {
    if (_mainScrollController.position.pixels >=
        _mainScrollController.position.maxScrollExtent - 50) {
      _fetchVerticalSalons();
    }
  }

  // --- VERTICAL DATA FETCH (MOCKED) ---
  Future<void> _fetchVerticalSalons() async {
    if (_isVerticalLoading || !_hasMoreVertical) return;

    setState(() {
      _isVerticalLoading = true;
      _isGlobalError = false;
    });

    try {
      // 🚀 MOCK API CALL YAHAN LAGI HAI
      final List<Salon> newSalons = await _getMockSalons(
        pageNumber: _verticalPage,
        pageSize: 5,
      );

      if (newSalons.length < 5) {
        _hasMoreVertical = false; // Stop loading if less than 5 items returned
      }

      setState(() {
        _discoverSalons.addAll(newSalons);
        _verticalPage++;
      });
    } catch (error) {
      debugPrint("Vertical API Error: $error");
      if (_discoverSalons.isEmpty) {
        setState(() => _isGlobalError = true);
      }
    } finally {
      if (mounted) setState(() => _isVerticalLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, child) {
        final String welcomeName =
            auth.userData?['username'] ?? 'Valued Customer';

        return Scaffold(
          backgroundColor: appTheme.scaffoldBackgroundColor,
          body: _isGlobalError
              ? _buildErrorScreen()
              : CustomScrollView(
                  controller: _mainScrollController,
                  slivers: [
                    // ==========================================
                    // 1. HEADER & SEARCH BAR
                    // ==========================================
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: Text(
                                'Hello, $welcomeName!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              'Find your perfect look today.',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ),
                          const SearchBarWidget(),
                        ],
                      ),
                    ),

                    // ==========================================
                    // 2. FEATURED SALONS (Horizontal Infinite)
                    // ==========================================
                    SliverToBoxAdapter(
                      child: HorizontalInfiniteSection(
                        title: "Featured Salons",
                        onFetchData: (page, size) async {
                          // 🚀 MOCK API CALL
                          return await _getMockSalons(
                            pageNumber: page,
                            pageSize: size,
                          );
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // ==========================================
                    // 3. NEARBY SALONS (Horizontal Infinite)
                    // ==========================================
                    SliverToBoxAdapter(
                      child: HorizontalInfiniteSection(
                        title: "Nearby You",
                        onFetchData: (page, size) async {
                          // 🚀 MOCK API CALL
                          return await _getMockSalons(
                            pageNumber: page,
                            pageSize: size,
                          );
                        },
                      ),
                    ),

                    // ==========================================
                    // 4. DISCOVER ALL HEADER
                    // ==========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                        child: Text(
                          'Discover All',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ),
                    ),

                    // ==========================================
                    // 5. DISCOVER ALL LIST (Vertical Infinite)
                    // ==========================================
                    _discoverSalons.isEmpty && _isVerticalLoading
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(50),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return _buildVerticalSalonCard(
                                _discoverSalons[index],
                              );
                            }, childCount: _discoverSalons.length),
                          ),

                    // ==========================================
                    // 6. VERTICAL BOTTOM SPINNER
                    // ==========================================
                    if (_isVerticalLoading && _discoverSalons.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
        );
      },
    );
  }

  // --- WIDGET: Vertical Card ---
  Widget _buildVerticalSalonCard(Salon salon) {
    String? imgUrl;
    if (salon.photos.isNotEmpty) imgUrl = salon.photos[0].url;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalonDetailPage(salon: salon),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: (imgUrl != null && imgUrl.isNotEmpty)
                    ? Image.network(
                        imgUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.store),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon.businessName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${salon.rating} (${salon.reviewsCount} reviews)",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      salon.services.isEmpty
                          ? "Pricing unavailable"
                          : "From Rs. ${salon.minPrice}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Global Error Screen ---
  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            "Server Connection lost.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _fetchVerticalSalons,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry Connection"),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// MOCK DATA FUNCTION (API BYPASS)
// =========================================================================
Future<List<Salon>> _getMockSalons({
  required int pageNumber,
  required int pageSize,
}) async {
  // Realistic API delay
  await Future.delayed(const Duration(seconds: 1));

  // Sirf 2 page tak data dikhayenge taake pagination real lagay
  if (pageNumber > 1) return [];

  final List<Map<String, dynamic>> dummyData = [
    {
      "businessName": "Urban Clippers",
      "rating": 4.8,
      "reviewsCount": 124,
      "minPrice": 800,
      "services": [
        {"name": "Haircut"},
      ],
      "photos": [
        {
          "url":
              "https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&q=80",
        },
      ],
    },
    {
      "businessName": "The Fade Studio",
      "rating": 4.5,
      "reviewsCount": 89,
      "minPrice": 1200,
      "services": [
        {"name": "Haircut"},
        {"name": "Beard"},
      ],
      "photos": [
        {
          "url":
              "https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&q=80",
        },
      ],
    },
    {
      "businessName": "Style Lounge",
      "rating": 4.2,
      "reviewsCount": 45,
      "minPrice": 500,
      "services": [
        {"name": "Trimming"},
      ],
      "photos": [
        {
          "url":
              "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&q=80",
        },
      ],
    },
  ];

  try {
    // DEVELOPER NOTE: Agar tumhare SalonModel mein fromJson ki jagah fromMap hai,
    // toh neechay .fromJson ki jagah .fromMap likh dena.
    return dummyData.map((data) => Salon.fromJson(data)).toList();
  } catch (e) {
    debugPrint("Mock Data Error (Please check SalonModel constructor): $e");
    return [];
  }
}

// =========================================================================
// REUSABLE CLASS: HORIZONTAL INFINITE SECTION
// =========================================================================

class HorizontalInfiniteSection extends StatefulWidget {
  final String title;
  final Future<List<Salon>> Function(int page, int pageSize) onFetchData;

  const HorizontalInfiniteSection({
    super.key,
    required this.title,
    required this.onFetchData,
  });

  @override
  State<HorizontalInfiniteSection> createState() =>
      _HorizontalInfiniteSectionState();
}

class _HorizontalInfiniteSectionState extends State<HorizontalInfiniteSection> {
  final ScrollController _horizontalController = ScrollController();
  final List<Salon> _salons = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadMoreData(); // Initial Load
    _horizontalController.addListener(_onHorizontalScroll);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  void _onHorizontalScroll() {
    if (_horizontalController.position.pixels >=
        _horizontalController.position.maxScrollExtent - 50) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      List<Salon> newItems = await widget.onFetchData(_currentPage, 5);

      if (newItems.length < 5) {
        _hasMore = false;
      }

      setState(() {
        _salons.addAll(newItems);
        _currentPage++;
      });
    } catch (e) {
      debugPrint("Horizontal List Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_salons.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _salons.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _salons.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return _buildHorizontalCard(_salons[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCard(Salon salon) {
    String? imgUrl;
    if (salon.photos.isNotEmpty) imgUrl = salon.photos[0].url;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, top: 5, bottom: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: (imgUrl != null && imgUrl.isNotEmpty)
                    ? Image.network(
                        imgUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.store),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${salon.rating} ⭐",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// SEARCH BAR WIDGET
// =========================================================================

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search salons...',
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
        ),
      ),
    );
  }
}
