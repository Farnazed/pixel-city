//
//  PopVC.swift
//  pixel-city
//
//  Created by farnaz on 2019-10-20.
//  Copyright © 2019 farnaz. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popUpImageView: UIImageView!
    
    var passedImage : UIImage!
    
    func initData(forImage image : UIImage){
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpImageView.image = passedImage
        addDoubleTap()
        
    }
    
    func addDoubleTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func doubleTap(){
        self.dismiss(animated: true, completion: nil)
           
    }
    


}
