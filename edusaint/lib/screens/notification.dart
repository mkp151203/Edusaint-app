import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 🔹 API URL (CHANGE ONLY THIS IF NEEDED)
  static const String apiUrl = "https://byte.edusaint.in/api/v1/notifications";

  String selectedCategory = "All";
  bool isLoading = false;
  String? errorMessage;

  final List<String> categories = ["Learning", "Rewards", "Friends", "System"];

  List<Map<String, dynamic>> allNotifications = [];

  // ================= API =================

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      allNotifications.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {"Accept": "application/json"},
      );

      // 🔍 DEBUG RAW RESPONSE (IMPORTANT)
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RAW RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = "Server error (${response.statusCode})";
        });
        return;
      }

      // ❌ Empty response
      if (response.body.isEmpty) {
        setState(() {
          errorMessage = "Empty server response";
        });
        return;
      }

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        setState(() {
          errorMessage = "Invalid JSON response from server";
        });
        return;
      }

      // ✅ CASE 1: API returns LIST directly
      if (decoded is List) {
        setState(() {
          allNotifications = List<Map<String, dynamic>>.from(decoded);
        });
        return;
      }

      // ✅ CASE 2: API returns OBJECT with data
      if (decoded is Map) {
        // data key
        if (decoded["data"] is List) {
          setState(() {
            allNotifications = List<Map<String, dynamic>>.from(decoded["data"]);
          });
          return;
        }

        // notifications key
        if (decoded["notifications"] is List) {
          setState(() {
            allNotifications = List<Map<String, dynamic>>.from(
              decoded["notifications"],
            );
          });
          return;
        }

        // error message from backend
        if (decoded["message"] != null) {
          setState(() {
            errorMessage = decoded["message"].toString();
          });
          return;
        }
      }

      // ❌ If nothing matched
      setState(() {
        errorMessage = "Unsupported API response format";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Unable to connect to server";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final response = await http.delete(Uri.parse("$apiUrl/$id"));

      if (response.statusCode == 200) {
        setState(() {
          allNotifications.removeWhere((n) => n["id"] == id);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Notification deleted")));
      } else {
        throw Exception();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete notification"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = selectedCategory == "All"
        ? allNotifications
        : allNotifications
              .where((n) => n["category"] == selectedCategory)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2B2F76),
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(child: _buildContent(filteredNotifications)),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: const Color(0xFF2B2F76),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => setState(() => selectedCategory = category),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> notifications) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (notifications.isEmpty) {
      return const Center(child: Text("No notifications found"));
    }

    return RefreshIndicator(
      onRefresh: fetchNotifications,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];

          return Dismissible(
            key: ValueKey(n["id"]),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              return await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Delete Notification"),
                  content: const Text(
                    "Are you sure you want to delete this notification?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) => deleteNotification(n["id"]),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(n["title"] ?? ""),
                subtitle: Text(n["message"] ?? ""),
                trailing: Text(
                  n["status"] ?? "",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
