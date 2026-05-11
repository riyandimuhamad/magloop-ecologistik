class AppConfig {
  // Aturan: 1 Kg = 10 GreenCoins (GC)
  static const int pointsPerKg = 10;

  // Aturan: 10 GC = Rp 1.000 (Artinya 1 GC = Rp 100)
  static const int rupiahPerPoint = 100;
  
  static int calculatePoints(double weight) {
    return (weight * pointsPerKg).toInt();
  }

  static int calculateRupiah(int points) {
    return points * rupiahPerPoint;
  }
}
