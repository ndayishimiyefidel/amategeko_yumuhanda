// Production configuration
class ProductionConfig {
  static const bool enableDebugPrints = false;
  static const bool enableDebugLogs = false;

  // Use this to conditionally print debug messages
  static void debugPrint(String message) {
    if (enableDebugPrints) {
      print(message);
    }
  }

  // Use this to conditionally log debug information
  static void debugLog(String message) {
    if (enableDebugLogs) {
      print('🔍 DEBUG: $message');
    }
  }
}
