//
//  DonutChartView.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/10/25.
//

import UIKit

// A simple model for the chart segments
struct ChartSegment {
    let value: CGFloat
    let color: UIColor
}

class DonutChartView: UIView {
    
    //Array of segments to display in the donut chart
    var segments: [ChartSegment] = [] {
        didSet {
            setNeedsDisplay() // redraw whenever segments change
        }
    }
    
    // This controls the thickness of the donut ring
    var ringWidth: CGFloat = 100
    
    override func draw(_ rect: CGRect) {
        guard !segments.isEmpty else { return }
        
        // Get the center of the view and the radius for the chart
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - ringWidth
        
        // Calculate total value of all segments
        let totalValue = segments.reduce(0) { $0 + $1.value }
        
        // Starting angle for the first segment
        var startAngle: CGFloat = -.pi / 2  // starts at top center
        
        for segment in segments {
            let endAngle = startAngle + 2 * .pi * (segment.value / totalValue)
            
            // Create a path for the donut slice
            let path = UIBezierPath()
            path.addArc(withCenter: centerPoint,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true)
            
            // Move inward to create a ring
            path.addArc(withCenter: centerPoint,
                        radius: radius - ringWidth,
                        startAngle: endAngle,
                        endAngle: startAngle,
                        clockwise: false)
            
            path.close()
            
            // Fill the segment color
            segment.color.setFill()
            path.fill()
            
            // Update start angle for next segment
            startAngle = endAngle
        }
    }
}
