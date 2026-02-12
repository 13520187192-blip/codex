import SwiftUI

enum NeoNoirTheme {
    enum Colors {
        static let baseBackground = Color(#colorLiteral(red: 0.03921568627, green: 0.05490196078, blue: 0.0862745098, alpha: 1)) // #0A0E16
        static let deepBlue = Color(#colorLiteral(red: 0.1176470588, green: 0.3098039216, blue: 0.5019607843, alpha: 1)) // #1E4F80
        static let sunsetOrange = Color(#colorLiteral(red: 0.9607843137, green: 0.5450980392, blue: 0.2901960784, alpha: 1)) // #F58B4A
        static let focusAccent = Color(#colorLiteral(red: 0.4470588235, green: 0.8980392157, blue: 0.3568627451, alpha: 1)) // #72E55B

        static let overlayWine = Color(#colorLiteral(red: 0.5568627451, green: 0.1843137255, blue: 0.231372549, alpha: 1)) // #8E2F3B
        static let overlayRose = Color(#colorLiteral(red: 0.7764705882, green: 0.2901960784, blue: 0.3333333333, alpha: 1)) // #C64A55

        static let card = Color(#colorLiteral(red: 0.06666666667, green: 0.09411764706, blue: 0.1450980392, alpha: 1))
        static let panelBackground = Color(#colorLiteral(red: 0.07058823529, green: 0.0862745098, blue: 0.1254901961, alpha: 1))
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.78)
        static let textMuted = Color.white.opacity(0.56)
        static let subtleBorder = Color.white.opacity(0.14)
    }

    enum Metrics {
        static let cornerRadius: CGFloat = 12
        static let controlCornerRadius: CGFloat = 10
        static let sideGlowWidth: CGFloat = 3
    }

    enum Motion {
        static let buttonPress = Animation.easeOut(duration: 0.12)
        static let cardIn = Animation.easeOut(duration: 0.26)
        static let listStagger = Animation.easeOut(duration: 0.22)
        static let overlaySpring = Animation.spring(response: 0.36, dampingFraction: 0.82)
    }
}
