import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';
import '../../core/localization/app_localizations.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/empty_states.dart';
import '../product/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<ProductModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _sortBy = 'popular'; // popular, price_low, price_high, newest

  /// Clear tugmasini ko'rsatish uchun - keraksiz rebuild oldini olish
  bool _showClearButton = false;

  // Qidiruv tarixi
  List<String> _searchHistory = [];
  static const String _historyKey = 'search_history';

  // Mashhur qidiruvlar
  final List<String> _popularSearches = [
    'Telefon',
    'Noutbuk',
    'Quloqchin',
    'Smart soat',
    'Televizor',
    'Kamera',
    'Planshet',
    'Aksessuar',
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _showClearButton = true;
      _performSearch(widget.initialQuery!);
    } else {
      // Avtomatik fokus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey);
    if (history != null && mounted) {
      setState(() {
        _searchHistory = history;
      });
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final productsProvider = context.read<ProductsProvider>();
      final results = await productsProvider.searchProducts(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

      // Tarixga qo'shish
      if (!_searchHistory.contains(query)) {
        setState(() {
          _searchHistory.insert(0, query);
          if (_searchHistory.length > 10) {
            _searchHistory.removeLast();
          }
        });
        _saveSearchHistory();
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Qidiruvda xatolik: $e')),
        );
      }
    }
  }

  void _addToCart(ProductModel product) async {
    if (!context.read<AuthProvider>().isLoggedIn) {
      Navigator.pushNamed(context, '/auth');
      return;
    }
    try {
      await context.read<CartProvider>().addToCart(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.locale.languageCode == 'ru'
                  ? 'Товар добавлен в корзину'
                  : 'Mahsulot savatga qo\'shildi',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.locale.languageCode == 'ru'
                  ? 'Ошибка при добавлении'
                  : 'Qo\'shishda xatolik',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleFavorite(ProductModel product) async {
    if (!context.read<AuthProvider>().isLoggedIn) {
      Navigator.pushNamed(context, '/auth');
      return;
    }
    try {
      await context.read<ProductsProvider>().toggleFavorite(product.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.locale.languageCode == 'ru' ? 'Ошибка' : 'Xatolik',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortResults() {
    setState(() {
      switch (_sortBy) {
        case 'price_low':
          _searchResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _searchResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
          _searchResults.sort((a, b) {
            final aDate = a.createdAt ?? DateTime(2000);
            final bDate = b.createdAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          break;
        default: // popular
          _searchResults.sort((a, b) => b.soldCount.compareTo(a.soldCount));
      }
    });
  }

  void _clearHistory() {
    setState(() {
      _searchHistory.clear();
    });
    _saveSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchField(),
        actions: [
          if (_hasSearched && _searchResults.isNotEmpty)
            IconButton(
              onPressed: _showSortOptions,
              icon: const Icon(Iconsax.sort),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.translate('search_products'),
          prefixIcon: const Icon(Icons.search, size: 22),
          suffixIcon: _showClearButton
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _showClearButton = false;
                      _hasSearched = false;
                      _searchResults.clear();
                    });
                  },
                  icon: const Icon(Icons.close, size: 20),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          // Faqat clear tugmasi holatini yangilash kerak bo'lganda setState chaqirish
          final shouldShowClear = value.isNotEmpty;
          if (_showClearButton != shouldShowClear) {
            setState(() {
              _showClearButton = shouldShowClear;
            });
          }
        },
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      // Shimmer skeleton loading
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.52,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      );
    }

    if (_hasSearched) {
      return _buildSearchResults();
    }

    return _buildSuggestions();
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Qidiruv tarixi
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Qidiruv tarixi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('Tozalash'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory.map((query) {
              return ActionChip(
                avatar:
                    Icon(Iconsax.clock, size: 16, color: Colors.grey.shade700),
                label: Text(
                  query,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.grey.shade200,
                side: BorderSide(color: Colors.grey.shade300),
                onPressed: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Mashhur qidiruvlar
        const Text(
          'Mashhur qidiruvlar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSearches.map((query) {
            return ActionChip(
              avatar:
                  Icon(Iconsax.trend_up, size: 16, color: AppColors.primary),
              label: Text(
                query,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              onPressed: () {
                _searchController.text = query;
                _performSearch(query);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return EmptySearchWidget(
        query: _searchController.text,
        onClear: () {
          _searchController.clear();
          setState(() {
            _hasSearched = false;
            _searchResults.clear();
          });
          _searchFocusNode.requestFocus();
        },
      );
    }

    return Column(
      children: [
        // Natijalar soni
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_searchResults.length} ${context.l10n.translate('results_count')}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _getSortLabel(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Mahsulotlar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.52,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ProductCard(
                name: product.nameUz,
                price: product.price.toInt(),
                oldPrice: product.oldPrice?.toInt(),
                discount: product.discountPercent,
                rating: product.rating,
                sold: product.soldCount,
                imageUrl: product.firstImage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: {
                          'id': product.id,
                          'name': product.nameUz,
                          'price': product.price,
                          'oldPrice': product.oldPrice,
                          'discount': product.discountPercent,
                          'rating': product.rating,
                          'sold': product.soldCount,
                          'image': product.firstImage,
                          'cashback': product.cashbackPercent,
                          'description': product.descriptionUz,
                        },
                      ),
                    ),
                  );
                },
                onAddToCart: () => _addToCart(product),
                onFavoriteToggle: () => _toggleFavorite(product),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'Arzon → Qimmat';
      case 'price_high':
        return 'Qimmat → Arzon';
      case 'newest':
        return 'Eng yangi';
      default:
        return 'Mashhur';
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Saralash',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSortOption('popular', 'Mashhur', Iconsax.star),
              _buildSortOption(
                  'price_low', 'Narx: Arzon → Qimmat', Iconsax.arrow_up_3),
              _buildSortOption(
                  'price_high', 'Narx: Qimmat → Arzon', Iconsax.arrow_down),
              _buildSortOption('newest', 'Eng yangi', Iconsax.calendar),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _sortResults();
        Navigator.pop(context);
      },
    );
  }
}
