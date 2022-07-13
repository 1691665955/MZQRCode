//
//  ViewController.swift
//  MZQRCode
//
//  Created by 曾龙 on 2022/7/11.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageView.center = self.view.center
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage.init(named: "test")
        self.view.addSubview(imageView)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(identifyQRCode(tap:)))
        imageView.addGestureRecognizer(tap)
        
        let scanBtn = UIButton(type: .custom)
        scanBtn.frame = CGRect(x: 0, y: 120, width: 100, height: 40)
        var center = self.view.center
        center.y = scanBtn.center.y
        scanBtn.center = center
        scanBtn.setTitle("扫码识别", for: .normal)
        scanBtn.setTitleColor(.brown, for: .normal)
        scanBtn.addTarget(self, action: #selector(scanQRCode), for: .touchUpInside)
        self.view.addSubview(scanBtn)
        
        MZQRCodeManager.createQRCode(content: "zzz", fillColor: .brown, logo: UIImage.init(named: "avatar")) { image in
            imageView.image = image
        }
        
    }

    @objc func identifyQRCode(tap: UITapGestureRecognizer) {
        let imageView = tap.view as! UIImageView
        MZQRCodeManager.identifyQRCode(imageView.image!) { content in
            print("识别结果为:\(content ?? "Null")")
        }
    }
    
    @objc func scanQRCode() {
        MZQRCodeManager.scanQRCode { value in
            print("扫码结果为:\(value)")
        }
    }

}

