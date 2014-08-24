//
//  CGPoint.swift
//  SwiftGraphics
//
//  Created by Jonathan Wight on 8/24/14.
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

import CoreGraphics

// MARK: CGPoint

extension CGPoint : Printable {
    public var description: String { get { return "\(x), \(y)" } }
}

public extension CGPoint {
    init(_ v:(CGFloat, CGFloat)) {
        (x, y) = v
    }
    
//    init() {
//        x = 0
//        y = 0
//    }

//    init(_ x:CGFloat, _ y:CGFloat)) {
//        self.x = x, y
//    }

    init(x:CGFloat) {
        self.x = x
        self.y = 0
    }

    init(y:CGFloat) {
        self.x = 0
        self.y = y
    }
}

public func + (lhs:CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

public func - (lhs:CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

public func * (lhs:CGPoint, rhs:CGFloat) -> CGPoint {
    return CGPoint(x:lhs.x * rhs, y:lhs.y * rhs)
}

public func * (lhs:CGFloat, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs * rhs.x, y:lhs * rhs.y)
}

public func / (lhs:CGPoint, rhs:CGFloat) -> CGPoint {
    return CGPoint(x:lhs.x / rhs, y:lhs.y / rhs)
}

public func += (inout lhs:CGPoint, rhs:CGPoint) {
    lhs = lhs + rhs
}

public func -= (inout lhs:CGPoint, rhs:CGPoint) {
    lhs = lhs - rhs
}

public func *= (inout lhs:CGPoint, rhs:CGFloat) {
    lhs = lhs * rhs
}

public func /= (inout lhs:CGPoint, rhs:CGFloat) {
    lhs = lhs / rhs
}

public extension CGPoint {
    func clamped(rect:CGRect) -> CGPoint {
        return CGPoint(
            x:clamp(self.x, rect.minX, rect.maxX),
            y:clamp(self.y, rect.minY, rect.maxY)
        )
    }
}

public extension CGPoint {
    init(length:CGFloat, theta:CGFloat) {
        x = cos(theta) * length
        y = sin(theta) * length
    }

    var length : CGFloat { get { return sqrt(x ** 2 + y ** 2) } }
    var normalized : CGPoint { get { return CGPoint(x:x / length, y:y / length) } }
}

public func atan2(point:CGPoint) -> CGFloat {
    return atan2(point.y, point.x)
}

