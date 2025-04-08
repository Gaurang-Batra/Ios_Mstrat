//import Charts
//import DGCharts
//import UIKit
//
//class BalloonMarker: MarkerImage {
//    
//    var color: UIColor
//    var font: UIFont
//    var textColor: UIColor
//    var insets: UIEdgeInsets
//    var minimumSize = CGSize()
//    
//    private var label: String = ""
//    private var labelSize: CGSize = .zero
//    private var paragraphStyle: NSMutableParagraphStyle?
//    private var drawAttributes: [NSAttributedString.Key: Any] = [:]
//
//    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
//        self.color = color
//        self.font = font
//        self.textColor = textColor
//        self.insets = insets
//        super.init()
//        
//        paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
//        paragraphStyle?.alignment = .center
//        drawAttributes = [
//            .font: self.font,
//            .paragraphStyle: paragraphStyle!,
//            .foregroundColor: self.textColor
//        ]
//    }
//
//    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
//        label = String(format: "%.2f", entry.y)
//        labelSize = label.size(withAttributes: drawAttributes)
//    }
//
//    override func draw(context: CGContext, point: CGPoint) {
//        guard let chart = chartView else { return }
//
//        let size = CGSize(width: labelSize.width + insets.left + insets.right,
//                          height: labelSize.height + insets.top + insets.bottom)
//
//        var origin = CGPoint(x: point.x - size.width / 2,
//                             y: point.y - size.height - 10)
//
//        // Make sure it doesn't go outside chart bounds
//        if origin.x + size.width > chart.bounds.size.width {
//            origin.x = chart.bounds.size.width - size.width
//        } else if origin.x < 0 {
//            origin.x = 0
//        }
//
//        if origin.y < 0 {
//            origin.y = point.y + 10
//        }
//
//        context.saveGState()
//
//        // MARK: 🔥 Gradient fill
//        let rect = CGRect(origin: origin, size: size)
//        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
//
//        context.addPath(path.cgPath)
//        context.clip()
//
//        let colors = [color.cgColor, color.withAlphaComponent(0.8).cgColor] as CFArray
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
//        context.drawLinearGradient(gradient, start: rect.origin, end: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), options: [])
//
//        // MARK: ✨ Shadow
//        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.2).cgColor)
//
//        context.setFillColor(color.cgColor)
//        context.addPath(path.cgPath)
//        context.fillPath()
//
//        // MARK: 🎯 Draw text
//        let textRect = CGRect(x: origin.x + insets.left,
//                              y: origin.y + insets.top,
//                              width: labelSize.width,
//                              height: labelSize.height)
//
//        label.draw(in: textRect, withAttributes: drawAttributes)
//
//        context.restoreGState()
//    }
//
// func size() -> CGSize {
//        return CGSize(width: labelSize.width + insets.left + insets.right,
//                      height: labelSize.height + insets.top + insets.bottom)
//    }
//}

import Charts
import DGCharts
import UIKit

class BalloonMarker: MarkerImage {
    
    var color: UIColor
    var font: UIFont
    var textColor: UIColor
    var insets: UIEdgeInsets
    var minimumSize = CGSize()
    
    private var label: String = ""
    private var labelSize: CGSize = .zero
    private var paragraphStyle: NSMutableParagraphStyle?
    private var drawAttributes: [NSAttributedString.Key: Any] = [:]

    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        super.init()
        
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.alignment = .center
        drawAttributes = [
            .font: self.font,
            .paragraphStyle: paragraphStyle!,
            .foregroundColor: self.textColor
        ]
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label = String(format: "%.2f", entry.y)
        labelSize = label.size(withAttributes: drawAttributes)
    }

    override func draw(context: CGContext, point: CGPoint) {
        guard let chart = chartView else { return }

        let size = CGSize(width: labelSize.width + insets.left + insets.right,
                          height: labelSize.height + insets.top + insets.bottom)

        var origin = CGPoint(x: point.x - size.width / 2,
                             y: point.y - size.height - 10)

        // Make sure it doesn't go outside chart bounds
        if origin.x + size.width > chart.bounds.size.width {
            origin.x = chart.bounds.size.width - size.width
        } else if origin.x < 0 {
            origin.x = 0
        }

        if origin.y < 0 {
            origin.y = point.y + 10
        }

        context.saveGState()

        // MARK: 🔥 Gradient fill
        let rect = CGRect(origin: origin, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)

        context.addPath(path.cgPath)
        context.clip()

        let colors = [color.cgColor, color.withAlphaComponent(0.8).cgColor] as CFArray
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
        context.drawLinearGradient(gradient, start: rect.origin, end: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height), options: [])

        // MARK: ✨ Shadow
        context.setShadow(offset: CGSize(width: 2, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.2).cgColor)

        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()

        // MARK: 🎯 Draw text
        let textRect = CGRect(x: origin.x + insets.left,
                              y: origin.y + insets.top,
                              width: labelSize.width,
                              height: labelSize.height)

        label.draw(in: textRect, withAttributes: drawAttributes)

        context.restoreGState()
    }

 func size() -> CGSize {
        return CGSize(width: labelSize.width + insets.left + insets.right,
                      height: labelSize.height + insets.top + insets.bottom)
    }
}


class GlassyMarker: MarkerImage {

    var blurEffectStyle: UIBlurEffect.Style = .light
    var font: UIFont
    var textColor: UIColor
    var insets: UIEdgeInsets
    var minimumSize = CGSize()
    
    private var label: String = ""
    private var labelSize: CGSize = .zero
    private var drawAttributes: [NSAttributedString.Key: Any] = [:]

    init(font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.font = font
        self.textColor = textColor
        self.insets = insets
        super.init()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        drawAttributes = [
            .font: self.font,
            .foregroundColor: self.textColor,
            .paragraphStyle: paragraphStyle
        ]
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        label = String(format: "%.1f", entry.y)
        labelSize = label.size(withAttributes: drawAttributes)
    }

    override func draw(context: CGContext, point: CGPoint) {
        guard let chart = chartView else { return }

        let size = CGSize(width: labelSize.width + insets.left + insets.right,
                          height: labelSize.height + insets.top + insets.bottom)

        var origin = CGPoint(x: point.x - size.width / 2,
                             y: point.y - size.height - 10)

        if origin.x + size.width > chart.bounds.size.width {
            origin.x = chart.bounds.size.width - size.width
        } else if origin.x < 0 {
            origin.x = 0
        }

        if origin.y < 0 {
            origin.y = point.y + 10
        }

        let rect = CGRect(origin: origin, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 14)

        context.saveGState()

        // MARK: 🌫️ Blur-style effect (simulated glass)
        let blurColor = UIColor.white.withAlphaComponent(0.15)
        context.setFillColor(blurColor.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()

        // MARK: 💡 Neon-style border
        context.setStrokeColor(UIColor.cyan.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(1.8)
        context.setShadow(offset: .zero, blur: 6, color: UIColor.cyan.cgColor)
        context.addPath(path.cgPath)
        context.strokePath()

        // MARK: 📝 Draw the text
        let textRect = CGRect(x: origin.x + insets.left,
                              y: origin.y + insets.top,
                              width: labelSize.width,
                              height: labelSize.height)
        label.draw(in: textRect, withAttributes: drawAttributes)

        context.restoreGState()
    }

    func size() -> CGSize {
        return CGSize(width: labelSize.width + insets.left + insets.right,
                      height: labelSize.height + insets.top + insets.bottom)
    }
}
