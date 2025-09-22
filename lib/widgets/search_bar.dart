import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final VoidCallback? onClear;

  const SearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Ürün ara',
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
                color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: Theme.of(context).inputDecorationTheme.border,
        focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (value) {
        setState(() {}); // Rebuild to show/hide clear button
        widget.onChanged(value);
      },
    );
  }
}