import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../providers/user_provider.dart';
import '../widgets/quote_card.dart';
import '../services/image_overlay_service.dart';
import '../services/share_service.dart';
import 'edit_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final _imageService = ImageOverlayService();
  final _shareService = ShareService();
  
  int _currentIndex = 0;
  bool _isProcessing = false;
  String _selectedCategory = 'All';

  // Categories
  final List<Map<String, String>> _categories = [
    {'id': 'All', 'label': 'All', 'hindi': 'सभी'},
    {'id': 'Good Morning', 'label': 'Good Morning', 'hindi': 'शुभ प्रभात'},
    {'id': 'Motivational', 'label': 'Motivational', 'hindi': 'प्रेरणादायक'},
    {'id': 'Shayari', 'label': 'Shayari', 'hindi': 'शायरी'},
    {'id': 'Religious', 'label': 'Religious', 'hindi': 'धार्मिक'},
    {'id': 'Love', 'label': 'Love', 'hindi': 'प्रेम'},
    {'id': 'Festival', 'label': 'Festival', 'hindi': 'त्योहार'},
  ];

  // Mock quote data with images
  final List<Map<String, dynamic>> _allQuotes = [
    {
      'text': '',
      'image': 'assets/quotes/template_1.jpg',
      'category': 'Motivational',
    },
    {
      'text': '',
      'image': 'assets/quotes/template_2.jpg',
      'category': 'Motivational',
    },
    {
      'text': '',
      'image': 'assets/quotes/template_3.jpg',
      'category': 'Daily Inspiration',
    },
    {
      'text': '',
      'image': 'assets/quotes/template_4.jpg',
      'category': 'Attitude',
    },
    {
      'text': '',
      'image': 'assets/quotes/template_5.jpg',
      'category': 'Motivational',
    },
  ];

  List<Map<String, dynamic>> get _filteredQuotes {
    if (_selectedCategory == 'All') return _allQuotes;
    // For demo purposes, if category doesn't match exactly, show random subset or all to ensure content displays
    // In real app, you would filter: return _allQuotes.where((q) => q['category'] == _selectedCategory).toList();
    
    // Since we only have 5 templates, we'll just rotate them or show specific ones for demo
    return _allQuotes; 
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
                    'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];
    return '${now.day} ${months[now.month - 1]}';
  }

  Future<void> _handleShare() async {
    setState(() => _isProcessing = true);

    try {
      // Capture the quote as image
      final imageFile = await _imageService.createPersonalizedQuote(
        repaintBoundaryKey: _repaintKey,
      );

      // Share the image
      await _shareService.shareQuote(imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isProcessing = true);

    try {
      // Capture the quote as image
      final imageFile = await _imageService.createPersonalizedQuote(
        repaintBoundaryKey: _repaintKey,
      );

      // Save to permanent storage
      await _imageService.saveQuoteToPermanentStorage(imageFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildCategoryPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                '${category['label']} (${category['hindi']})',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  _selectedCategory = category['id']!;
                  _currentIndex = 0;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF6A1B9A),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6A1B9A) : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final quotes = _filteredQuotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suvichar'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Pills
          _buildCategoryPills(),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Carousel with quotes
                Flexible(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 500,
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() => _currentIndex = index);
                      },
                    ),
                    items: quotes.map((quote) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: QuoteCard(
                              quoteText: quote['text'],
                              userName: user.name,
                              userPhotoPath: user.photoPath,
                              date: _getCurrentDate(),
                              showDate: user.showDate,
                              backgroundImage: quote['image'],
                              repaintKey: _currentIndex == quotes.indexOf(quote)
                                  ? _repaintKey
                                  : null,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Carousel indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: quotes.asMap().entries.map((entry) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? const Color(0xFF6A1B9A)
                            : Colors.grey[300],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _handleShare,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF6A1B9A)),
                      foregroundColor: const Color(0xFF6A1B9A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _handleDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF6A1B9A)),
                      foregroundColor: const Color(0xFF6A1B9A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('EDIT'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
