// ignore_for_file: file_names
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
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
