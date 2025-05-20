import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/feedback/feedback_model.dart';

class FeedbackService {
  static final CollectionReference _feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  static Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      await _feedbackCollection.add(feedback.toMap());
    } catch (e) {
      throw Exception('Error submitting feedback: $e');
    }
  }

  static Stream<List<FeedbackModel>> getFeedbackStream() {
    return _feedbackCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FeedbackModel.fromMap(data);
      }).toList();
    });
  }

  static Future<List<FeedbackModel>> getFeedbackList() async {
    try {
      final snapshot = await _feedbackCollection
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FeedbackModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Error getting feedback list: $e');
    }
  }

  static Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _feedbackCollection.doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Error deleting feedback: $e');
    }
  }

  static Future<void> updateFeedback(String feedbackId, FeedbackModel feedback) async {
    try {
      await _feedbackCollection.doc(feedbackId).update(feedback.toMap());
    } catch (e) {
      throw Exception('Error updating feedback: $e');
    }
  }
} 