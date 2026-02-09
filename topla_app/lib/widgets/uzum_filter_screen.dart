import 'package:flutter/material.dart';
import '../models/filter_model.dart';
import '../models/brand_model.dart';
import '../models/color_option.dart';
import '../models/category_filter_attribute.dart';

/// Uzum uslubidagi professional filter ekrani
/// Full-screen bottom sheet bilan
class UzumFilterScreen extends StatefulWidget {
  final ProductFilter currentFilter;
  final List<BrandModel> brands;
  final List<ColorOption> colors;
  final List<CategoryFilterAttribute> categoryFilters;
  final String categoryName;
  final Color accentColor;
  final int? productCount;
  final Function(ProductFilter)? onFilterChanged;

  const UzumFilterScreen({
    super.key,
    required this.currentFilter,
    this.brands = const [],
    this.colors = const [],
    this.categoryFilters = const [],
    this.categoryName = 'Filtrlar',
    this.accentColor = const Color(0xFFFFD54F),
    this.productCount,
    this.onFilterChanged,
  });

  /// Filter ekranini ochish uchun static method
  static Future<ProductFilter?> show(
    BuildContext context, {
    required ProductFilter currentFilter,
    List<BrandModel> brands = const [],
    List<ColorOption> colors = const [],
    List<CategoryFilterAttribute> categoryFilters = const [],
    String categoryName = 'Filtrlar',
    Color accentColor = const Color(0xFFFFD54F),
    int? productCount,
    Function(ProductFilter)? onFilterChanged,
  }) {
    return showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UzumFilterScreen(
        currentFilter: currentFilter,
        brands: brands,
        colors: colors,
        categoryFilters: categoryFilters,
        categoryName: categoryName,
        accentColor: accentColor,
        productCount: productCount,
        onFilterChanged: onFilterChanged,
      ),
    );
  }

  @override
  State<UzumFilterScreen> createState() => _UzumFilterScreenState();
}

class _UzumFilterScreenState extends State<UzumFilterScreen> {
  late ProductFilter _filter;
  
