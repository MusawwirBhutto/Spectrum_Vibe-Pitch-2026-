import 'package:baalkatwao/models/SalonModel.dart';
import 'package:baalkatwao/pages/SalonBookingPage.dart';
import 'package:flutter/material.dart';

class SalonDetailPage extends StatelessWidget {
  final Salon salon;

  const SalonDetailPage({super.key, required this.salon});

  @override
  Widget build(BuildContext context) {
    // Get the first photo URL if available
    String? coverImageUrl;
    if (salon.photos.isNotEmpty) {
      coverImageUrl = salon.photos[0].url;
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 100,
            ), // Add padding for bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Cover Image ---
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: (coverImageUrl != null && coverImageUrl.isNotEmpty)
                      ? SafeArea(
                          child: Image.network(
                            coverImageUrl,
                            width: double.infinity,
                            height: 280,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 280,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.store,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 280,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.store,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),

                // --- Salon Info (Name, Rating, Location) ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salon.businessName, // Fixed: Use businessName
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${salon.rating} (${salon.reviewsCount} reviews)", // Fixed: reviewsCount
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              // Fixed: Handle nullable city/address cleanly
                              "${salon.address}, ${salon.city}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // About section (Optional but good)
                      if (salon.about.isNotEmpty) ...[
                        Text(
                          salon.about,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                      ],

                      Text(
                        "From Rs. ${salon.minPrice}",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                const Divider(indent: 24, endIndent: 24),

                // --- Services List ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    "Available Services",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true, // Important inside SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: salon.services.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final Services service = salon.services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.content_cut,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          service.serviceName, // Fixed: Use serviceName
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Rs. ${service.price.toInt()}", // Clean formatting
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Salonbookingpage(
                                  salon: salon,
                                  service: service,
                                ),
                              ),
                            );
                          },
                          child: const Text("Book"),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // --- Custom Back Button ---
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context); // Best practice: Pop to go back
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
