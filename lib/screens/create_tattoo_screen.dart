import 'package:flutter/material.dart';

class CreateTattooScreen extends StatelessWidget {
  const CreateTattooScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tattoo AI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your perfect tattoo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Base Image Placeholder
            _buildSection(
              title: 'Base Image (Required)',
              child: _buildPlaceholderBox('Tap to upload Base Image'),
            ),
            const SizedBox(height: 16),
            
            // Reference Image Placeholder
            _buildSection(
              title: 'Reference Tattoo (Optional)',
              child: _buildPlaceholderBox('Tap to upload Reference Image'),
            ),
            const SizedBox(height: 16),
            
            // Tattoo Description
            _buildSection(
              title: 'Tattoo Description (Optional)',
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Describe your dream tattoo...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 32),
            
            // Generate Button
            FilledButton(
              onPressed: () {
                // TODO: Implement generation logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generation not implemented yet')),
                );
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Generate Tattoo',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPlaceholderBox(String text) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
