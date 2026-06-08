import 'dart:io';
import 'package:baalkatwao/api_services/auth_notifier.dart';
import 'package:baalkatwao/api_services/auth_services.dart';
import 'package:baalkatwao/pages/MainNavigationPage.dart';
import 'package:baalkatwao/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//------------------------------------------------BusinessHours Class ------------------------------------------------------

bool _isLoading = false;
bool isLoading = false;

class BusinessHours {
  TimeOfDay? openingHour;
  TimeOfDay? closingHour;
  bool? isOpen;
}

//------------------------------------------------Service Class -------------------------------------------------------

class Service {
  String? serviceName;
  double? price;
  int? duration;

  Service({this.serviceName, this.price, this.duration});
}

//------------------------------------------------Onboardingpage Class ------------------------------------------------------
class Onboardingpage extends StatefulWidget {
  const Onboardingpage({super.key});

  @override
  State<Onboardingpage> createState() => _OnboardingpageState();
}

class _OnboardingpageState extends State<Onboardingpage> {
  final _formkey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _capacityController = TextEditingController();
  String selectedBusinessType = 'Barbershop';

  final List<XFile> _salonImages = [];
  final List<Service> _services = [];

  final Map<String, BusinessHours> _businessHours = {
    'MONDAY': BusinessHours(),
    'TUESDAY': BusinessHours(),
    'WEDNESDAY': BusinessHours(),
    'THURSDAY': BusinessHours(),
    'FRIDAY': BusinessHours(),
    'SATURDAY': BusinessHours(),
    'SUNDAY': BusinessHours(),
  };
  @override
  void dispose() {
    _aboutController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  //-----------------------------------------------SectionHeader Method ---------------------------------------------------------
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  //-----------------------------------------------Pick-Images Method -------------------------------------------------------

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage(
      imageQuality: 70,
    );
    if (pickedImages.isNotEmpty) {
      setState(() {
        _salonImages.addAll(pickedImages);
      });
    }
    if (_salonImages.length > 5) {
      setState(() {
        _salonImages.removeRange(5, _salonImages.length);
      });
    }
  }

