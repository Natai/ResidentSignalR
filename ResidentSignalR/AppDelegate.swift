//
//  AppDelegate.swift
//  ResidentSignalR
//
//  Created by natai on 2018/9/21.
//  Copyright © 2018年 natai. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var count = 0
    var timer: Timer?
    lazy var silentPlayer: AVAudioPlayer? = getSilentPlayer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(silentPlayerDidInterrupted), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        silentPlayer?.play()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }
            print(strongSelf.count)
            strongSelf.count += 1
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        silentPlayer?.pause()
        timer?.invalidate()
        count = 0
    }
    
    @objc private func silentPlayerDidInterrupted(notification: Notification) {
        if let rawValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            AVAudioSession.InterruptionType(rawValue: rawValue) == .ended,
            UIApplication.shared.applicationState == .background {
            silentPlayer?.play()
        }
    }
    
    private func getSilentPlayer() -> AVAudioPlayer? {
        let sourceURL = Bundle.main.url(forResource: "silent", withExtension: "mp3")!
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            let player = try AVAudioPlayer(contentsOf: sourceURL)
            player.prepareToPlay()
            player.numberOfLoops = -1
            return player
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
