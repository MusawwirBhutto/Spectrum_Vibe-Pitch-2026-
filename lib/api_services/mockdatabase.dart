class MockDatabase {
  // Yeh static list hamara "Fake Server" hai.
  // User yahan data daalega, aur Salon Dashboard yahan se read karega.
  static List<Map<String, dynamic>> bookings = [
    {
      "id": "123456789",
      "salonName": "Urban Clippers",
      "customerName": "Ahmed Raza", // Ek fake customer
      "service": "Classic Haircut",
      "date": "10/6/2026",
      "time": "15:30 PM",
      "status": "Pending",
      "price": 800.0,
    },
  ];

  static void addBooking(Map<String, dynamic> newBooking) {
    bookings.add(newBooking);
  }
}
