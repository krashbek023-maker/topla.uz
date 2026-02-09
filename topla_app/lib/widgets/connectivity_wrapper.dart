import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';

/// Internet uzilganda ekran yuqorisida banner ko'rsatadi
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _showRestoredBanner = false;
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        final isConnected = connectivity.isConnected;

        // Internet tiklanganda — keyingi frame'da banner ko'rsatish
        if (isConnected && _wasOffline && !_showRestoredBanner) {
          _wasOffline = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _showRestoredBanner = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() => _showRestoredBanner = false);
                }
              });
            }
          });
        }

        // Internet uzilganda flag saqlash
        if (!isConnected) {
          _wasOffline = true;
        }

        return Column(
          children: [
            // Internet yo'q banner
            if (!isConnected)
              _buildOfflineBanner(context)
            // Internet tiklandi banner
            else if (_showRestoredBanner)
              _buildOnlineBanner(context),

            // Asosiy kontent
            Expanded(child: widget.child),
          ],
        );
      },
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Material(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          bottom: 8,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Internet aloqasi yo\'q',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineBanner(BuildContext context) {
    return Material(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          bottom: 8,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_rounded,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Internet aloqasi tiklandi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
