import 'dart:math' as math;

/// Exact port of web src/utils/trustScore.ts
class TrustBreakdown {
  final int onTimeReturns;
  final int reviews;
  final int verification;
  final int accountAge;
  final int responsiveness;
  const TrustBreakdown({
    required this.onTimeReturns,
    required this.reviews,
    required this.verification,
    required this.accountAge,
    required this.responsiveness,
  });
}

class TrustScoreResult {
  final int total;
  final String tierName;
  final TrustBreakdown breakdown;
  const TrustScoreResult({
    required this.total,
    required this.tierName,
    required this.breakdown,
  });
}

class TrustHistory {
  final int onTimeReturns;
  final int totalReturns;
  final List<int> reviewRatings; // ratings 1-5 received
  final bool phoneVerified;
  final bool emailVerified;
  final int accountAgeDays;
  final double responseRate;
  const TrustHistory({
    required this.onTimeReturns,
    required this.totalReturns,
    required this.reviewRatings,
    required this.phoneVerified,
    required this.emailVerified,
    required this.accountAgeDays,
    required this.responseRate,
  });
}

const int kOnTimeMax = 40;
const int kOnTimeVolumeFullAt = 8;
const int kReviewsMax = 25;
const int kReviewsCountedMax = 10;
const int kPerVerifiedField = 5;
const int kAccountAgeMax = 10;
const int kAccountAgeDaysPerPoint = 73;
const int kResponsivenessMax = 15;

double _clampD(double v, double lo, double hi) => math.min(hi, math.max(lo, v));
int _clampI(int v, int lo, int hi) => math.min(hi, math.max(lo, v));

int onTimeRatePoints(int onTimeReturns, int totalReturns) {
  if (totalReturns <= 0) return 0;
  final rate = _clampD(onTimeReturns / totalReturns, 0, 1);
  final volume = _clampD(totalReturns / kOnTimeVolumeFullAt, 0, 1);
  return (kOnTimeMax * rate * volume).round();
}

String tierForScore(int score) {
  final s = _clampI(score, 0, 100);
  if (s >= 75) return 'Community Pillar';
  if (s >= 50) return 'Trusted';
  if (s >= 25) return 'Reliable';
  return 'New Neighbor';
}

int tierMinScore(String tierName) {
  switch (tierName) {
    case 'Community Pillar':
      return 75;
    case 'Trusted':
      return 50;
    case 'Reliable':
      return 25;
    default:
      return 0;
  }
}

TrustScoreResult calculateTrustScore(TrustHistory history) {
  final onTime = onTimeRatePoints(history.onTimeReturns, history.totalReturns);

  final reviewCount = math.min(
    history.reviewRatings.length,
    kReviewsCountedMax,
  );
  double avg = 0;
  if (history.reviewRatings.isNotEmpty) {
    var sum = 0.0;
    for (final r in history.reviewRatings) {
      sum += _clampD(r.toDouble(), 1, 5);
    }
    avg = _clampD(sum / history.reviewRatings.length, 0, 5);
  }
  final reviews = ((reviewCount / kReviewsCountedMax) * (avg / 5) * kReviewsMax)
      .round();

  final verification =
      (history.phoneVerified ? kPerVerifiedField : 0) +
      (history.emailVerified ? kPerVerifiedField : 0);

  final accountAge = math.min(
    (history.accountAgeDays / kAccountAgeDaysPerPoint).round(),
    kAccountAgeMax,
  );

  final responsiveness =
      (_clampD(history.responseRate, 0, 1) * kResponsivenessMax).round();

  final total = _clampI(
    onTime + reviews + verification + accountAge + responsiveness,
    0,
    100,
  );
  return TrustScoreResult(
    total: total,
    tierName: tierForScore(total),
    breakdown: TrustBreakdown(
      onTimeReturns: onTime,
      reviews: reviews,
      verification: verification,
      accountAge: accountAge,
      responsiveness: responsiveness,
    ),
  );
}
