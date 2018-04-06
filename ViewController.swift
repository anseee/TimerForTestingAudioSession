//
//  ViewController.swift
//  TimerForTestingAudioSession
//
//  Created by 박성원 on 2018. 4. 6..
//  Copyright © 2018년 timer. All rights reserved.
//

import UIKit
import UserNotifications
import AudioToolbox.AudioServices

class ViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: .seconds(1))
        t.setEventHandler(handler: { [weak self] in
            self?.reduceSeconds()
        })
        return t
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestAuthorization(completionHandler: { (success) in
            guard success else { return }
            
        })
        
        UNUserNotificationCenter.current().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startTimer(_ sender: Any) {
        if timerLabel.text == "0" {
            timerLabel.text = "5"
        }
        timer.resume()
    }
    
    @objc func reduceSeconds() {
        DispatchQueue.main.async {
            let remindSecond = Int(self.timerLabel.text!)! - 1
            
            self.timerLabel.text = "\(remindSecond)"
            
            if (remindSecond == 0) {
                self.timer.suspend()

                UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                    switch notificationSettings.authorizationStatus {
                    case .notDetermined:
                        break
                    case .authorized:
                        self.scheduleLocalNotification()
                        
                        break
                    case .denied:
                        break
                    }
                }
                
                return
            }
        }
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            
            completionHandler(success)
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Cocoacasts"
        notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "In this tutorial, you learn how to schedule local notifications with the User Notifications framework."
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
    }
}

extension ViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}

