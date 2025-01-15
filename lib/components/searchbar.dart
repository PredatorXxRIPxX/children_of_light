import 'package:flutter/material.dart';

class CustomSearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final Function(String) onSearch;
  final String hintText;
  final Color? backgroundColor;
  final Color? searchBarColor;

  const CustomSearchAppBar({
    Key? key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearch,
    this.hintText = 'Search...',
    this.backgroundColor = Colors.white,
    this.searchBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomSearchBar(
            controller: searchController,
            focusNode: searchFocusNode,
            handleSearch: onSearch,
            hintText: hintText,
            backgroundColor: searchBarColor,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) handleSearch;
  final String hintText;
  final Color? backgroundColor;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.handleSearch,
    this.hintText = 'Rechercher...',
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear, color: Colors.grey[400]),
          onPressed: () => controller.clear(),
        ),
        filled: true,
        fillColor: backgroundColor ?? Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: handleSearch,
    );
  }
}