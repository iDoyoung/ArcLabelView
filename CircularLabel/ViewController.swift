//
//  ViewController.swift
//  CircularLabel
//
//  Created by Doyoung on 2021/10/31.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    lazy var arcLabel: UIView = {
        let label = ArcLabelView()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(arcLabel)
        arcLabel.snp.makeConstraints { make in
            make.height.equalTo(self.view.frame.width)
            make.width.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class ArcLabelView: UIView {
    
    let allText = ["Test1", "Test2", "Test3", "Test4", "Test5", "Test6", "Test7", "Test8"]
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: self.bounds.midX, y: self.bounds.midX)
        context.scaleBy (x: 1, y: -1)

        centreArcPerpendicular(text: allText, context: context, radius: (self.bounds.width - 50) / 2, angle: 0, colour: UIColor.red, font: UIFont.systemFont(ofSize: 50), clockwise: true)
    }
    
    func centreArcPerpendicular(text str: [String], context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool){
        
        let characters: [[Character]] = str.map { Array($0) } // An array of single character strings, each character in str
        let l = characters.count
        let attributes = [NSAttributedString.Key.font: font]

        //var arcs: [CGFloat] = [] // This will be the arcs subtended by each character
        let totalArc: CGFloat = 360 // ... and the total arc subtended by the string

        // Calculate the arc subtended by each letter and their total
//        for i in 0 ..< l {
//            //MARK: chord 길이 고정하기
//            arcs += [chordToArc(characters[i].size(withAttributes: attributes).width, radius: r)]
//            totalArc += arcs[i]
//        }

        // Are we writing clockwise (right way up at 12 o'clock, upside down at 6 o'clock)
        // or anti-clockwise (right way up at 6 o'clock)?
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection: CGFloat = clockwise ? -.pi / 2 : .pi / 2

        // The centre of the first character will then be at
        // thetaI = theta - totalArc / 2 + arcs[0] / 2
        // But we add the last term inside the loop
        var thetaI = theta - direction * totalArc / 2

        for i in 0 ..< l {
            thetaI += direction * (.pi * self.frame.width / 8) / 2
            // Call centerText with each character in turn.
            // Remember to add +/-90º to the slantAngle otherwise
            // the characters will "stack" round the arc rather than "text flow"
            var newThetaI = thetaI
            for index in characters[i].indices {
                let char = String(characters[i][index])
                newThetaI += direction * (chordToArc(char.size(withAttributes: attributes).width, radius: r)) / 2
                centre(text: char, context: context, radius: r, angle: newThetaI, colour: c, font: font, slantAngle: newThetaI + slantCorrection)
                newThetaI += direction * (chordToArc(char.size(withAttributes: attributes).width, radius: r)) / 2
            }
//            centre(text: characters[i], context: context, radius: r, angle: thetaI, colour: c, font: font, slantAngle: thetaI + slantCorrection)
            // The centre of the next character will then be at
            // thetaI = thetaI + arcs[i] / 2 + arcs[i + 1] / 2
            // but again we leave the last term to the start of the next loop...
            thetaI += direction * (.pi * self.frame.width / 8) / 2
        }
    }

    //chord = 현
    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
    }

    func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
        // *******************************************************
        // This draws the String str centred at the position
        // specified by the polar coordinates (r, theta)
        // i.e. the x= r * cos(theta) y= r * sin(theta)
        // and rotated by the angle slantAngle
        // *******************************************************

        // Set the text attributes
        let attributes = [NSAttributedString.Key.foregroundColor: c, NSAttributedString.Key.font: font]
        //let attributes = [NSForegroundColorAttributeName: c, NSFontAttributeName: font]
        // Save the context
        context.saveGState()
        // Undo the inversion of the Y-axis (or the text goes backwards!)
        context.scaleBy(x: 1, y: -1)
        // Move the origin to the centre of the text (negating the y-axis manually)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        // Rotate the coordinate system
        context.rotate(by: -slantAngle)
        // Calculate the width of the text
        let offset = str.size(withAttributes: attributes)
        // Move the origin by half the size of the text
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2) // Move the origin to the centre of the text (negating the y-axis manually)
        // Draw the text
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        // Restore the context
        context.restoreGState()
    }
}
