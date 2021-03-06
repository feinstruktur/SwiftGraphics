//
//  BezierBounds.swift
//  SwiftGraphics
//
//  Created by Zhang Yungui <https://github.com/rhcad> on 15/1/13.
//    Modified from http://pomax.nihongoresources.com/pages/bezier
//
//  Copyright (c) 2014 schwa.io. All rights reserved.
//

import CoreGraphics

public extension BezierCurve {
    
// MARK: simpleBounds and bounds
    
    public var simpleBounds: CGRect { get {
        return CGRect.unionOfPoints(points)
    }}
    
    //! Compute the bounding box based on the straightened curve, for best fit
    public var boundingBox: CGRect { get {
        if self.controls.count == 1 {
            return increasedOrder().boundingBox
        }
        
        let pt1 = start!
        let pt2 = controls[0]
        let pt3 = controls[1]
        let pt4 = end
    
        var bbox = CGRect(P1:pt1, P2:pt4)   // compute linear bounds first
        var flag = 0
        
        // Recompute bounds projected on the x-axis, if the control points lie outside the bounding box x-bounds
        if pt2.x < bbox.minX || pt2.x > bbox.maxX || pt3.x < bbox.minX || pt3.x > bbox.maxX {
            let (t1, t2) = computeCubicFirstDerivativeRoots(pt1.x, b:pt2.x, c:pt3.x, d:pt4.x)
            if t1>=0 && t1<=1 {
                let x = computeCubicBaseValue(t1, a:pt1.x, b:pt2.x, c:pt3.x, d:pt4.x)
                bbox.union(CGPoint(x:x, y:bbox.minY))
                flag |= 1
            }
            if t2>=0 && t2<=1 {
                let x = computeCubicBaseValue(t2, a:pt1.x, b:pt2.x, c:pt3.x, d:pt4.x)
                bbox.union(CGPoint(x:x, y:bbox.minY))
                flag |= 2
            }
        }
        
        // Recompute on the y-axis, if the control points lie outside the bounding box y-bounds
        if pt2.y < bbox.minY || pt2.y > bbox.maxY || pt3.y < bbox.minY || pt3.y > bbox.maxY {
            let (t1, t2) = computeCubicFirstDerivativeRoots(pt1.y, b:pt2.y, c:pt3.y, d:pt4.y)
            if t1>=0 && t1<=1 {
                let y = computeCubicBaseValue(t1, a:pt1.y, b:pt2.y, c:pt3.y, d:pt4.y)
                bbox.union(CGPoint(x:bbox.minX, y:y))
                flag |= 4
            }
            if t2>=0 && t2<=1 {
                let y = computeCubicBaseValue(t2, a:pt1.y, b:pt2.y, c:pt3.y, d:pt4.y)
                bbox.union(CGPoint(x:bbox.minX, y:y))
                flag |= 8
            }
        }
        
        return bbox
    }}
    
    // compute the value for the cubic bezier function at time=t
    private func computeCubicBaseValue(t:CGFloat, a:CGFloat, b:CGFloat, c:CGFloat, d:CGFloat) -> CGFloat {
        let v  = 1-t
        let v2 = v*v
        let t2 = t*t
        return v2*v*a + 3*v2*t*b + 3*v*t2*c + t2*t*d
    }
    
    // compute the value for the first derivative of the cubic bezier function at time=t
    private func computeCubicFirstDerivativeRoots(a:CGFloat, b:CGFloat, c:CGFloat, d:CGFloat) -> (CGFloat,CGFloat) {
        let u = b - a, vt = c - b, w = d - c
        let v = abs(u+w - 2*vt)<0.001 ? vt + 0.01 : vt
        
        let denominator = 2*(u - 2*v + w)
        let numerator   = 2*(u - v)
        let uv2         = 2*v-2*u
        let quadroot    = uv2*uv2 - 2*u*denominator
        let root        = sqrt(quadroot)
        
        // there are two possible values for 't' that yield inflection points,
        // and each of these inflection points might be outside the linear bounds
        return ((numerator + root) / denominator, (numerator - root) / denominator)
    }
    
// MARK: isStraight and length
    
