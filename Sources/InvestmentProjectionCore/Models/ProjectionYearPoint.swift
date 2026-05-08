import Foundation

public struct ProjectionYearPoint: Equatable, Sendable {
    public let year: Int
    public let balance: Decimal
    public let contributionsToDate: Decimal
    public let growthToDate: Decimal

    public init(
        year: Int,
        balance: Decimal,
        contributionsToDate: Decimal,
        growthToDate: Decimal
    ) {
        self.year = year
        self.balance = balance
        self.contributionsToDate = contributionsToDate
        self.growthToDate = growthToDate
    }
}
