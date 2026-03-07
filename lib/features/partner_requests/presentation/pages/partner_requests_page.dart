import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/features/partner_requests/presentation/state/partner_request_state.dart';
import 'package:tripmates/features/partner_requests/presentation/viewmodel/partner_request_viewmodel.dart';
import 'package:tripmates/features/partner_requests/presentation/widgets/request_card.dart';

/// Partner Requests Page
class PartnerRequestsPage extends ConsumerStatefulWidget {
  const PartnerRequestsPage({super.key});

  @override
  ConsumerState<PartnerRequestsPage> createState() =>
      _PartnerRequestsPageState();
}

class _PartnerRequestsPageState extends ConsumerState<PartnerRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(partnerRequestViewmodelProvider.notifier).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partnerRequestViewmodelProvider);
    final viewmodel = ref.read(partnerRequestViewmodelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Requests'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              viewmodel.setFilter(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Requests')),
              const PopupMenuItem(value: 'received', child: Text('Received')),
              const PopupMenuItem(value: 'sent', child: Text('Sent')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewmodel.loadRequests(refresh: true),
        child: _buildBody(state, viewmodel),
      ),
    );
  }

  Widget _buildBody(
    PartnerRequestState state,
    PartnerRequestViewmodel viewmodel,
  ) {
    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.requests.isEmpty) {
      return _buildErrorState(state.error!, viewmodel);
    }

    if (state.requests.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.requests.length,
      itemBuilder: (context, index) {
        final request = state.requests[index];
        return RequestCard(
          request: request,
          isReceived: state.selectedFilter != 'sent',
          onAccept: () => _handleAccept(request.id, viewmodel),
          onReject: () => _handleReject(request.id, viewmodel),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Partner Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your requests will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, PartnerRequestViewmodel viewmodel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Requests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewmodel.loadRequests(refresh: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(
    String requestId,
    PartnerRequestViewmodel viewmodel,
  ) async {
    final success = await viewmodel.acceptRequest(requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Request accepted successfully'
                : 'Failed to accept request',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleReject(
    String requestId,
    PartnerRequestViewmodel viewmodel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await viewmodel.rejectRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Request rejected' : 'Failed to reject request',
            ),
            backgroundColor: success ? AppColors.primary : Colors.red,
          ),
        );
      }
    }
  }
}
