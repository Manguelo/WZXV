//
//  GradientButton.swift
//  SwiftRadio
//
//  Created by Matthew Anguelo on 3/2/18.
//  Copyright © 2018 matthewfecher.com. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class GradientButton: UIButton{
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
        
        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
        
            gradientLayer.frame = bounds
            gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = layer.cornerRadius
            gradientLayer.opacity = 0.7
            layer.insertSublayer(gradientLayer, at: 0)
            //self.bringSubview(toFront: self.imageView!)
            
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
}


