import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsccsg/model/my_user.dart';
import 'package:gsccsg/screens/homepage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/apis.dart';
import '../model/adhd_image.dart';
import 'chat_screen.dart';

class ResultsPage extends StatefulWidget {
  final MyUser user;
  final String? file;
  final String subject;
  final Future<String>? futureFileSummary;

  const ResultsPage({
    super.key,
    required this.user,
    this.file,
    required this.subject,
    this.futureFileSummary,
  });

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late Future<List<AdhdImage>> _adhdImagesFuture;
  late Future<String> _fileSummaryFuture;
  bool _showAccessibilityPanel = false;

  // Accessibility settings
  String _selectedFont = 'OpenDyslexic';
  double _fontSize = 16.0;
  Color _textColor = Colors.white70;
  Color _backgroundColor = Colors.black;
  Color _panelColor = Colors.grey[900]!;
  double _letterSpacing = 0.0;
  double _wordSpacing = 0.0;
  FontWeight _fontWeight = FontWeight.normal;
  bool _useBoldHeaders = true;

  // Supported fonts
  final List<String> _supportedFonts = [
    'OpenDyslexic',
    'Hyperlegible',
    'Verdana',
    'Lexend',
    'Comic Neu',
    'Times New Roman',
  ];

  @override
  void initState() {
    super.initState();
    _adhdImagesFuture = APIs.getAdhdImage(widget.file ?? "", widget.subject);
    _fileSummaryFuture =
        widget.futureFileSummary ?? Future.value(widget.file ?? "No content available");
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedFont = prefs.getString('dyslexia_font') ?? 'OpenDyslexic';
      _fontSize = prefs.getDouble('dyslexia_font_size') ?? 16.0;
      _textColor = Color(prefs.getInt('dyslexia_text_color') ?? Colors.white70.value);
      _backgroundColor = Color(prefs.getInt('dyslexia_bg_color') ?? Colors.black.value);
      _panelColor = Color(prefs.getInt('dyslexia_panel_color') ?? Colors.grey[900]!.value);
      _letterSpacing = prefs.getDouble('letter_spacing') ?? 0.0;
      _wordSpacing = prefs.getDouble('word_spacing') ?? 0.0;
      _fontWeight = FontWeight.values[prefs.getInt('font_weight') ?? FontWeight.normal.index];
      _useBoldHeaders = prefs.getBool('use_bold_headers') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dyslexia_font', _selectedFont);
    await prefs.setDouble('dyslexia_font_size', _fontSize);
    await prefs.setInt('dyslexia_text_color', _textColor.value);
    await prefs.setInt('dyslexia_bg_color', _backgroundColor.value);
    await prefs.setInt('dyslexia_panel_color', _panelColor.value);
    await prefs.setDouble('letter_spacing', _letterSpacing);
    await prefs.setDouble('word_spacing', _wordSpacing);
    await prefs.setInt('font_weight', _fontWeight.index);
    await prefs.setBool('use_bold_headers', _useBoldHeaders);
  }

