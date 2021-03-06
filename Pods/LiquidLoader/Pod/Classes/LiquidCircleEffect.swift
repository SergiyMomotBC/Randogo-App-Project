//
//  LiquidCircleLoader.swift
//  LiquidLoading
//
//  Created by Takuma Yoshida on 2015/08/21.
//  Copyright (c) 2015年 yoavlt. All rights reserved.
//

import Foundation
import UIKit

class LiquidCircleEffect : LiquidLoadEffect {

    var radius: CGFloat {
        get {
            return loader!.frame.width * 0.5
        }
    }
    
    override func setupShape() -> [LiquittableCircle] {
        return Array(0..<numberOfCircles).map { i in
            let angle = CGFloat(i) * CGFloat(2 * CGFloat.pi) / 8.0
            let frame = self.loader.frame
            let center = CGMath.circlePoint(frame.center.minus(frame.origin), radius: self.radius - self.circleRadius, rad: angle)
            return LiquittableCircle(
                center: center,
                radius: self.circleRadius,
                color: self.color,
                growColor: self.growColor
            )
        }
    }

    override func movePosition(_ key: CGFloat) -> CGPoint {
        guard self.loader != nil else {return CGPoint.zero}
        
        let frame = self.loader!.frame.center.minus(self.loader!.frame.origin)
        return CGMath.circlePoint(
            frame,
            radius: self.radius - self.circleRadius,
            rad: self.key * CGFloat(2 * CGFloat.pi)
        )
    }

    override func update() {
        switch key {
        case 0.0...1.0:
            key += 1/(duration*60)
        default:
            key = key - 1.0
        }
    }

    override func willSetup() {
        self.circleRadius = loader.frame.width * 0.09
        self.circleScale = 1.10
        self.engine = SimpleCircleLiquidEngine(radiusThresh: self.circleRadius * 0.85, angleThresh: 0.5)
        let moveCircleRadius = circleRadius * moveScale
        moveCircle = LiquittableCircle(center: movePosition(0.0), radius: moveCircleRadius, color: self.color, growColor: self.growColor)
    }

    override func resize() {
        guard moveCircle != nil else { return }
        guard loader != nil else { return }
        
        let moveVec = moveCircle!.center.minus(loader.center.minus(loader.frame.origin)).normalized()
        circles.map { circle in
            return (circle, moveVec.dot(circle.center.minus(self.loader.center.minus(self.loader.frame.origin)).normalized()))
        }.each { entry in
            let circle = entry.0
            let dot = entry.1
            if 0.75 < dot && dot <= 1.0 {
                let normalized = (dot - 0.75) / 0.25
                let scale = normalized * normalized
                circle.radius = self.circleRadius + (self.circleRadius * self.circleScale - self.circleRadius) * scale
            } else {
                circle.radius = self.circleRadius
            }
        }
    }
    
}