  // Price controllers
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _minPriceController.text = _filter.minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceController.text = _filter.maxPrice?.toStringAsFixed(0) ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _updateFilter(ProductFilter newFilter) {
    setState(() => _filter = newFilter);
    widget.onFilterChanged?.call(newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Narx
                  _buildPriceSection(),
                  _buildDivider(),
                  
                  // Yetkazish muddati
                  _buildDeliverySection(),
                  _buildDivider(),
                  
                  // Toggle options
                  _buildToggleSection(),
                  _buildDivider(),
                  
                  // Brendlar
                  if (widget.brands.isNotEmpty) ...[
                    _buildBrandsSection(),
                    _buildDivider(),
                  ],
                  
                  // Ranglar
                  if (widget.colors.isNotEmpty) ...[
                    _buildColorsSection(),
                    _buildDivider(),
                  ],
                  
                  // Kategoriyaga xos filterlar
                  ...widget.categoryFilters.map((attr) {
                    return Column(
                      children: [
                        _buildCategoryAttributeSection(attr),
                        _buildDivider(),
                      ],
                    );
                  }),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Bottom button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Clear all button
              if (_filter.hasActiveFilters)
                TextButton(
                  onPressed: () {
                    _updateFilter(ProductFilter.empty());
                    _minPriceController.clear();
                    _maxPriceController.clear();
                  },
                  child: Text(
                    'Tozalash',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 32,
      thickness: 1,
      color: Colors.grey.shade200,
    );
  }

  // === NARX SECTION ===
  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Narxi, so\'m',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceInput(
                controller: _minPriceController,
                label: 'd.',
                hint: 'dan',
                onChanged: (value) {
                  final price = double.tryParse(value);
                  _updateFilter(_filter.copyWith(
                    minPrice: price,
                    clearMinPrice: value.isEmpty,
                  ));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceInput(
                controller: _maxPriceController,
                label: 'g.',
                hint: 'gacha',
                onChanged: (value) {
                  final price = double.tryParse(value);
                  _updateFilter(_filter.copyWith(
                    maxPrice: price,
                    clearMaxPrice: value.isEmpty,
                  ));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // === YETKAZISH MUDDATI SECTION ===
  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yetkazish muddati',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDeliveryChip(
              label: 'Bugun yoki ertaga',
              value: 24,
            ),
            _buildDeliveryChip(
              label: '7 kungacha',
              value: 168,
            ),
            _buildDeliveryChip(
              label: 'Muhim emas',
              value: null,
              isDefault: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryChip({
    required String label,
    required int? value,
    bool isDefault = false,
  }) {
    final isSelected = _filter.deliveryHours == value;
    
    return GestureDetector(
      onTap: () {
        _updateFilter(_filter.copyWith(
          deliveryHours: value,
          clearDeliveryHours: value == null,
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: widget.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === TOGGLE OPTIONS SECTION ===
  Widget _buildToggleSection() {
    return Column(
      children: [
        _buildToggleItem(
          title: 'Klik bilan yetkazish',
          value: _filter.isClickDelivery ?? false,
          onChanged: (value) {
            _updateFilter(_filter.copyWith(
              isClickDelivery: value,
              clearIsClickDelivery: !value,
            ));
          },
        ),
        _buildToggleItem(
          title: 'WOW-narx',
          subtitle: 'Eng yaxshi narxlar',
          value: _filter.onlyWithDiscount,
          onChanged: (value) {
            _updateFilter(_filter.copyWith(onlyWithDiscount: value));
          },
        ),
        _buildToggleItem(
          title: 'Original',
          subtitle: 'Sifat kafolati',
          value: _filter.isOriginal ?? false,
          hasInfo: true,
          onChanged: (value) {
            _updateFilter(_filter.copyWith(
              isOriginal: value,
              clearIsOriginal: !value,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    bool hasInfo = false,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasInfo)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: widget.accentColor,
            activeTrackColor: widget.accentColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  // === BRENDLAR SECTION ===
  Widget _buildBrandsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Brend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.brands.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Show all brands
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Barchasi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.brands.take(10).map((brand) {
            final isSelected = _filter.brandIds.contains(brand.id);
            return _buildChip(
              label: brand.nameUz,
              isSelected: isSelected,
              onTap: () {
                final newBrands = Set<String>.from(_filter.brandIds);
                if (isSelected) {
                  newBrands.remove(brand.id);
                } else {
                  newBrands.add(brand.id);
                }
                _updateFilter(_filter.copyWith(brandIds: newBrands));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // === RANGLAR SECTION ===
  Widget _buildColorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.colors.length > 6)
              TextButton(
                onPressed: () {
                  // TODO: Show all colors
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Barchasi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.colors.take(10).map((color) {
            final isSelected = _filter.colorIds.contains(color.id);
            return _buildColorCircle(
              color: color,
              isSelected: isSelected,
              onTap: () {
                final newColors = Set<String>.from(_filter.colorIds);
                if (isSelected) {
                  newColors.remove(color.id);
                } else {
                  newColors.add(color.id);
                }
                _updateFilter(_filter.copyWith(colorIds: newColors));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle({
    required ColorOption color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorValue = Color(int.parse(color.hexCode.replaceFirst('#', '0xFF')));
    final isLight = colorValue.computeLuminance() > 0.7;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorValue,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? widget.accentColor 
                    : (isLight ? Colors.grey.shade300 : Colors.transparent),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: isLight ? Colors.black : Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            color.nameUz,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // === KATEGORIYA ATRIBUT SECTION ===
  Widget _buildCategoryAttributeSection(CategoryFilterAttribute attr) {
    switch (attr.filterType) {
      case FilterType.chips:
        return _buildChipsFilter(attr);
      case FilterType.range:
        return _buildRangeFilter(attr);
      case FilterType.toggle:
        return _buildToggleFilter(attr);
      case FilterType.color:
        return _buildColorFilter(attr);
      case FilterType.radio:
        return _buildRadioFilter(attr);
    }
  }

  Widget _buildChipsFilter(CategoryFilterAttribute attr) {
    final currentValue = _filter.attributes[attr.attributeKey];
    final selectedValues = currentValue?.selectedValues ?? <String>{};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  attr.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (attr.unit != null)
                  Text(
                    ', ${attr.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
            if (attr.options.length > 5)
              TextButton(
                onPressed: () {
                  // TODO: Show all options
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Barchasi',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: attr.options.take(10).map((option) {
            final isSelected = selectedValues.contains(option.value);
            return _buildChip(
              label: option.label,
              isSelected: isSelected,
              onTap: () {
                final newSelected = Set<String>.from(selectedValues);
                if (isSelected) {
                  newSelected.remove(option.value);
                } else {
                  newSelected.add(option.value);
                }
                final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
                newAttrs[attr.attributeKey] = SelectedFilterValue(
                  attributeKey: attr.attributeKey,
                  filterType: attr.filterType,
                  selectedValues: newSelected,
                );
                _updateFilter(_filter.copyWith(attributes: newAttrs));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRangeFilter(CategoryFilterAttribute attr) {
    final currentValue = _filter.attributes[attr.attributeKey];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              attr.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (attr.unit != null)
              Text(
                ', ${attr.unit}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            if (attr.hasHelp)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.help_outline,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRangeInput(
                label: 'd.',
                value: currentValue?.minValue?.toString() ?? '',
                onChanged: (value) {
                  final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
                  final existing = newAttrs[attr.attributeKey];
                  newAttrs[attr.attributeKey] = SelectedFilterValue(
                    attributeKey: attr.attributeKey,
                    filterType: FilterType.range,
                    minValue: double.tryParse(value),
                    maxValue: existing?.maxValue,
                  );
                  _updateFilter(_filter.copyWith(attributes: newAttrs));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRangeInput(
                label: 'g.',
                value: currentValue?.maxValue?.toString() ?? '',
                onChanged: (value) {
                  final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
                  final existing = newAttrs[attr.attributeKey];
                  newAttrs[attr.attributeKey] = SelectedFilterValue(
                    attributeKey: attr.attributeKey,
                    filterType: FilterType.range,
                    minValue: existing?.minValue,
                    maxValue: double.tryParse(value),
                  );
                  _updateFilter(_filter.copyWith(attributes: newAttrs));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeInput({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          TextField(
            controller: TextEditingController(text: value),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleFilter(CategoryFilterAttribute attr) {
    final currentValue = _filter.attributes[attr.attributeKey];
    final isEnabled = currentValue?.toggleValue ?? false;
    
    return _buildToggleItem(
      title: attr.name,
      value: isEnabled,
      hasInfo: attr.hasHelp,
      onChanged: (value) {
        final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
        newAttrs[attr.attributeKey] = SelectedFilterValue(
          attributeKey: attr.attributeKey,
          filterType: FilterType.toggle,
          toggleValue: value,
        );
        _updateFilter(_filter.copyWith(attributes: newAttrs));
      },
    );
  }

  Widget _buildColorFilter(CategoryFilterAttribute attr) {
    // Color filter uses the same UI as main color section
    // but with category-specific colors
    return const SizedBox.shrink();
  }

  Widget _buildRadioFilter(CategoryFilterAttribute attr) {
    final currentValue = _filter.attributes[attr.attributeKey];
    final selectedOption = currentValue?.selectedValues.firstOrNull;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              attr.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (attr.hasHelp)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.help_outline,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...attr.options.map((option) {
              final isSelected = selectedOption == option.value;
              return _buildRadioChip(
                label: option.label,
                isSelected: isSelected,
                onTap: () {
                  final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
                  newAttrs[attr.attributeKey] = SelectedFilterValue(
                    attributeKey: attr.attributeKey,
                    filterType: FilterType.radio,
                    selectedValues: {option.value},
                  );
                  _updateFilter(_filter.copyWith(attributes: newAttrs));
                },
              );
            }),
            // "Muhim emas" option
            _buildRadioChip(
              label: 'Muhim emas',
              isSelected: selectedOption == null,
              isDefault: true,
              onTap: () {
                final newAttrs = Map<String, SelectedFilterValue>.from(_filter.attributes);
                newAttrs.remove(attr.attributeKey);
                _updateFilter(_filter.copyWith(attributes: newAttrs));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioChip({
    required String label,
    required bool isSelected,
    bool isDefault = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? widget.accentColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // === BOTTOM BUTTON ===
  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _filter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accentColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.productCount != null
                ? 'Tovarlarni ko\'rsatish (${widget.productCount})'
                : 'Tovarlarni ko\'rsatish',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
