import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/news.dart';
import '../../services/news_service.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  late Future<List<News>> _newsFuture;
  final NewsService _newsService = NewsService(baseUrl: 'http://localhost:8383');

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.getLatestNews();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _newsFuture = _newsService.getLatestNews();
    });
    await _newsFuture;
  }

  Future<void> _openArticle(News news) async {
    final messenger = ScaffoldMessenger.of(context);
    final articleUrl = news.articleUrl?.trim();

    if (articleUrl == null || articleUrl.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Esta noticia no tiene un enlace válido para abrir.')),
      );
      return;
    }

    final uri = Uri.tryParse(articleUrl);
    final isValid = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    if (!isValid) {
      messenger.showSnackBar(
        const SnackBar(content: Text('El enlace de la noticia no es válido.')),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (!launched && mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la noticia en este momento.')),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la noticia en este momento.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surface,
              scheme.surfaceContainerLowest,
              scheme.primaryContainer.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: FutureBuilder<List<News>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _NewsLoadingState();
            }

            if (snapshot.hasError) {
              return _NewsErrorState(
                message: _friendlyError(snapshot.error),
                onRetry: _refreshNews,
              );
            }

            final news = snapshot.data ?? const <News>[];
            if (news.isEmpty) {
              return _NewsEmptyState(onRetry: _refreshNews);
            }

            final sortedNews = _sortByDate(news);
            final breakingNews = sortedNews.take(5).toList(growable: false);
            final institutionalNews = sortedNews.where(_isInstitutional).toList(growable: false);
            final relevantNews = sortedNews.where((item) => !_isInstitutional(item)).toList(growable: false);

            return RefreshIndicator(
              onRefresh: _refreshNews,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1100;
                  final horizontalPadding = isWide ? 28.0 : 18.0;
                  final panelHeight = isWide ? 540.0 : 480.0;
                  final screenHeight = MediaQuery.sizeOf(context).height;
                  final breakingPanelHeight = (screenHeight * 0.36).clamp(300.0, 380.0);

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 28),
                        children: [
                          _DashboardHeader(
                            totalItems: news.length,
                            breakingItems: breakingNews.length,
                            relevantItems: relevantNews.length,
                            institutionalItems: institutionalNews.length,
                          ),
                          const SizedBox(height: 18),
                          _SectionPanel(
                            title: 'Último minuto',
                            subtitle: '3 a 5 noticias recientes en un carrusel horizontal',
                            accentColor: scheme.primary,
                            child: SizedBox(
                              height: breakingPanelHeight,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: breakingNews.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  return _BreakingNewsCard(
                                    news: breakingNews[index],
                                    onOpenArticle: _openArticle,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _SectionPanel(
                                    title: 'Noticias relevantes',
                                    subtitle: 'Lista vertical con scroll independiente',
                                    accentColor: scheme.secondary,
                                    child: SizedBox(
                                      height: panelHeight,
                                      child: relevantNews.isEmpty
                                          ? const _PanelEmptyState(
                                              icon: Icons.feed_outlined,
                                              title: 'No hay noticias relevantes separadas',
                                              message: 'Todas las noticias actuales están clasificadas como institucionales o el feed aún es demasiado corto.',
                                            )
                                          : ListView.separated(
                                              physics: const BouncingScrollPhysics(),
                                              itemCount: relevantNews.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                                              itemBuilder: (context, index) {
                                                return _RelevantNewsTile(
                                                  news: relevantNews[index],
                                                  onOpenArticle: _openArticle,
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: _SectionPanel(
                                    title: 'Noticias institucionales',
                                    subtitle: 'DIAN, Cámara de Comercio y entidades gubernamentales',
                                    accentColor: scheme.tertiary,
                                    child: SizedBox(
                                      height: panelHeight,
                                      child: institutionalNews.isEmpty
                                          ? const _PanelEmptyState(
                                              icon: Icons.account_balance_outlined,
                                              title: 'Sin noticias institucionales',
                                              message: 'Cuando aparezcan fuentes como DIAN, Cámara de Comercio o gobierno, se mostrarán aquí.',
                                            )
                                          : ListView.separated(
                                              physics: const BouncingScrollPhysics(),
                                              itemCount: institutionalNews.length,
                                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                                              itemBuilder: (context, index) {
                                                return _InstitutionalNewsTile(
                                                  news: institutionalNews[index],
                                                  onOpenArticle: _openArticle,
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _SectionPanel(
                              title: 'Noticias relevantes',
                              subtitle: 'Lista vertical con scroll independiente',
                              accentColor: scheme.secondary,
                              child: SizedBox(
                                height: panelHeight,
                                child: relevantNews.isEmpty
                                    ? const _PanelEmptyState(
                                        icon: Icons.feed_outlined,
                                        title: 'No hay noticias relevantes separadas',
                                        message: 'Todas las noticias actuales están clasificadas como institucionales o el feed aún es demasiado corto.',
                                      )
                                    : ListView.separated(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: relevantNews.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          return _RelevantNewsTile(
                                            news: relevantNews[index],
                                            onOpenArticle: _openArticle,
                                          );
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _SectionPanel(
                              title: 'Noticias institucionales',
                              subtitle: 'DIAN, Cámara de Comercio y entidades gubernamentales',
                              accentColor: scheme.tertiary,
                              child: SizedBox(
                                height: panelHeight,
                                child: institutionalNews.isEmpty
                                    ? const _PanelEmptyState(
                                        icon: Icons.account_balance_outlined,
                                        title: 'Sin noticias institucionales',
                                        message: 'Cuando aparezcan fuentes como DIAN, Cámara de Comercio o gobierno, se mostrarán aquí.',
                                      )
                                    : ListView.separated(
                                        physics: const BouncingScrollPhysics(),
                                        itemCount: institutionalNews.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          return _InstitutionalNewsTile(
                                            news: institutionalNews[index],
                                            onOpenArticle: _openArticle,
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  List<News> _sortByDate(List<News> items) {
    final sorted = List<News>.from(items);
    sorted.sort((left, right) {
      final leftTime = left.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final rightTime = right.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return rightTime.compareTo(leftTime);
    });
    return sorted;
  }

  bool _isInstitutional(News news) {
    final text = _normalize(
      [news.title, news.summary, news.source, news.category].whereType<String>().join(' '),
    );

    return _InstitutionalTag.all.any((tag) => tag.matches(text));
  }

  String _friendlyError(Object? error) {
    if (error is NewsServiceException) {
      return error.message;
    }
    return 'No fue posible cargar las noticias en este momento.';
  }

  String _normalize(String value) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    var normalized = value.toLowerCase();
    replacements.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }
}

class _DashboardHeader extends StatelessWidget {
  final int totalItems;
  final int breakingItems;
  final int relevantItems;
  final int institutionalItems;

  const _DashboardHeader({
    required this.totalItems,
    required this.breakingItems,
    required this.relevantItems,
    required this.institutionalItems,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surface,
            scheme.primaryContainer.withValues(alpha: 0.82),
            scheme.secondaryContainer.withValues(alpha: 0.60),
          ],
        ),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;

          final headline = Text(
            'Noticias compactas para formalización y emprendimiento',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'NotoSerif',
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              height: 1.08,
            ),
          );

          final description = Text(
            'Último minuto, noticias relevantes e institucionales en una vista más densa, pensada para aprovechar mejor el espacio visible.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.84),
              height: 1.45,
            ),
          );

          final stats = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: 'Total', value: '$totalItems', icon: Icons.newspaper_rounded, accentColor: scheme.primary),
              _StatChip(label: 'Último minuto', value: '$breakingItems', icon: Icons.bolt_rounded, accentColor: scheme.tertiary),
              _StatChip(label: 'Relevantes', value: '$relevantItems', icon: Icons.view_list_rounded, accentColor: scheme.secondary),
              _StatChip(label: 'Institucionales', value: '$institutionalItems', icon: Icons.apartment_rounded, accentColor: scheme.primary),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LUAI News Desk',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                headline,
                const SizedBox(height: 10),
                description,
                const SizedBox(height: 16),
                stats,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUAI News Desk',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    headline,
                    const SizedBox(height: 10),
                    description,
                  ],
                ),
              ),
              const SizedBox(width: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: stats,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Color accentColor;

  const _SectionPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _BreakingNewsCard extends StatelessWidget {
  final News news;
  final Future<void> Function(News news) onOpenArticle;

  const _BreakingNewsCard({required this.news, required this.onOpenArticle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tag = _InstitutionalTag.pickFor(news);
    final hasImage = (news.imageUrl ?? '').isNotEmpty;
    final sourceLabel = _shortSourceLabel(news.source);

    return SizedBox(
      width: 290,
      child: _NewsInteractiveCardShell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => onOpenArticle(news),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.surface,
                scheme.surfaceContainerHighest.withValues(alpha: 0.36),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 104,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      Image.network(
                        news.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _NewsFallbackImage(label: sourceLabel, icon: Icons.campaign_rounded);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _NewsFallbackImage(label: sourceLabel, icon: Icons.campaign_rounded);
                        },
                      )
                    else
                      _NewsFallbackImage(label: sourceLabel, icon: Icons.campaign_rounded),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.62),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 14,
                      child: _SourcePill(text: sourceLabel, color: tag.color),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'NotoSerif',
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(icon: Icons.public_rounded, text: sourceLabel),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _InfoChip(icon: Icons.calendar_month_rounded, text: _formatShortDate(news.publishedAt)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoChip(
                        icon: Icons.schedule_rounded,
                        text: _formatRelativeTime(news.publishedAt),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => onOpenArticle(news),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('Leer más'),
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelevantNewsTile extends StatelessWidget {
  final News news;
  final Future<void> Function(News news) onOpenArticle;

  const _RelevantNewsTile({required this.news, required this.onOpenArticle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tag = _InstitutionalTag.pickFor(news);
    final sourceLabel = _shortSourceLabel(news.source);

    return _NewsInteractiveCardShell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => onOpenArticle(news),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsThumbnail(
              imageUrl: news.imageUrl,
              fallbackLabel: sourceLabel,
              width: 92,
              height: 92,
              radius: 18,
              icon: Icons.article_rounded,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          news.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'NotoSerif',
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SourcePill(text: tag.label, color: tag.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(icon: Icons.public_rounded, text: news.source),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoChip(icon: Icons.calendar_month_rounded, text: _formatShortDate(news.publishedAt)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.schedule_rounded, text: _formatRelativeTime(news.publishedAt)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onOpenArticle(news),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Leer más'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _InstitutionalNewsTile extends StatelessWidget {
  final News news;
  final Future<void> Function(News news) onOpenArticle;

  const _InstitutionalNewsTile({required this.news, required this.onOpenArticle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tag = _InstitutionalTag.pickFor(news);
    final sourceLabel = _shortSourceLabel(news.source);

    return _NewsInteractiveCardShell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => onOpenArticle(news),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tag.color.withValues(alpha: 0.10),
              scheme.surfaceContainerLowest,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: tag.color.withValues(alpha: 0.24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsThumbnail(
              imageUrl: news.imageUrl,
              fallbackLabel: sourceLabel,
              width: 84,
              height: 84,
              radius: 18,
              icon: tag.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SourcePill(text: tag.label, color: tag.color),
                      _InstitutionalMark(label: 'Institucional', color: tag.color),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'NotoSerif',
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(icon: Icons.public_rounded, text: sourceLabel),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoChip(icon: Icons.calendar_month_rounded, text: _formatShortDate(news.publishedAt)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoChip(icon: Icons.schedule_rounded, text: _formatRelativeTime(news.publishedAt)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onOpenArticle(news),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Leer más'),
                      style: TextButton.styleFrom(
                        foregroundColor: tag.color,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsThumbnail extends StatelessWidget {
  final String? imageUrl;
  final String fallbackLabel;
  final double width;
  final double height;
  final double radius;
  final IconData icon;

  const _NewsThumbnail({
    required this.imageUrl,
    required this.fallbackLabel,
    required this.width,
    required this.height,
    required this.radius,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = (imageUrl ?? '').isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _NewsFallbackImage(label: fallbackLabel, icon: icon);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _NewsFallbackImage(label: fallbackLabel, icon: icon);
                },
              )
            else
              _NewsFallbackImage(label: fallbackLabel, icon: icon),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    scheme.primary.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsFallbackImage extends StatelessWidget {
  final String label;
  final IconData icon;

  const _NewsFallbackImage({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -10,
            child: Icon(
              icon,
              size: 88,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            right: 12,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  final String text;
  final Color color;

  const _SourcePill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InstitutionalMark extends StatelessWidget {
  final String label;
  final Color color;

  const _InstitutionalMark({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PanelEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: scheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsLoadingState extends StatelessWidget {
  const _NewsLoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: scheme.primary,
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Cargando noticias para LUAI...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _NewsInteractiveCardShell extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _NewsInteractiveCardShell({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_NewsInteractiveCardShell> createState() => _NewsInteractiveCardShellState();
}

class _NewsInteractiveCardShellState extends State<_NewsInteractiveCardShell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.008 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: _hovered ? 5 : 0,
            shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: widget.borderRadius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _NewsErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  'No pudimos cargar las noticias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsEmptyState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _NewsEmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article_outlined, size: 64, color: scheme.primary),
                const SizedBox(height: 16),
                Text(
                  'No hay noticias disponibles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'En este momento no hay publicaciones que coincidan con formalización empresarial o emprendimiento.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstitutionalTag {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> keywords;

  const _InstitutionalTag({
    required this.label,
    required this.icon,
    required this.color,
    required this.keywords,
  });

  bool matches(String text) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  static _InstitutionalTag pickFor(News news) {
    final text = _normalizeStatic(
      [news.title, news.summary, news.source, news.category].whereType<String>().join(' '),
    );

    for (final tag in all) {
      if (tag.matches(text)) {
        return tag;
      }
    }

    return defaultTag;
  }

  static const _InstitutionalTag defaultTag = _InstitutionalTag(
    label: 'Institucional',
    icon: Icons.account_balance_rounded,
    color: Color(0xff2E7D32),
    keywords: <String>[],
  );

  static const List<_InstitutionalTag> all = <_InstitutionalTag>[
    _InstitutionalTag(
      label: 'DIAN',
      icon: Icons.receipt_long_rounded,
      color: Color(0xff0F766E),
      keywords: <String>[
        'dian',
        'direccion de impuestos y aduanas nacionales',
      ],
    ),
    _InstitutionalTag(
      label: 'Cámara de Comercio',
      icon: Icons.apartment_rounded,
      color: Color(0xff0369A1),
      keywords: <String>[
        'camara de comercio',
        'camaras de comercio',
        'ccb',
      ],
    ),
    _InstitutionalTag(
      label: 'Gobierno',
      icon: Icons.account_balance_rounded,
      color: Color(0xffB45309),
      keywords: <String>[
        'gobierno',
        'ministerio',
        'presidencia',
        'alcaldia',
        'gobernacion',
        'contraloria',
        'procuraduria',
        'superintendencia',
        'fiscalia',
        'congreso',
        'senado',
        'dnp',
        'mincit',
        'mintrabajo',
      ],
    ),
  ];
}

String _normalizeStatic(String value) {
  const replacements = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };

  var normalized = value.toLowerCase();
  replacements.forEach((from, to) {
    normalized = normalized.replaceAll(from, to);
  });
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}

String _shortSourceLabel(String source) {
  final normalized = source.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.isEmpty) {
    return 'Fuente';
  }

  const maxLength = 24;
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return '${normalized.substring(0, maxLength - 1).trim()}…';
}

String _formatShortDate(DateTime? date) {
  if (date == null) {
    return 'Fecha no disponible';
  }

  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatRelativeTime(DateTime? date) {
  if (date == null) {
    return 'Tiempo no disponible';
  }

  final difference = DateTime.now().difference(date.toLocal());
  if (difference.isNegative) {
    return 'Hace unos minutos';
  }

  if (difference.inMinutes < 1) {
    return 'Hace unos segundos';
  }

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return minutes == 1 ? 'Hace 1 min' : 'Hace $minutes min';
  }

  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return hours == 1 ? 'Hace 1 hora' : 'Hace $hours horas';
  }

  if (difference.inDays < 7) {
    final days = difference.inDays;
    return days == 1 ? 'Hace 1 día' : 'Hace $days días';
  }

  return _formatShortDate(date);
}