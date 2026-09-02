class TranscriptionResult {
  final String originalText;
  final String translatedText;
  final String detectedLanguage;
  final String audioFilePath;

  const TranscriptionResult({
    required this.originalText,
    required this.translatedText,
    required this.detectedLanguage,
    required this.audioFilePath,
  });
}
