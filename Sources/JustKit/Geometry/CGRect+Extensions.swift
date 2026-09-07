import CoreGraphics

public extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
