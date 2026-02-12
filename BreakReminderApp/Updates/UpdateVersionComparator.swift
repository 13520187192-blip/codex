import Foundation

public enum UpdateVersionComparator {
    public static func isRemoteVersionNewer(remote: String, current: String) -> Bool {
        compare(remote, current) == .orderedDescending
    }

    public static func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let left = normalizedComponents(from: lhs)
        let right = normalizedComponents(from: rhs)
        let count = max(left.count, right.count)

        for index in 0..<count {
            let l = index < left.count ? left[index] : 0
            let r = index < right.count ? right[index] : 0
            if l < r {
                return .orderedAscending
            }
            if l > r {
                return .orderedDescending
            }
        }

        return .orderedSame
    }

    private static func normalizedComponents(from version: String) -> [Int] {
        let cleaned = version.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "v", with: "", options: .caseInsensitive)

        return cleaned
            .split(separator: ".")
            .map { component in
                Int(component.filter { $0.isNumber }) ?? 0
            }
    }
}
