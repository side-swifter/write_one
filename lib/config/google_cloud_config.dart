class GoogleCloudConfig {
  // Google Cloud Vision API Credentials
  static const String projectId = 'gen-lang-client-0931779335';
  static const String apiKey = 'AQ.Ab8RN6IJWumgzQlffe-IC2CVyucutJbc2yWT4A27UfyHRxLWmQ';
  
  // For simple HTTP API calls, we just need the project ID and API key
  static bool get isConfigured {
    return projectId.isNotEmpty && apiKey != 'YOUR_API_KEY';
  }
}
