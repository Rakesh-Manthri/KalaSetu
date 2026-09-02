class PricingSuggestion {
  final double suggestedPrice;
  final double materialCost;
  final double laborCost;
  final int laborHours;
  final double fairMargin;
  final String currency;

  const PricingSuggestion({
    required this.suggestedPrice,
    required this.materialCost,
    required this.laborCost,
    required this.laborHours,
    required this.fairMargin,
    this.currency = '₹',
  });
}
