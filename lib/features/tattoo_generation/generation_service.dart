// Phase 6 / 7 – Generation Service wird hier implementiert.
//
// Verantwortung:
// - Lokale Validierung: baseImage && (referenceImage || tattooDescription)
// - Bildauswahl (image_picker)
// - Upload nach Firebase Storage: users/{uid}/generation_requests/{requestId}/
// - generation_request Dokument in Firestore anlegen
// - createGeneration Cloud Function aufrufen
// - Firestore Status-Updates beobachten (queued → generating → completed / failed)

import 'package:flutter/foundation.dart';

class GenerationService extends ChangeNotifier {
  GenerationService._();
  static final GenerationService instance = GenerationService._();

  // Wird in Phase 6.1 – 7.3 implementiert
}
