//
//  CustomRequestButton.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 12/3/22.
//

import UIKit

class CustomRequestButton: UIButton {
    override init(frame:CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder:NSCoder){
        super.init(coder: coder)
        setConfig()
    }
    
    func setConfig() {
        backgroundColor = UIColor.clear
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 15.0
    }
    
    func touchIn(){
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {self.transform = .init(scaleX: 0.9, y:0.9)}, completion: nil)
    }
    
    func touchEnd() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {self.transform = .identity}, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchIn()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchEnd()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
