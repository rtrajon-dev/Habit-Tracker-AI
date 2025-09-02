import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:habit/services/quote_service.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen>
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  late TabController _tabController;

  List<Map<String, String>> quotes = [
    {"q": "Believe you can and you're halfway there.", "a": "Theodore Roosevelt"},
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchQuotes();
  }

  Future<void> fetchQuotes() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          "https://api.allorigins.win/raw?url=https://zenquotes.io/api/quotes"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          quotes.addAll(data.take(10).map((q) {
            return {
              "q": (q["q"] ?? "No quote").toString(),
              "a": (q["a"] ?? "Unknown").toString(),
            };
          }).toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch quotes")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching quotes: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildQuoteCard(Map<String, String> quote) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quote["q"] ?? "",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "- ${quote["a"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: "${quote["q"]} - ${quote["a"]}"));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Copied to clipboard!")),
                    );
                  },
                ),
                StreamBuilder<bool>(
                  stream: Stream.fromFuture(
                      _quoteService.isFavorite(quote["q"]!)),
                  builder: (context, snapshot) {
                    final isFav = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.grey,
                      ),
                      onPressed: () async {
                        if (isFav) {
                          await _quoteService.removeFavorite(quote["q"]!);
                        } else {
                          await _quoteService.addFavorite(quote);
                        }
                        setState(() {}); // refresh UI
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAllQuotesTab() {
    if (isLoading && quotes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: fetchQuotes,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: quotes.length,
        itemBuilder: (context, index) => _buildQuoteCard(quotes[index]),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _quoteService.getFavoritesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final favorites = snapshot.data!;
        if (favorites.isEmpty) {
          return const Center(child: Text("No favorite quotes yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final q = favorites[index];
            return _buildQuoteCard({
              "q": q["q"] ?? "",
              "a": q["a"] ?? "Unknown",
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivational Quotes"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.secondary,
          tabs: const [
            Tab(text: "All Quotes"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllQuotesTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }
}
