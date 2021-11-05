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
        label.backgroundColor = .clear
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
    
    let allText = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"]
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.translateBy(x: self.bounds.midX, y: self.bounds.midX)
        context.scaleBy (x: 1, y: -1)

        centreArcPerpendicular(text: allText, context: context, radius: (self.bounds.size.width - 40) / 2, angle: 0, colour: UIColor.red, font: UIFont.systemFont(ofSize: 40), clockwise: true)
    }
    
    func centreArcPerpendicular(text str: [String], context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, clockwise: Bool){
        
        let characters: [[Character]] = str.map { Array($0) }
        let l = characters.count
        let attributes = [NSAttributedString.Key.font: font]
        let direction: CGFloat = clockwise ? -1 : 1
        let slantCorrection: CGFloat = clockwise ? -.pi / 2 : .pi / 2
        var thetaI: CGFloat = deg2rad(0)

        for i in 0 ..< l {
            var newThetaI = thetaI
            for index in characters[i].indices {
                let char = String(characters[i][index])
                newThetaI += direction * (chordToArc(char.size(withAttributes: attributes).width, radius: r)) / 2
                centre(text: char, context: context, radius: r, angle: newThetaI, colour: c, font: font, slantAngle: newThetaI + slantCorrection)
                newThetaI += direction * (chordToArc(char.size(withAttributes: attributes).width, radius: r)) / 2
            }
            thetaI += direction * deg2rad(360/8)
        }
    }

    func chordToArc(_ chord: CGFloat, radius: CGFloat) -> CGFloat {
        return 2 * asin(chord / (2 * radius))
    }

    func centre(text str: String, context: CGContext, radius r: CGFloat, angle theta: CGFloat, colour c: UIColor, font: UIFont, slantAngle: CGFloat) {
      
        let attributes = [NSAttributedString.Key.foregroundColor: c, NSAttributedString.Key.font: font]
       
        context.saveGState()
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: r * cos(theta), y: -(r * sin(theta)))
        context.rotate(by: -slantAngle)
        let offset = str.size(withAttributes: attributes)
        context.translateBy (x: -offset.width / 2, y: -offset.height / 2)
        str.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        context.restoreGState()
    }
}

func deg2rad(_ number: CGFloat) -> CGFloat {
    return number * .pi / 180
}