  void _showColorPicker(
      BuildContext context, Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color', style: _getHeaderTextStyle()),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              availableColors: const [
                Colors.white,
                Colors.white70,
                Colors.black,
                Colors.blue,
                Colors.red,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
                Colors.teal,
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('OK', style: _getContentTextStyle()),
              onPressed: () {
                Navigator.of(context).pop();
                _saveSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccessibilityPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showAccessibilityPanel ? 420 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Reading Preferences',
              style: _getHeaderTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(color: Colors.white54),
            _buildFontSelector(),
            const SizedBox(height: 15),
            _buildFontSizeSlider(),
            const SizedBox(height: 15),
            _buildSpacingControls(),
            const SizedBox(height: 15),
            _buildColorControls(),
            const SizedBox(height: 15),
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Font:', style: _getContentTextStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _supportedFonts.map((font) {
            return ChoiceChip(
              label: Text(font, style: _getFontPreviewStyle(font)),
              selected: _selectedFont == font,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFont = font);
                  _saveSettings();
                }
              },
              selectedColor: Colors.deepPurpleAccent,
              backgroundColor: Colors.grey[800],
              labelStyle: _getContentTextStyle().copyWith(
                color: _selectedFont == font ? Colors.black : _textColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Font Size: ${_fontSize.toStringAsFixed(1)}',
            style: _getContentTextStyle()),
        Slider(
          value: _fontSize,
          min: 12,
          max: 28,
          divisions: 16,
          activeColor: Colors.deepPurpleAccent,
          inactiveColor: Colors.grey[700],
          onChanged: (value) {
            setState(() => _fontSize = value);
            _saveSettings();
          },
        ),
      ],
    );
  }

  Widget _buildSpacingControls() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Letter Spacing', style: _getContentTextStyle()),
              Slider(
                value: _letterSpacing,
                min: 0,
                max: 2,
                divisions: 20,
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.grey[700],
                onChanged: (value) {
                  setState(() => _letterSpacing = value);
                  _saveSettings();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Word Spacing', style: _getContentTextStyle()),
              Slider(
                value: _wordSpacing,
                min: 0,
                max: 10,
                divisions: 20,
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.grey[700],
                onChanged: (value) {
                  setState(() => _wordSpacing = value);
                  _saveSettings();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colors:', style: _getContentTextStyle()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorOption('Text', _textColor, (color) {
              setState(() => _textColor = color);
              _saveSettings();
            }),
            _buildColorOption('Background', _backgroundColor, (color) {
              setState(() => _backgroundColor = color);
              _saveSettings();
            }),
            _buildColorOption('Panel', _panelColor, (color) {
              setState(() => _panelColor = color);
              _saveSettings();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.restore),
      label: Text('Reset to Defaults', style: _getContentTextStyle()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: _textColor,
      ),
      onPressed: _resetSettings,
    );
  }

  Widget _buildColorOption(
      String label, Color color, Function(Color) onChanged) {
    return InkWell(
      onTap: () => _showColorPicker(context, color, (newColor) {
        onChanged(newColor);
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: _getContentTextStyle()),
          ],
        ),
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _selectedFont = 'OpenDyslexic';
      _fontSize = 16.0;
      _textColor = Colors.white70;
      _backgroundColor = Colors.black;
      _panelColor = Colors.grey[900]!;
      _letterSpacing = 0.0;
      _wordSpacing = 0.0;
      _fontWeight = FontWeight.normal;
      _useBoldHeaders = true;
    });
    _saveSettings();
  }

  TextStyle _getFontPreviewStyle(String font) {
    return TextStyle(
      fontFamily: _getFontFamily(font),
      color: _textColor,
      fontSize: 14,
      letterSpacing: _letterSpacing,
      wordSpacing: _wordSpacing,
    );
  }

  String? _getFontFamily(String font) {
    if (font == 'OpenDyslexic') return 'OpenDyslexic';
    if (font == 'Lexend') return 'Lexend';
    if (font == 'Hyperlegible') return 'Hyperlegible';
    if (font == 'Verdana') return 'Verdana';
    if (font == 'Comic Neu') return 'Comic Neu';
    if (font == 'Times New Roman') return 'Times New Roman';

    return font;
  }

  TextStyle _getContentTextStyle() {
    final baseStyle = TextStyle(
      fontSize: _fontSize,
      color: _textColor,
      height: 1.5,
      letterSpacing: _letterSpacing,
      wordSpacing: _wordSpacing,
      fontWeight: _fontWeight,
    );

    if (_selectedFont == 'OpenDyslexic') {
      return baseStyle.copyWith(fontFamily: 'OpenDyslexic');
    }
    if (_selectedFont == 'Lexend') {
      return GoogleFonts.lexend(textStyle: baseStyle);
    }
    if (_selectedFont == 'Hyperlegible') {
      return GoogleFonts.atkinsonHyperlegible(textStyle: baseStyle);
    }
    if (_selectedFont == 'Verdana') {
      return baseStyle.copyWith(fontFamily: 'Verdana');
    }
    if (_selectedFont == 'Comic Neu') {
      return GoogleFonts.comicNeue(textStyle: baseStyle);
    }
    if (_selectedFont == 'Times New Roman') {
      return GoogleFonts.luxuriousRoman(textStyle: baseStyle);
    }
    return baseStyle.copyWith(fontFamily: _selectedFont);
  }

  TextStyle _getHeaderTextStyle() {
    return _getContentTextStyle().copyWith(
      fontSize: _fontSize + 4,
      fontWeight: _useBoldHeaders ? FontWeight.bold : _fontWeight,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDyslexia = widget.user.disorder.contains('Dyslexia');
    final hasADHD = widget.user.disorder.contains('ADHD');
    final hasDyscalculia = widget.user.disorder.contains('Dyscalculia');

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text("Results", style: _getHeaderTextStyle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: hasDyslexia
            ? [
          IconButton(
            icon: Icon(Icons.accessibility_new, color: _textColor),
            onPressed: () => setState(() => _showAccessibilityPanel = !_showAccessibilityPanel),
          )
        ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _fileSummaryFuture,
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: _textColor),
                        const SizedBox(height: 20),
                        Text("Generating your lesson...",
                            style: _getContentTextStyle()),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: _getContentTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // In your ResultsPage build method
                final fileContent = snapshot.data ?? "No content available";

                if (hasADHD) {
                  return FutureBuilder<List<AdhdImage>>(
                    future: APIs.getAdhdImage(fileContent, widget.subject),
                    builder: (context, snapshot) {
                      // Handle loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: _textColor),
                              const SizedBox(height: 20),
                              Text("Creating visual representations...",
                                  style: _getContentTextStyle()),
                            ],
                          ),
                        );
                      }

                      // Handle error state
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 40),
                              const SizedBox(height: 16),
                              Text("Couldn't generate visuals",
                                  style: _getHeaderTextStyle()),
                              Text(snapshot.error.toString(),
                                  style: _getContentTextStyle()),
                            ],
                          ),
                        );
                      }

                      // Handle empty data
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text("No visual content available",
                              style: _getHeaderTextStyle()),
                        );
                      }

                      // Display the carousel
                      final images = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(
                            height: 350,
                            child: PageView.builder(
                              itemCount: images.length,
                              controller: PageController(viewportFraction: 0.9),
                              itemBuilder: (context, index) {
                                final image = images[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(
                                            image.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: progress.expectedTotalBytes != null
                                                      ? progress.cumulativeBytesLoaded /
                                                      progress.expectedTotalBytes!
                                                      : null,
                                                  color: _textColor,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                                Center(
                                                  child: Icon(Icons.broken_image,
                                                      color: _textColor, size: 40),
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        child: Text(
                                          image.caption,
                                          style: _getContentTextStyle().copyWith(
                                            fontSize: _fontSize * 0.9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(images.length, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _textColor.withOpacity(
                                      index == 0 ? 0.9 : 0.4), // Update this with actual page index
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          Text("Visual Learning Aids",
                              style: _getHeaderTextStyle()),

                          const SizedBox(height:70),

                          SafeArea(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomePage())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text("Back to Home",
                                  style: _getContentTextStyle().copyWith(color: Colors.black)),
                            ),
                          ),
                        ],

                      );
                    },
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.deepPurpleAccent.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Your Generated Lesson", style: _getHeaderTextStyle()),
                              const SizedBox(height: 15),
                              Text(fileContent, style: _getContentTextStyle()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        hasDyscalculia ?
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(initialLesson: fileContent, user: widget.user),
                            ),
                          ),
                          child: const Text('Ask Questions'),
                        ) : const SizedBox.shrink(),

                        const SizedBox(height: 30),
                        SafeArea(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomePage())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text("Back to Home",
                                style: _getContentTextStyle().copyWith(color: Colors.black)),
                          ),
                        ),
                        if (hasDyslexia)
                          SafeArea(
                            child: SizedBox(
                                height: 500,
                                child: _buildAccessibilityPanel()),
                          ),
                        const SizedBox(height: 60,)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (hasDyslexia) _buildAccessibilityPanel(),
        ],
      ),
    );
  }
}