import SwiftUI

enum DesignTokens {

    // MARK: - Spacing
    enum Spacing {
        static let xxs:  CGFloat = 2
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 12
        static let lg:   CGFloat = 16
        static let xl:   CGFloat = 20
        static let xxl:  CGFloat = 24
        static let xxxl: CGFloat = 36

        // Semantic aliases
        static let inputHorizontal: CGFloat = 12
        static let inputVertical:   CGFloat = 10
        static let inputLabelGap:   CGFloat = 3
        static let fieldSpacing:    CGFloat = 20
        static let inputFieldHeight: CGFloat = 55
        static let screenHorizontal: CGFloat = 24
        static let screenBottom:    CGFloat = 36
    }

    // MARK: - Corner Radius
    enum Radius {
        static let field:    CGFloat = 8
        static let button:   CGFloat = 10
        static let card:     CGFloat = 12
        static let cardLg:   CGFloat = 14
        static let search:   CGFloat = 24
    }

    // MARK: - Animation
    enum Animation {
        static let fast:     Double = 0.15
        static let standard: Double = 0.25
    }

    // MARK: - Icon Sizes
    enum IconSize {
        static let xs:  CGFloat = 11
        static let sm:  CGFloat = 13
        static let md:  CGFloat = 15
        static let lg:  CGFloat = 22
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 34
        static let hero: CGFloat = 48
        static let eye:  CGFloat = 16
    }

    // MARK: - Component Sizes
    // design.md §2a: named sizes keep Views free of raw numbers
    enum Size {
        static let logoWidth:     CGFloat = 96
        static let tabItemHeight: CGFloat = 38
    }

    // MARK: - Layout
    // design.md §2a (iPad adaptive): shared max-width used by every full-screen form
    enum Layout {
        static let maxWidthRegular: CGFloat = 430
    }
}
