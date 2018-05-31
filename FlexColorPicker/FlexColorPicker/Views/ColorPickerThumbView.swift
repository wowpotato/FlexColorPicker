//
//  ColorPickerThumbView.swift
//  FlexColorPicker
//
//  Created by Rastislav Mirek on 28/5/18.
//  
//	MIT License
//  Copyright (c) 2018 Rastislav Mirek
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

private let colorPickerThumbViewDiameter: CGFloat = 28
private let defaultBorderWidth: CGFloat = 6
private let defaultExpandedUpscaleRatio: CGFloat = 1.6
private let expansionAnimationDuration = 0.3
private let collapsingAnimationDelay = 0.1
private let expansionAnimationSpringDamping: CGFloat = 0.7
private let brightnessToChangeToDark: CGFloat = 0.3
private let saturationToChangeToDark: CGFloat = 0.4
private let textLabelUpShift: CGFloat = 12

@IBDesignable
open class ColorPickerThumbView: UIViewWithCommonInit {
    public let borderView = CircleShapedView()
    public let colorView = CircleShapedView()
    public let percentageLabel = UILabel()

    public var autoDarken: Bool = true
    public var showPercentage: Bool = true
    public var expandOnTap: Bool = true

    var expandedUpscaleRatio: CGFloat = defaultExpandedUpscaleRatio {
        didSet {
            if isExpanded {
                setExpanded(true, animated: true)
            }
        }
    }
    open var color: UIColor = .clear {
        didSet {
            colorView.backgroundColor = color
            setDarkBorderIfNeeded()
        }
    }
    open var percentage: Int = 0 {
        didSet {
            updatePercentage(percentage)
        }
    }

    public private(set) var isExpanded = false

    open override var intrinsicContentSize: CGSize {
        return CGSize(width: colorPickerThumbViewDiameter, height: colorPickerThumbViewDiameter)
    }

    var wideBorderWidth: CGFloat {
        return defaultBorderWidth
    }

    open override func commonInit() {
        addAutolayoutFillingSubview(borderView)
        addAutolayoutFillingSubview(colorView, edgeInsets: UIEdgeInsets(top: defaultBorderWidth, left: defaultBorderWidth, bottom: defaultBorderWidth, right: defaultBorderWidth))
        addAutolayoutCentredView(percentageLabel)
        borderView.borderColor = UIColor(named: "BorderColor", in: flexColorPickerBundle)
        borderView.borderWidth = 1 / UIScreen.main.scale
        percentageLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        percentageLabel.textColor = UIColor(named: "PercentageTextColor", in: flexColorPickerBundle)
        percentageLabel.textAlignment = .center
        percentageLabel.alpha = 0
        clipsToBounds = false // required for the text label to be displayed ourside of bounds
        borderView.backgroundColor = UIColor(named: "ThumbViewWideBorderColor", in: flexColorPickerBundle)
    }

    public func updatePercentage(_ percentage: Int) {
        percentageLabel.text = String(min(100, max(0, percentage))) + "%"
    }
}

extension ColorPickerThumbView {
    open func setExpanded(_ expanded: Bool, animated: Bool) {
        let transform = expanded && expandOnTap ? CATransform3DMakeScale(expandedUpscaleRatio, expandedUpscaleRatio, 1) : CATransform3DIdentity
        let textLabelRaiseAmount: CGFloat = expanded && expandOnTap ? (bounds.height / 2) * defaultExpandedUpscaleRatio + textLabelUpShift : (bounds.height / 2)  + textLabelUpShift
        let labelTransform = CATransform3DMakeTranslation(0, -textLabelRaiseAmount, 0)
        isExpanded = expanded

        UIView.animate(withDuration: animated ? expansionAnimationDuration : 0, delay: expanded ? 0 : collapsingAnimationDelay, usingSpringWithDamping: expansionAnimationSpringDamping, initialSpringVelocity: 0, options: [], animations: {
            self.borderView.layer.transform = transform
            self.colorView.layer.transform = transform
            self.percentageLabel.layer.transform = labelTransform
            self.percentageLabel.alpha = expanded && self.showPercentage ? 1 : 0
        }, completion: nil)
    }

    open func setDarkBorderIfNeeded() {
        let (_, s, b) = color.hsbColor.asTupleNoAlpha()
        let isBorderDark = autoDarken && 1 - b < brightnessToChangeToDark && s < saturationToChangeToDark

        #if TARGET_INTERFACE_BUILDER
            setWideBorderColors(isBorderDark) //animations do not work
        #else
        UIView.animate(withDuration: 0.3) {
            self.setWideBorderColors(isBorderDark)
        }
        #endif
    }

    private func setWideBorderColors(_ isDark: Bool) {
        self.borderView.borderColor = UIColor(named: isDark ? "BorderColor" : "LightBorderColor", in: flexColorPickerBundle)
        self.borderView.backgroundColor = UIColor(named: isDark ? "ThumbViewWideBorderDarkColor" : "ThumbViewWideBorderColor", in: flexColorPickerBundle)
    }
}