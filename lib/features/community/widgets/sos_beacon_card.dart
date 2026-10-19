import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/paw_image.dart';
import '../../../models/community_post_model.dart';
import 'heart_burst_overlay.dart';
import 'heart_pop_button.dart';

/// Enriched Apple Liquid Glass SOS Beacon Card for Tab 0 feed.
/// STRICT ZERO JANK: No [BackdropFilter] inside scrolling items.
class SosBeaconCard extends StatefulWidget {
  final CommunityPostModel post;
  final VoidCallback onSightingTap;
  final VoidCallback onVolunteerTap;
  final VoidCallback onOpenMapTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAuthor;
  final bool isAdmin;

  const SosBeaconCard({
    super.key,
    required this.post,
    required this.onSightingTap,
    required this.onVolunteerTap,
    required this.onOpenMapTap,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.onEdit,
    this.onDelete,
    this.isAuthor = false,
    this.isAdmin = false,
  });

  @override
  State<SosBeaconCard> createState() => _SosBeaconCardState();
}

class _SosBeaconCardState extends State<SosBeaconCard> {
  bool _isExpanded = false;

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    if (diff.inHours < 24) return '${diff.inHours} ч назад';
    return '${diff.inDays} дн назад';
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(widget.post.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131318),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentRed.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentRed.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Urgency Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🚨 СРОЧНЫЙ ПОИСК',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Пропал $timeAgo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.accentRed.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: widget.onOpenMapTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 13, color: AppColors.accentBlue),
                        SizedBox(width: 4),
                        Text(
                          'На карте',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Author & Pet info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                PawAvatar(
                  url: widget.post.authorAvatar,
                  radius: 18,
                  fallbackColor: AppColors.accentRed,
                  fallbackIcon: Icons.pets_rounded,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.authorName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.post.petName != null && widget.post.petName!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🐾 ${widget.post.petName}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Район: ${widget.post.district}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Post Content / Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.post.title.isNotEmpty) ...[
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  widget.post.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (widget.post.content.length > 120 && !_isExpanded)
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = true),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Читать полностью...',
                        style: TextStyle(
                          color: AppColors.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 4. Photo Media if present
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: HeartBurstOverlay(
                    onDoubleTap: widget.onLike,
                    child: PawImage(
                      url: widget.post.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

          // 5. Interactive SOS Command Deck («Замечен здесь» & «Помочь в поиске»)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // «Замечен здесь» (Spotting Signal)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onSightingTap,
                          icon: const Icon(Icons.pin_drop_rounded, size: 16, color: Colors.white),
                          label: const Text(
                            'Замечен здесь',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // «Помочь в поиске» (Volunteer Toggle)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onVolunteerTap,
                          icon: Icon(
                            widget.post.isVolunteering ? Icons.check_circle_rounded : Icons.group_add_rounded,
                            size: 16,
                            color: widget.post.isVolunteering ? AppColors.accentGreen : AppColors.textPrimary,
                          ),
                          label: Text(
                            widget.post.isVolunteering ? 'В отряде' : 'Помочь в поиске',
                            style: TextStyle(
                              color: widget.post.isVolunteering ? AppColors.accentGreen : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: widget.post.isVolunteering
                                ? AppColors.accentGreen.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.06),
                            side: BorderSide(
                              color: widget.post.isVolunteering
                                  ? AppColors.accentGreen.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Telemetry Counters
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.volunteersCount} в отряде',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.sightingsCount} отметок следа',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 6. Action Bar (Likes, Comments, Share)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
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
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  splashRadius: 20,
                  onPressed: widget.onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
