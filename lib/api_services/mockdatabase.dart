class MockDatabase {
  // Yeh static list hamara "Fake Server" hai.
  // User yahan data daalega, aur Salon Dashboard yahan se read karega.
  static List<Map<String, dynamic>> bookings = [];

  static void addBooking(Map<String, dynamic> newBooking) {
    bookings.add(newBooking);
  }
}
