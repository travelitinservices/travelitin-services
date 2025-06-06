import 'package:flutter/material.dart'; //place it in lib/screens
import '../services/cdn_service.dart';

class CdnScreen extends StatefulWidget {
  @override
  _CdnScreenState createState() => _CdnScreenState();
}

class _CdnScreenState extends State<CdnScreen> {
  final CdnService cdnService = CdnService();
  String fileUrl = "";
  String filePath = "assets/banner.png";
  String jwtToken = "your-jwt-token";

  void fetchFile() async {
    String? url = await cdnService.fetchCDNFile(filePath, jwtToken);
    if (url != null) {
      setState(() {
        fileUrl = url;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFile();  // Fetch CDN file when screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CDN File Viewer")),
      body: Center(
        child: fileUrl.isNotEmpty
            ? Image.network(fileUrl)  // Display fetched CDN file
            : Text("Loading CDN file..."),
      ),
    );
  }
}