  void removeimage(int index) {
    setState(() {
      _salonImages.removeAt(index);
    });
  }
  //--------------------------------------------Remove Service Method ----------------------------------------------------------------

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }
  //--------------------------------------------Logout Method ----------------------------------------------------------------

  void _handleLogout() {
    setState(() {
      isLoading = true;
    });
    Provider.of<AuthNotifier>(context, listen: false).clearAuthData();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainNavigationPage(initialindex: 0),
      ),
      (route) => false,
    );
    setState(() {
      isLoading = false;
    });
  }

  //--------------------------------------------Dialog-Add Salon Service Method----------------------------------------------------------
  Future<void> _showAddServiceDialog() async {
    final serviceNameController = TextEditingController();
    final servicePriceController = TextEditingController();
    final serviceDurationController = TextEditingController();
    final dialogformKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Service'),
          content: SingleChildScrollView(
            child: Form(
              key: dialogformKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: serviceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter a service name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: servicePriceController,

                    decoration: const InputDecoration(labelText: 'Price Rs: '),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: serviceDurationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (In minutes)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter a duration';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (dialogformKey.currentState!.validate()) {
                  setState(() {
                    _services.add(
                      Service(
                        serviceName: serviceNameController.text,
                        price: double.parse(servicePriceController.text),
                        duration: int.parse(serviceDurationController.text),
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  //------------------------------------------Select Salon Timings Method-----------------------------------
  Future<void> _selectTime(
    BuildContext context,
    String day,
    bool isOpening,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    setState(() {
      if (picked != null) {
        if (isOpening) {
          _businessHours[day]!.openingHour = picked;
        } else {
          _businessHours[day]!.closingHour = picked;
        }
      }
    });
  }

  //-------------------------------------------Submit Form Method-------------------------------------------

  // Place this method inside your _OnboardingpageState class

  // In your Onboardingpage class

  // Add this state variable at the top of your _OnboardingpageState

  // The helper function to format time
  // In your Onboardingpage class

  // Add this state variable at the top of your _OnboardingpageState

  // The helper function to format time
  String _formatTimeOfDay(TimeOfDay time) {
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  // The final submission method
  Future<void> _submitForm() async {
    if (!_formkey.currentState!.validate()) {
      // ... (Your existing validation logic) ...
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      final token = authNotifier.authToken;
      if (token == null) throw Exception("User not authenticated.");

      // --- PREPARE THE THREE SEPARATE DATA PARTS ---

      // Part 1: The businessProfile object (only simple details)
      Map<String, dynamic> businessProfileDetails = {
        "businessName":
            _nameController.text, // Confirm this key with your friend
        "about": _aboutController.text,
        "business_type": selectedBusinessType,
        "address": _addressController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "capacity": int.tryParse(_capacityController.text) ?? 0,
        "latitude": 0.0,
        "longitude": 0.0,
      };

      // Part 2: The services list
      List<Map<String, dynamic>> formattedServices = [];
      for (var service in _services) {
        formattedServices.add({
          "serviceName": service.serviceName,
          "price": service.price,
          "duration": (service.duration ?? 0) * 60,
        });
      }

      // Part 3: The businessHours list
      List<Map<String, dynamic>> formattedHours = [];
      _businessHours.forEach((day, hours) {
        if (hours.isOpen == true &&
            hours.openingHour != null &&
            hours.closingHour != null) {
          formattedHours.add({
            "day": day,
            "openingHour": _formatTimeOfDay(hours.openingHour!),
            "closingHour": _formatTimeOfDay(hours.closingHour!),
          });
        }
      });

      // --- MAKE THE API CALL ---
      await createBusinessProfile(
        token: token,
        businessProfile: businessProfileDetails, // Part 1
        services: formattedServices, // Part 2
        businessHours: formattedHours, // Part 3
        images: _salonImages
            .map((x) => File(x.path))
            .toList(), // convert XFile -> File
      );

      // --- HANDLE SUCCESS ---
      await authNotifier.refreshUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile submitted successfully for review!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamed(context, Routes.mainbusinesspage);
    } catch (e) {
      // ... (Your existing error handling) ...
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission Failed: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  //------------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //---------------------------------------------- SECTION 1: WELCOME --------------------------------
                  Text(
                    "Welcome!",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(fontSize: 27),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "Fill out the details below to create your salon profile. This information will be visible to your customers.",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 17),
                  ),
                  SizedBox(height: 10.0),

                  //---------------------------------------------- SECTION 2: SALON DETAILS --------------------------------
                  _buildSectionHeader('Salon Details', Icons.storefront),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Salon Name',
                      alignLabelWithHint: true,
                      hintText: 'ABC Men\'s Salon',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please provide a name' : null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _aboutController,
                    decoration: const InputDecoration(
                      labelText: 'About your Salon',
                      alignLabelWithHint: true,
                      hintText: 'Describe what makes your salon special.',
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v!.isEmpty ? 'Please provide a description' : null,
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBusinessType,
                    decoration: const InputDecoration(
                      labelText: 'Business Type',
                    ),
                    items: ['Barbershop', 'Beauty Parlour']
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedBusinessType = value!),
                  ),
                  SizedBox(height: 16.0),
                  //---------------------------------------------- SECTION 3: LOCATION --------------------------------
                  _buildSectionHeader(
                    "Location of your salon",
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Street Address',
                    ),
                    validator: (v) => v!.isEmpty ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'City'),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: const InputDecoration(
                            labelText: 'State/Province',
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      /* will Implement Google Map Picker to get lat/long */
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Set Location on Map"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  //---------------------------------------------- SECTION 4: SALON IMAGES --------------------------------
                  _buildSectionHeader(
                    "Add Photos",
                    Icons.photo_library_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload up to 5 high-quality photos of your salon.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...List.generate(_salonImages.length, (index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_salonImages[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => removeimage(index),
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 12,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_salonImages.length < 5)
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                size: 30,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(),

                  // ----------------------- SECTION 4: SERVICES ------------------------------------------------------
                  _buildSectionHeader(
                    "Your Services",
                    Icons.content_cut_rounded,
                  ),
                  const SizedBox(height: 5.0),
                  _services.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                          child: Text("Click '+' to add your salon services."),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Card(
                                    elevation: 2,
                                    shadowColor: Colors.grey,
                                    child: ListTile(
                                      title: Text(
                                        service.serviceName ??
                                            'Unnamed Service',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Duration: ${service.duration ?? 0} mins",
                                      ),
                                      trailing: Text(
                                        "Rs. ${(service.price ?? 0).toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 7,
                                  right: 7,
                                  child: GestureDetector(
                                    onTap: () => _removeService(index),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 9,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  const SizedBox(height: 5),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                    ),
                    onPressed: _showAddServiceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add a Service"),
                  ),
                  Divider(),
                  //------------------------------------------- SECTION 5: Capacity of YOUR SALON -----------------------------
                  _buildSectionHeader('Capacity of your salon', Icons.chair),
                  SizedBox(height: 5),
                  Text(
                    'How many customers can your salon accommodate at a time?',
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 130,
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        disabledBorder: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        labelText: 'Enter Capacity',
                      ),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 16),

                  //---------------------------------------- --- SECTION 6: OPENING HOURS ------------------------------
                  _buildSectionHeader(
                    "Opening Hours",
                    Icons.access_time_rounded,
                  ),
                  ..._businessHours.entries.map((entry) {
                    final day = entry.key;
                    final hours = entry.value;
                    final isOpen = hours.isOpen ?? false;
                    return Row(
                      children: [
                        Checkbox(
                          value: isOpen,
                          onChanged: (val) =>
                              setState(() => hours.isOpen = val),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            day.substring(0, 1) +
                                day.substring(1).toLowerCase(),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            onPressed: !isOpen
                                ? null
                                : () => _selectTime(context, day, true),
                            child: Text(
                              hours.openingHour?.format(context) ?? 'Open',
                            ),
                          ),
                        ),
                        const Text("-"),
                        Expanded(
                          flex: 3,
                          child: TextButton(
                            onPressed: !isOpen
                                ? null
                                : () => _selectTime(context, day, false),
                            child: Text(
                              hours.closingHour?.format(context) ?? 'Close',
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  // --- SUBMIT BUTTON ---
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitForm(),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text("Submit For Review"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () => _handleLogout(),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text("Log Out"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
