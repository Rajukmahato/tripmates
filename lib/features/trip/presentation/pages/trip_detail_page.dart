import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripmates/app/theme/app_colors.dart';
import 'package:tripmates/app/theme/theme_extensions.dart';

class TripDetailPage extends ConsumerWidget {
  final String title;
  final String location;
  final String category;
  final bool isLost;
  final String description;
  final String reportedBy;
  final String? imageUrl;

  const TripDetailPage({
    super.key,
    required this.title,
    required this.location,
    required this.category,
    required this.isLost,
    required this.description,
    required this.reportedBy,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null && imageUrl!.isNotEmpty
                  ? (imageUrl!.startsWith('http')
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : Image.file(File(imageUrl!), fit: BoxFit.cover))
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.luggage_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isLost
                            ? AppColors.lostGradient
                            : AppColors.foundGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLost ? 'PLANNED' : 'COMPLETED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              Text(
                                location,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description Section
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: context.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Reported By
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withAlpha(51),
                            child: Text(
                              reportedBy[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Created by',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textTertiary,
                                ),
                              ),
                              Text(
                                reportedBy,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
