import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, Raju 👋",
                    style: TextStyle(
                      fontFamily: "OpenSans Italic",
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.notifications_none, size: 26),
                ],
              ),

              const SizedBox(height: 20),

              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upcoming Trip",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Pokhara Adventure",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today,
                            color: Colors.white70, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "20 Aug - 25 Aug",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                "Quick Actions",
                style: TextStyle(
                  fontFamily: "Oswald Semibold", 
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(Icons.add, "Create\nTrip"),
                  _actionButton(Icons.map, "Explore"),
                  _actionButton(Icons.group, "Members"),
                  _actionButton(Icons.receipt_long, "Expenses"),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                "Recent Trips",
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              _tripTile("Annapurna Base Camp", "In Progress"),
              _tripTile("Chitwan Safari", "Completed"),
              _tripTile("Everest Base Camp", "Completed"),
              _tripTile("Lumbini Visit", "Completed"),
            ],
          ),
        ),
      ),
    );
  }
  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  Widget _tripTile(String title, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            status,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

