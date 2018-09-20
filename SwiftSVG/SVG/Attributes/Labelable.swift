//
//  Labelable.swift
//  Pods-ColoringDemo
//
//  Created by Viktor Smeshkov on 9/17/18.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

let labelableSVGElementLabelXKey = "labelableSVGElementLabelXKey"
let labelableSVGElementLabelYKey = "labelableSVGElementLabeYKey"
let labelableSVGElementLabelText = "labelableSVGElementLabeText"
let labelableSVGElementColorId = "labelableSVGElementColorId"
let labelableSVGElementFont = UIFont.systemFont(ofSize: 20)


public protocol Labelable { }

/**
 Default implementation for the style attribute on `SVGElement`s
 */
extension Labelable where Self : SVGShapeElement {
    
    var labelAttributes: [String : (String) -> ()] {
        return [
            "labelx": parseLabelX,
            "labely": parseLabelY,
            "text": labelText,
            "colorId": colorId,
        ]
    }
    
    internal func parseLabelX(x: String) {
        guard let x = CGFloat(x) else {
            return
        }
        svgLayer.setValue(x, forKey: labelableSVGElementLabelXKey)
    }

    internal func parseLabelY(y: String) {
        guard let y = CGFloat(y) else {
            return
        }
        svgLayer.setValue(y, forKey: labelableSVGElementLabelYKey)
    }
    
    internal func labelText(text: String) {
        svgLayer.setValue(text, forKey: labelableSVGElementLabelText)
    }
    
    internal func colorId(id: String) {
        svgLayer.setValue(id, forKey: labelableSVGElementColorId)
    }
    
    internal func getLabelLayer() -> CATextLayer? {
        guard let labelX = svgLayer.value(forKeyPath: labelableSVGElementLabelXKey) as? CGFloat,
            let labelY = svgLayer.value(forKeyPath: labelableSVGElementLabelYKey) as? CGFloat
            else { return nil }
        
        let text = "1"
        
        let textLayer = LabelTextLayer()
        textLayer.font = labelableSVGElementFont
        textLayer.fontSize = labelableSVGElementFont.pointSize
        textLayer.string = text
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        let textSize = text.boundingRect(with: constraintRect,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedStringKey.font: labelableSVGElementFont],
                                         context: nil).size
        let origin = CGPoint(x: labelX - textSize.width / 2, y: labelY - textSize.height / 2)
        let rect = CGRect(origin: origin, size: textSize)
        textLayer.frame = rect

        DispatchQueue.main.safeAsync({
            textLayer.setNeedsDisplay()
        })
        
        return textLayer
    }
    
}

class LabelTextLayer: CATextLayer {
    override func contains(_ p: CGPoint) -> Bool {
        return false
    }
}

extension String {
    func size(font: UIFont) -> CGSize {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.size
    }
}
