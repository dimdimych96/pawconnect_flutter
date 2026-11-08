import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/community_post_model.dart';
import 'heart_burst_overlay.dart';
import 'heart_pop_button.dart';
import 'sos_beacon_card.dart';

/// Instagram-style Liquid Glass card widget for community feed posts.
/// Complies with Apple Liquid Glass performance rules (STRICT ZERO JANK:
/// NO [BackdropFilter] inside list items).
class CommunityPostCard extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSightingTap;
  final VoidCallback? onVolunteerTap;
  final VoidCallback? onOpenMapTap;
  final bool isAuthor;
  final bool isAdmin;
  final bool useBeaconLayout;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onBookmark,
    required this.onShare,
    this.onEdit,
    this.onDelete,
    this.onSightingTap,
    this.onVolunteerTap,
    this.onOpenMapTap,
    this.isAuthor = false,
    this.isAdmin = false,
    this.useBeaconLayout = false,
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
    final lower = category.toLowerCase();
    final (Color color, String label) = switch (lower) {
      'sos' => (AppColors.accentRed, 'SOS'),
      'health' => (AppColors.accentGreen, 'Здоровье'),
      'training' => (AppColors.accentBlue, 'Дрессировка'),
      _ => (AppColors.textTertiary, 'Общее'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lower == 'sos')
          Icon(Icons.warning_amber_rounded, size: 12, color: color)
        else
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: lower == 'sos' ? AppColors.accentRed : AppColors.textSecondary,
            fontWeight: lower == 'sos' ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
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
                        fontWeight: FontWeight.w600,
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
                      color: AppColors.accentBlue,
                    ),
                  ],
                  if (widget.post.petName != null && widget.post.petName!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• ${widget.post.petName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.post.district,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  _buildCategoryBadge(widget.post.category),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          key: ValueKey('post_actions_button_${widget.post.id}'),
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          splashRadius: 20,
          onPressed: () => _showActionsSheet(context),
        ),
      ],
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      isScrollControlled: true,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.obsidianCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              if (widget.onEdit != null) ...[
                _buildActionItem(
                  icon: Icons.edit_outlined,
                  title: 'Редактировать запись',
                  color: AppColors.textPrimary,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    widget.onEdit?.call();
                  },
                ),
                const SizedBox(height: 6),
              ],
              if (widget.onDelete != null) ...[
                _buildActionItem(
                  icon: Icons.delete_outline_rounded,
                  title: widget.isAuthor
                      ? 'Удалить запись'
                      : 'Удалить запись (Администратор)',
                  color: AppColors.accentRed,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _showDeleteConfirmationDialog(context);
                  },
                ),
                const SizedBox(height: 6),
              ],
              _buildActionItem(
                icon: Icons.link_rounded,
                title: 'Скопировать ссылку',
                color: AppColors.textPrimary,
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  widget.onShare();
                },
              ),
              if (!widget.isAuthor) ...[
                const SizedBox(height: 6),
                _buildActionItem(
                  icon: Icons.flag_outlined,
                  title: 'Пожаловаться на запись',
                  color: AppColors.accentRed,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final isModeratorAction = !widget.isAuthor && (widget.isAdmin || widget.onDelete != null);

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.obsidianCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: Text(
          isModeratorAction ? 'Удалить запись (Администратор)?' : 'Удалить публикацию?',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          isModeratorAction
              ? 'Вы удаляете публикацию пользователя ${widget.post.authorName} с правами администратора. Это действие нельзя отменить.'
              : 'Это действие нельзя отменить. Публикация и все комментарии будут удалены навсегда.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            key: const ValueKey('confirm_delete_post_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onDelete?.call();
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: HeartBurstOverlay(
          onDoubleTap: widget.onLike,
          child: PawImage(
            url: widget.post.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            borderRadius: 10,
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
            const SizedBox(width: 12),
            InkWell(
              onTap: widget.onComment,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.post.commentsCount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        fontFeatures: [FontFeature.tabularFigures()],
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
            color: widget.post.isBookmarked ? AppColors.textPrimary : AppColors.textSecondary,
            size: 20,
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
            fontWeight: FontWeight.w600,
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
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
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
    if (widget.useBeaconLayout && widget.post.category.toLowerCase() == 'sos') {
      return SosBeaconCard(
        post: widget.post,
        isAuthor: widget.isAuthor,
        isAdmin: widget.isAdmin,
        onLike: widget.onLike,
        onComment: widget.onComment,
        onShare: widget.onShare,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
        onSightingTap: widget.onSightingTap ?? () {},
        onVolunteerTap: widget.onVolunteerTap ?? () {},
        onOpenMapTap: widget.onOpenMapTap ?? () {},
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1.0,
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
            const SizedBox(height: 10),
          ],

          // Actions Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _buildActionsBar(),
          ),

          // Content & Caption & Comments Preview
          Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 14.0),
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