    public var isStraight: Bool { get {
        let pts = points
        return collinear(pts[0], pts[2], pts[1])
            || (pts.count == 4 && collinear(pts[0], pts[2], pts[3]))
        }}
    
    // Gauss quadrature for cubic Bezier curves http://processingjs.nihongoresources.com/bezierinfo/
    
    public var length: CGFloat { get {
        if self.isStraight {
            return self.start!.distanceTo(self.end)
        }
        if self.controls.count == 1 {
            return increasedOrder().length
        }
        
        let pts = points
        let z2:CGFloat = 0.5
        var sum:CGFloat = 0.0
        
        for i in 0..<24 {
            let corrected_t = z2 * BezierCurve.Tvalues[i] + z2
            sum += BezierCurve.Cvalues[i] * cubicF(corrected_t, pts)
        }
        
        return z2 * sum
        }}
    
    private func base3(t:CGFloat, _ p1:CGFloat, _ p2:CGFloat, _ p3:CGFloat, _ p4:CGFloat) -> CGFloat {
        let t1 = -3*p1 + 9*p2 - 9*p3 + 3*p4
        let t2 = t*t1 + 6*p1 - 12*p2 + 6*p3
        return t*t2 - 3*p1 + 3*p2
    }
    
    private func cubicF(t:CGFloat, _ pts:[CGPoint]) -> CGFloat {
        let xbase = base3(t, pts[0].x, pts[1].x, pts[2].x, pts[3].x)
        let ybase = base3(t, pts[0].y, pts[1].y, pts[2].y, pts[3].y)
        return hypot(xbase, ybase)
    }
    
    // Legendre-Gauss abscissae (xi values, defined at i=n as the roots of the nth order Legendre polynomial Pn(x))
    private static let Tvalues:[CGFloat] = {
        let arr:[CGFloat] = [-0.06405689286260562997910028570913709, 0.06405689286260562997910028570913709,
            -0.19111886747361631067043674647720763, 0.19111886747361631067043674647720763,
            -0.31504267969616339684080230654217302, 0.31504267969616339684080230654217302,
            -0.43379350762604512725673089335032273, 0.43379350762604512725673089335032273,
            -0.54542147138883956269950203932239674, 0.54542147138883956269950203932239674,
            -0.64809365193697554552443307329667732, 0.64809365193697554552443307329667732,
            -0.74012419157855435791759646235732361, 0.74012419157855435791759646235732361]
        let arr2:[CGFloat] = [-0.82000198597390294708020519465208053, 0.82000198597390294708020519465208053,
            -0.88641552700440107148693869021371938, 0.88641552700440107148693869021371938,
            -0.93827455200273279789513480864115990, 0.93827455200273279789513480864115990,
            -0.97472855597130947380435372906504198, 0.97472855597130947380435372906504198,
            -0.99518721999702131064680088456952944, 0.99518721999702131064680088456952944]
        return arr + arr2
        }()
    
    // Legendre-Gauss weights (wi values, defined by a function linked to in the Bezier primer article)
    private static let Cvalues:[CGFloat] = {
        let arr:[CGFloat] = [0.12793819534675215932040259758650790, 0.12793819534675215932040259758650790,
            0.12583745634682830250028473528800532, 0.12583745634682830250028473528800532,
            0.12167047292780339140527701147220795, 0.12167047292780339140527701147220795,
            0.11550566805372559919806718653489951, 0.11550566805372559919806718653489951,
            0.10744427011596563437123563744535204, 0.10744427011596563437123563744535204,
            0.09761865210411388438238589060347294, 0.09761865210411388438238589060347294,
            0.08619016153195327434310968328645685, 0.08619016153195327434310968328645685]
        let arr2:[CGFloat] = [0.07334648141108029983925575834291521, 0.07334648141108029983925575834291521,
            0.05929858491543678333801636881617014, 0.05929858491543678333801636881617014,
            0.04427743881741980774835454326421313, 0.04427743881741980774835454326421313,
            0.02853138862893366337059042336932179, 0.02853138862893366337059042336932179,
            0.01234122979998720018302016399047715, 0.01234122979998720018302016399047715]
        return arr + arr2
        }()
}
