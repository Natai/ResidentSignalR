//
//  ViewController.swift
//  ResidentSignalR
//
//  Created by natai on 2018/9/21.
//  Copyright © 2018年 natai. All rights reserved.
//

import UIKit
import SignalR_ObjC
import UserNotifications

class ViewController: UIViewController {
    private var identifier = 0
    private lazy var MQSConnection = getMQSConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNotification()
    }

    private func getMQSConnection() -> SRHubConnection {
        let MQSConnection = SRHubConnection(urlString: "http://192.168.0.51:8056/mqs", queryString: ["uid": "10956BFA1C5148CDBAC66987FA830864"])!
        let dialogHub = MQSConnection.createHubProxy("dialoghub") as! SRHubProxy
        dialogHub.on("getMessage", perform: self, selector: #selector(getDialogMessage(_:)))
        return MQSConnection
    }
    
    private func configureNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("授权成功")
            }
        }
    }
    
    @objc private func getDialogMessage(_ message: Any) {
        sendNotification(identifier: String(identifier))
        identifier += 1
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        MQSConnection.start()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        MQSConnection.stop()
    }
    
    private func sendNotification(identifier: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = identifier
        notificationContent.body = "body"
        notificationContent.sound = UNNotificationSound.default
        
        let notificationRequest = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: nil)
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: nil)
    }
}

// MARK:
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active { // 前台静默，不发送通知
            completionHandler([])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}
