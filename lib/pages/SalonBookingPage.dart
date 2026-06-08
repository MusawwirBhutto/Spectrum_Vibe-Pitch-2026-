// ignore_for_file: file_names
import 'package:baalkatwao/api_services/mockdatabase.dart';
import 'package:baalkatwao/models/SalonModel.dart';
import 'package:flutter/material.dart';

class Salonbookingpage extends StatefulWidget {
  final Salon salon;
  final Services service;

  const Salonbookingpage({
    super.key,
    required this.salon,
    required this.service,
  });

  @override
  State<Salonbookingpage> createState() => _BookingPageState();
}

class _BookingPageState extends State<Salonbookingpage> {
  String? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize the selected service with the one passed from the previous page
    selectedService = widget.service.serviceName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Book at ${widget.salon.businessName}",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Services Dropdown ---
            Text(
              "Select Service",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedService,
              hint: const Text("Choose a service"),
              items: widget.salon.services.map((service) {
                return DropdownMenuItem<String>(
                  value: service.serviceName,
                  child: Text(
                    "${service.serviceName} - Rs. ${service.price}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Date Picker ---
            Text("Select Date", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).colorScheme.primary,
                          onPrimary: Theme.of(context).colorScheme.onPrimary,
                          onSurface: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() => selectedDate = pickedDate);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        selectedDate == null
                            ? "Choose Date"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Time Picker ---
            Text("Select Time", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Theme.of(context).colorScheme.primary,
                          onPrimary: Theme.of(context).colorScheme.onPrimary,
                          onSurface: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime != null) {
                  setState(() => selectedTime = pickedTime);
                }
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        selectedTime == null
                            ? "Choose Time"
                            : "${selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period.name.toUpperCase()}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // --- Corrected Confirm Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (selectedService != null &&
                        selectedDate != null &&
                        selectedTime != null)
                    ? () async {
                        // 1. Show Fake Loading Spinner
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // 2. Simulate Network Delay (2 seconds)
                        await Future.delayed(const Duration(seconds: 2));

                        // 3. Save Data to our Mock Database
                        MockDatabase.addBooking({
                          "id": DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          "salonName": widget.salon.businessName,
                          "customerName": "Guest User",
                          "service": selectedService,
                          "date":
                              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                          "time":
                              "${selectedTime!.hourOfPeriod}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period.name.toUpperCase()}",
                          "status": "Pending",
                          "price": widget.service.price,
                        });

                        // 4. Close the Loading Spinner
                        if (context.mounted) Navigator.pop(context);

                        // 5. Show Success Message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Booking Successful! Sent to Salon.",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // 6. Go back to the previous page
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: Text(
                  "Confirm Booking",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
