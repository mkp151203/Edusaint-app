import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  String? errorMessage;

  // Static leagues used in UI (unchanged)
  final List<Map<String, dynamic>> leagues = [
    {"name": "Bronze", "color": Colors.brown, "icon": Icons.military_tech},
    {"name": "Silver", "color": Colors.grey, "icon": Icons.military_tech},
    {"name": "Gold", "color": Colors.amber, "icon": Icons.military_tech},
    {
      "name": "Platinum",
      "color": Colors.blueAccent,
      "icon": Icons.military_tech,
    },
    {"name": "Diamond", "color": Colors.cyan, "icon": Icons.military_tech},
  ];

  // API endpoint (single place to change)
  static const String _apiUrl = 'https://byte.edusaint.in/api/v1/leaderboard';

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  /// Public fetch method (safe, sets loading & error state)
  Future<void> fetchLeaderboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse(_apiUrl);
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = _safeJsonDecode(response.body);
        final items = _parseLeaderboardItemsFromResponse(decoded);

        if (items == null) {
          setState(() {
            leaderboardData = [];
            errorMessage = 'Unexpected API response format.';
          });
        } else if (items.isEmpty) {
          setState(() {
            leaderboardData = [];
            errorMessage = 'No leaderboard data found.';
          });
        } else {
          // Normalize & sort (rank preferred, otherwise sort by score desc)
          final normalized = items
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
          normalized.sort(_leaderboardComparator);
          for (int i = 0; i < normalized.length; i++) {
            normalized[i]['rank'] = normalized[i]['rank'] ?? (i + 1);
          }

          setState(() {
            leaderboardData = normalized;
            errorMessage = null;
          });
        }
      } else {
        setState(() {
          leaderboardData = [];
          errorMessage =
              'Failed to load leaderboard (status ${response.statusCode}).';
        });
      }
    } catch (e) {
      setState(() {
        leaderboardData = [];
        errorMessage = 'Something went wrong: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // --- Parsing Helpers ---

  /// Safely decode JSON text; returns dynamic or null if decode fails.
  dynamic _safeJsonDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Extract a List<Map<String, dynamic>> from likely API response shapes.
  /// Returns null when shape is completely unexpected.
  List<Map<String, dynamic>>? _parseLeaderboardItemsFromResponse(
    dynamic decoded,
  ) {
    if (decoded == null) return null;

    // Case: API returns a List at root
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }

    // Case: API returns a Map: try common keys
    if (decoded is Map) {
      // Common patterns:
      // { "data": [ ... ] }
      if (decoded['data'] is List) {
        return (decoded['data'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }

      // { "data": { "leaderboard": [ ... ] } }
      if (decoded['data'] is Map && decoded['data']['leaderboard'] is List) {
        return (decoded['data']['leaderboard'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }

      // { "leaderboard": [ ... ] } or { "results": [ ... ] }
      if (decoded['leaderboard'] is List) {
        return (decoded['leaderboard'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
      if (decoded['results'] is List) {
        return (decoded['results'] as List)
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }

      // Fallback: find the first List value inside the map
      for (final v in decoded.values) {
        if (v is List) {
          return v
              .whereType<Map>()
              .map((m) => Map<String, dynamic>.from(m))
              .toList();
        }
      }
    }

    // Unknown shape
    return null;
  }

  /// Comparator: prefer numeric `rank`; otherwise prefer numeric `score` (desc).
  int _leaderboardComparator(Map<String, dynamic> a, Map<String, dynamic> b) {
    final aRank = _toInt(a['rank']);
    final bRank = _toInt(b['rank']);
    if (aRank != null && bRank != null) return aRank.compareTo(bRank);

    final aScore = _toInt(a['score']) ?? 0;
    final bScore = _toInt(b['score']) ?? 0;
    return bScore.compareTo(aScore);
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F2027),
                Color.fromARGB(255, 47, 50, 100),
                Color.fromARGB(255, 44, 65, 100),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Leaderboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchLeaderboard,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              )
            : errorMessage != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: fetchLeaderboard,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              )
            : leaderboardData.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'No leaderboard data found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      _buildLeaguesSection(),
                      const SizedBox(height: 20),
                      _buildLeaderboardCard(width),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLeaguesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Leagues",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF101A36),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CustomPaint(
                      painter: PentagonPainter(league['color']),
                      child: Container(
                        height: 80,
                        width: 80,
                        alignment: Alignment.center,
                        child: Icon(
                          league['icon'],
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      league['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101A36),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Top Performers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF101A36),
              ),
            ),
            const SizedBox(height: 20),
            if (leaderboardData.length >= 3) _buildTopThree(width),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            SizedBox(
              // show remaining participants in a scrollable area
              height: 400,
              child: ListView.builder(
                itemCount: leaderboardData.length > 3
                    ? leaderboardData.length - 3
                    : 0,
                itemBuilder: (context, index) {
                  final item = leaderboardData[index + 3];
                  return _buildListTile(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThree(double width) {
    // Defensive: ensure we have at least 3 items
    final top = leaderboardData;
    final Map<String, dynamic> first = top.length > 0
        ? top[0]
        : {'name': '-', 'score': 0, 'rank': 1};
    final Map<String, dynamic> second = top.length > 1
        ? top[1]
        : {'name': '-', 'score': 0, 'rank': 2};
    final Map<String, dynamic> third = top.length > 2
        ? top[2]
        : {'name': '-', 'score': 0, 'rank': 3};

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPodium(second, Colors.grey[400]!, 70, "2"),
        _buildPodium(first, const Color(0xFFFFD700), 90, "1"),
        _buildPodium(third, const Color(0xFFCD7F32), 70, "3"),
      ],
    );
  }

  Widget _buildPodium(
    Map<String, dynamic> user,
    Color color,
    double size,
    String rank,
  ) {
    final name =
        (user['name'] ?? user['full_name'] ?? user['username'] ?? 'Unknown')
            .toString();
    final score = user['score'] ?? user['points'] ?? 0;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: size + 15,
              width: size + 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Text(
              rank,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101A36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF101A36),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          "$score pts",
          style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildListTile(Map<String, dynamic> user) {
    final name =
        (user['name'] ?? user['full_name'] ?? user['username'] ?? 'Unknown')
            .toString();
    final score = user['score'] ?? user['points'] ?? 0;
    final rank = user['rank'] ?? '-';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF101A36),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
          child: Text(
            rank.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          "$score pts",
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// PentagonPainter unchanged (keeps the same look)
class PentagonPainter extends CustomPainter {
  final Color color;
  PentagonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = math.min(w, h) / 2;

    for (int i = 0; i < 5; i++) {
      double angle = (math.pi / 2) + (2 * math.pi * i / 5);
      double x = cx + r * math.cos(angle);
      double y = cy - r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
