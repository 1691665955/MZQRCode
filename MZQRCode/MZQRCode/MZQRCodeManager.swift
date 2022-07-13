//
//  MZQRCodeManager.swift
//  MZQRCode
//
//  Created by 曾龙 on 2022/7/11.
//

import UIKit
import MZAuthorization

public struct MZQRCodeManager {
    
    /// 扫描二维码
    /// - Parameter completionHandler: 扫描回调
    public static func scanQRCode(completionHandler:  @escaping (String) -> Void) {
        MZAuthorization.requestAuth(type: .camera) {
            let scanController = MZQRCodeScanController()
            scanController.completionHandler = completionHandler
            scanController.modalTransitionStyle = .coverVertical
            scanController.modalPresentationStyle = .fullScreen
            UIApplication.shared.delegate?.window!!.rootViewController?.present(scanController, animated: true)
        }
    }
    
    /// 生成二维码图片
    /// - Parameters:
    ///   - content: 二维码内容
    ///   - size: 二维码尺寸
    ///   - logo: 二维码填充logo
    ///   - backgroundColor: 二维码背景颜色
    ///   - fillColor: 二维码颜色
    ///   - completionHandler: 二维码生成回调
    public static func createQRCode(content: String, size: CGFloat = 200.0, backgroundColor: UIColor = .white, fillColor: UIColor = .black, logo: UIImage? = nil, completionHandler: @escaping (UIImage) -> Void) {
        DispatchQueue.init(label: "createQRCode").async {
            // 创建滤镜对象
            let filter = CIFilter.init(name: "CIQRCodeGenerator")!
            // 恢复默认设置
            filter.setDefaults()
            // 设置数据
            let infoData = content.data(using: .utf8)
            filter.setValue(infoData, forKey: "inputMessage")
            // 生成二维码
            let outputImage = filter.outputImage
            
            // 设置二维码颜色
            let colorFilter = CIFilter.init(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(outputImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(color: fillColor), forKey: "inputColor0")
            colorFilter.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")
            
            let newOutputImage = colorFilter.outputImage!
            let scale = size / newOutputImage.extent.width
            
            var image = UIImage(ciImage: newOutputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale)))
            
            if let logoImage = logo {
                let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                
                UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
                image.draw(in: rect)
                let logoSize = CGSize(width: rect.width / 4, height: rect.height / 4)
                let x = (rect.width - logoSize.width) /  2
                let y = (rect.height - logoSize.height) / 2
                logoImage.draw(in: CGRect(x: x, y: y, width: logoSize.width, height: logoSize.height))
                
                image = UIGraphicsGetImageFromCurrentImageContext()!
                
                UIGraphicsEndImageContext()
            }
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }
    }
    
    /// 识别二维码
    /// - Parameters:
    ///   - image: 二维码图片
    ///   - completionHandler: 识别回调
    public static func identifyQRCode(_ image: UIImage, completionHandler: @escaping (String?) -> Void) {
        DispatchQueue.init(label: "").async {
            var ciImage = image.ciImage
            if ciImage == nil {
                guard let cgImage = image.cgImage else {
                    DispatchQueue.main.async {
                        completionHandler(nil)
                    }
                    return
                }
                ciImage = CIImage.init(cgImage: cgImage)
            }
            
            // 初始化扫描仪，设置识别类型和识别质量
            let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
            
            // 扫描获取的特征组
            let features = detector.features(in: ciImage!)
            
            // 获取扫描结果
            if features.count == 1 {
                let feature = features[0] as! CIQRCodeFeature
                let content = feature.messageString
                DispatchQueue.main.async {
                    completionHandler(content)
                }
            } else if features.count > 1 {
                DispatchQueue.main.async {
                    let identifyController = MZQRCodeIndentifyController()
                    identifyController.completionHandler = completionHandler
                    identifyController.modalTransitionStyle = .coverVertical
                    identifyController.modalPresentationStyle = .fullScreen
                    identifyController.qrCodeImage = image
                    identifyController.features = features as? [CIQRCodeFeature]
                    currentViewController()?.present(identifyController, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            }
        }
    }
    
    private static func currentViewController() -> UIViewController? {
        guard let controller = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        return self.currentViewControllerFrom(controller)
    }
    
    private static func currentViewControllerFrom(_ root: UIViewController) -> UIViewController {
        let currentViewController: UIViewController
        if root.presentedViewController != nil {
            return self.currentViewControllerFrom(root.presentedViewController!)
        }
        if root.isKind(of: UITabBarController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UITabBarController).selectedViewController!)
        } else if root.isKind(of: UINavigationController.classForCoder()) {
            currentViewController = self.currentViewControllerFrom((root as! UINavigationController).visibleViewController!)
        } else {
            currentViewController = root
        }
        return currentViewController
    }
}
