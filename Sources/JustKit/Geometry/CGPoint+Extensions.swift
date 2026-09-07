import CoreGraphics

public extension CGPoint {
    var distance: Double {
        sqrt(pow(x, 2) + pow(y, 2))
    }
}
