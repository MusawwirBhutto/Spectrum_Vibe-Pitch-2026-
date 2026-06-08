import 'package:baalkatwao/api_services/mockdatabase.dart';
import 'package:flutter/material.dart'; // Apna path check kar lena

class SalonBookingsPage extends StatefulWidget {
  const SalonBookingsPage({super.key});

  @override
  State<SalonBookingsPage> createState() => _SalonBookingsPageState();
}

class _SalonBookingsPageState extends State<SalonBookingsPage> {
  @override
  Widget build(BuildContext context) {
    // Database se saari bookings fetch kar rahe hain
    final bookings = MockDatabase.bookings;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Incoming Appointments"),
        centerTitle: true,
        elevation: 0,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No bookings yet!",
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Share your app with customers to get started.",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              // .reversed use kiya hai taake latest booking upar aaye
              itemBuilder: (context, index) {
                final booking = bookings.reversed.toList()[index];
                final isPending = booking['status'] == "Pending";

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header: Customer Name & Status Badge ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  booking['customerName'] ?? "Guest User",
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.orange.shade100
                                    : (booking['status'] == "Confirmed"
                                          ? Colors.green.shade100
                                          : Colors.red.shade100),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking['status'] ?? "Pending",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPending
                                      ? Colors.orange.shade800
                                      : (booking['status'] == "Confirmed"
                                            ? Colors.green.shade800
                                            : Colors.red.shade800),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // --- Booking Details ---
                        Row(
                          children: [
                            const Icon(Icons.cut, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "Service: ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              "${booking['service']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "When: ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              "${booking['date']} at ${booking['time']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_outlined,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Price: ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            Text(
                              "Rs. ${booking['price']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        // --- Action Buttons (Only show if Pending) ---
                        if (isPending) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      booking['status'] = "Declined";
                                    });
                                  },
                                  child: const Text("Decline"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      booking['status'] = "Confirmed";
                                    });
                                  },
                                  child: const Text("Accept"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
