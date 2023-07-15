//
//  MZAudioPlayTool.swift
//  TDSwiftTemplate
//
//  Created by 曾龙 on 2021/11/29.
//

import AVFoundation

struct MZAudioPlayTool {
    
    /// 播放自定义声音，不超过30s
    /// - Parameter named: 音频文件名称,带后缀
    static func playAudio(_ named: String) {
        if let path = Bundle.qrBundle!.path(forResource: named, ofType: nil) {
            let url = URL.init(fileURLWithPath: path)
            var id: SystemSoundID = 1
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
            AudioServicesPlaySystemSound(id)
        }
    }
    
    /// 震动
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
