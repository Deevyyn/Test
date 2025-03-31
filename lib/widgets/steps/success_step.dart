import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuccessStep extends StatelessWidget {
  final String? reportId;
  final VoidCallback onSubmitAnother;

  const SuccessStep({
    Key? key,
    required this.reportId,
    required this.onSubmitAnother,
  }) : super(key: key);

  void _copyReportId(BuildContext context) {
    if (reportId != null) {
      Clipboard.setData(ClipboardData(text: reportId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report ID copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 24),
            Text(
              'Report Submitted Successfully!',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you for reporting this flood. Your information will help authorities respond effectively.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (reportId != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Your Report ID',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      reportId!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () => _copyReportId(context),
                                    tooltip: 'Copy Report ID',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                

                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Please save this ID for future reference. You can use it to check the status of your report.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmitAnother,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Submit Another Report'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // This would navigate to a flood map view in a real app
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Flood map feature coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('View Flood Map'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

