import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/community_post_model.dart';
import 'heart_burst_overlay.dart';
import 'heart_pop_button.dart';

/// Instagram-style Liquid Glass card widget for community feed posts.
/// Complies with Apple Liquid Glass performance rules (STRICT ZERO JANK:
/// NO [BackdropFilter] inside list items).
class CommunityPostCard extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onShare,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool _isExpanded = false;

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.isNegative || diff.inMinutes < 1) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    } else {
      return '${diff.inDays} дн назад';
    }
  }

  Widget _buildCategoryBadge(String category) {
    final (Color color, IconData icon, String label) = switch (category.toLowerCase()) {
      'sos' => (AppColors.accentRed, Icons.warning_amber_rounded, 'SOS'),
      'health' => (AppColors.accentGreen, Icons.healing_rounded, 'Здоровье'),
      'training' => (AppColors.accentBlue, Icons.sports_rounded, 'Дрессировка'),
      _ => (AppColors.textSecondary, Icons.chat_bubble_outline_rounded, 'Общее'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final timeAgo = _formatTimeAgo(widget.post.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PawAvatar(
          url: widget.post.authorAvatar,
          radius: 18,
          fallbackColor: widget.post.isOfficial ? AppColors.accentBlue : AppColors.accentGreen,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.post.authorName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.post.isOfficial) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: Color(0xFF38BDF8),
                    ),
                  ],
                  if (widget.post.petName != null && widget.post.petName!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🐾 ${widget.post.petName}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // District pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.post.district,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Category badge
                  _buildCategoryBadge(widget.post.category),
                  // Time ago
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedia() {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: HeartBurstOverlay(
          onDoubleTap: widget.onLike,
          child: PawImage(
            url: widget.post.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            borderRadius: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActionsBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HeartPopButton(
              isLiked: widget.post.isLiked,
              likesCount: widget.post.likesCount,
              onTap: widget.onLike,
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: widget.onComment,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.obsidianGlassSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.post.commentsCount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: widget.onShare,
              icon: const Icon(
                Icons.share_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Поделиться',
            ),
          ],
        ),
        IconButton(
          onPressed: widget.onBookmark,
          icon: Icon(
            widget.post.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: widget.post.isBookmarked ? AppColors.accentBlue : AppColors.textSecondary,
            size: 22,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'В закладки',
        ),
      ],
    );
  }

  Widget _buildContent() {
    final isLong = widget.post.content.length > 120;
    final displayContent = (!isLong || _isExpanded)
        ? widget.post.content
        : '${widget.post.content.substring(0, 120)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          displayContent,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'скрыть' : 'ещё...',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsPreview() {
    return GestureDetector(
      onTap: widget.onComment,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          widget.post.commentsCount > 0
              ? 'Посмотреть все ${widget.post.commentsCount} комментариев'
              : 'Написать первый комментарий',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCardTranslucent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white12,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: _buildHeader(),
          ),

          // Media Section
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: _buildMedia(),
            ),
            const SizedBox(height: 12),
          ],

          // Actions Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: _buildActionsBar(),
          ),

          // Content & Caption & Comments Preview
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContent(),
                _buildCommentsPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
