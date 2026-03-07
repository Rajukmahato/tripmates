import 'package:flutter/material.dart';

enum RequestStatus { pending, accepted, rejected, cancelled }

class PartnerRequest {
  final String requestId;
  final String senderName;
  final String senderId;
  final String tripName;
  final String tripId;
  final RequestStatus status;
  final DateTime sentDate;
  final String? message;

  PartnerRequest({
    required this.requestId,
    required this.senderName,
    required this.senderId,
    required this.tripName,
    required this.tripId,
    required this.status,
    required this.sentDate,
    this.message,
  });
}

class PartnerRequestCard extends StatelessWidget {
  final PartnerRequest request;
  final bool isIncoming;
  final Function()? onAccept;
  final Function()? onReject;
  final Function()? onCancel;

  const PartnerRequestCard({
    super.key,
    required this.request,
    required this.isIncoming,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(child: Text(request.senderName[0].toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Trip: ${request.tripName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            const SizedBox(height: 12),

            // Message (if any)
            if (request.message != null && request.message!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.message!,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),

            // Date
            Text(
              _formatDate(request.sentDate),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),

            // Actions
            if (request.status == RequestStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isIncoming)
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: onReject,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: onAccept,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Accept'),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Cancel Request'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    final (label, color) = switch (status) {
      RequestStatus.pending => ('Pending', Colors.orange),
      RequestStatus.accepted => ('Accepted', Colors.green),
      RequestStatus.rejected => ('Rejected', Colors.red),
      RequestStatus.cancelled => ('Cancelled', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return date.toString().split(' ')[0];
    }
  }
}

class PartnerRequestsPage extends StatefulWidget {
  const PartnerRequestsPage({super.key});

  @override
  State<PartnerRequestsPage> createState() => _PartnerRequestsPageState();
}

class _PartnerRequestsPageState extends State<PartnerRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<PartnerRequest> _receivedRequests = [
    PartnerRequest(
      requestId: '1',
      senderName: 'Alice Johnson',
      senderId: 'user1',
      tripName: 'Mountain Hiking Adventure',
      tripId: 'trip1',
      status: RequestStatus.pending,
      sentDate: DateTime.now().subtract(const Duration(hours: 2)),
      message: 'Hi! I\'d love to join your hiking trip!',
    ),
  ];

  final List<PartnerRequest> _sentRequests = [
    PartnerRequest(
      requestId: '2',
      senderName: 'Bob Smith',
      senderId: 'user2',
      tripName: 'Beach Volleyball Getaway',
      tripId: 'trip2',
      status: RequestStatus.accepted,
      sentDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Requests'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Received'),
                  if (_receivedRequests.isNotEmpty)
                    Badge(label: Text(_receivedRequests.length.toString())),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sent'),
                  if (_sentRequests.isNotEmpty)
                    Badge(label: Text(_sentRequests.length.toString())),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Received Tab
          _receivedRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No received requests',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _receivedRequests.length,
                  itemBuilder: (context, index) => PartnerRequestCard(
                    request: _receivedRequests[index],
                    isIncoming: true,
                    onAccept: () {
                      setState(() {
                        _receivedRequests[index] = PartnerRequest(
                          requestId: _receivedRequests[index].requestId,
                          senderName: _receivedRequests[index].senderName,
                          senderId: _receivedRequests[index].senderId,
                          tripName: _receivedRequests[index].tripName,
                          tripId: _receivedRequests[index].tripId,
                          status: RequestStatus.accepted,
                          sentDate: _receivedRequests[index].sentDate,
                          message: _receivedRequests[index].message,
                        );
                      });
                    },
                    onReject: () {
                      setState(() {
                        _receivedRequests[index] = PartnerRequest(
                          requestId: _receivedRequests[index].requestId,
                          senderName: _receivedRequests[index].senderName,
                          senderId: _receivedRequests[index].senderId,
                          tripName: _receivedRequests[index].tripName,
                          tripId: _receivedRequests[index].tripId,
                          status: RequestStatus.rejected,
                          sentDate: _receivedRequests[index].sentDate,
                          message: _receivedRequests[index].message,
                        );
                      });
                    },
                  ),
                ),

          // Sent Tab
          _sentRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sent requests',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _sentRequests.length,
                  itemBuilder: (context, index) => PartnerRequestCard(
                    request: _sentRequests[index],
                    isIncoming: false,
                    onCancel: () {
                      setState(() {
                        _sentRequests[index] = PartnerRequest(
                          requestId: _sentRequests[index].requestId,
                          senderName: _sentRequests[index].senderName,
                          senderId: _sentRequests[index].senderId,
                          tripName: _sentRequests[index].tripName,
                          tripId: _sentRequests[index].tripId,
                          status: RequestStatus.cancelled,
                          sentDate: _sentRequests[index].sentDate,
                          message: _sentRequests[index].message,
                        );
                      });
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
