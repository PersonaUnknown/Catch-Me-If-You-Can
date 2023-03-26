//
//  CustomButtons.swift
//  CSE_438_Final_Project
//
//  Created by 이찬 on 12/1/22.
//

import Foundation
import UIKit

class CustomButtons:UIButton {
    override init(frame:CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder:NSCoder){
        super.init(coder: coder)
        setConfig()
    }
    
    func setConfig() {
        backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
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
    
}
