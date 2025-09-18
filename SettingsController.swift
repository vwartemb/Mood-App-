//
//  SettingsController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.
// Quiz: Gesture
//Settings page is done 

import UIKit
import CoreData
import UserNotifications

class SettingsController: UIViewController, UNUserNotificationCenterDelegate {
    
    // Title label at the top
    private let settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings:"
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        return label
    }()
    
    private let DarkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Dark Mode"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    // Label for the notification toggle
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Reminders"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    // Toggle switch to enable/disable reminders
    private let notificationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false // Default off
        return toggle
    }()
    
    private let DarkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = false //default off
        return toggle
    }()
    
    // Time picker configured to pick time only in a compact style (iOS 14+)
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = .compact
        }
        picker.isEnabled = false
        return picker
    }()
    
    private let clearMoodsLabel: UIButton = {
        let clear = UIButton(type: .system)
        clear.setTitle("Clear Moods", for: .normal)
        clear.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        clear.addTarget(self, action: #selector(clearAllMoodsFromCoreData), for: .touchUpInside)
        return clear
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        UNUserNotificationCenter.current().delegate = self
        
        
        // Request notification authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied: \(error?.localizedDescription ?? "No error info")")
            }
        }
        
        view.addSubview(settingsTitleLabel)
        view.addSubview(DarkModeLabel)
        view.addSubview(notificationLabel)
        view.addSubview(notificationSwitch)
        view.addSubview(DarkModeSwitch)
        view.addSubview(timePicker)
        view.addSubview(clearMoodsLabel)
        
        // Add target for the switch
        notificationSwitch.addTarget(self, action: #selector(notificationSwitchChanged), for: .valueChanged)
        DarkModeSwitch.addTarget(self, action: #selector(darkModeSwitchToggled), for: .valueChanged)
        
        setupLayout()
        scheduleTestNotification()
    }
    
    // MARK: - Layout Setup
    
    private func setupLayout() {
        // Disable autoresizing masks
        settingsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        DarkModeLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        notificationSwitch.translatesAutoresizingMaskIntoConstraints = false
        DarkModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        clearMoodsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            settingsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            DarkModeLabel.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 80),
            DarkModeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            notificationLabel.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 140),
            notificationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            DarkModeSwitch.centerYAnchor.constraint(equalTo: DarkModeLabel.centerYAnchor),
            DarkModeSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: DarkModeLabel.trailingAnchor, constant: 200),
            
            notificationSwitch.centerYAnchor.constraint(equalTo: notificationLabel.centerYAnchor),
            notificationSwitch.leadingAnchor.constraint(greaterThanOrEqualTo: notificationLabel.trailingAnchor, constant: 10),
            
            timePicker.centerYAnchor.constraint(equalTo: notificationLabel.centerYAnchor),
            timePicker.leadingAnchor.constraint(equalTo: notificationSwitch.trailingAnchor, constant: 10),
            timePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            
            clearMoodsLabel.topAnchor.constraint(equalTo: settingsTitleLabel.bottomAnchor, constant: 200),
            clearMoodsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func clearAllMoodsFromCoreData() {
        // Retrieve the managed object context from the AppDelegate's persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Create a fetch request for the MoodEntry entity.
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MoodEntry.fetchRequest()
        
        // Create a batch delete request using the fetch request.
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()
            
            print("All moods cleared from Core Data")
        } catch {
            print("Failed to clear moods: \(error)")
        }
    }
    private func scheduleDailyNotification(at date: Date) {
        // get the hour and minute components from the selected date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        //  a trigger that repeats daily at the given time
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Don't forget to log your mood today!"
        content.sound = .default
        
        // Create the notification request with an identifier so you can cancel it later
        let request = UNNotificationRequest(identifier: "DailyMoodReminder", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(date)")
            }
        }
    }

    @objc private func notificationSwitchChanged() {
        // Enable or disable the time picker based on the switch’s state
        timePicker.isEnabled = notificationSwitch.isOn
        
        if notificationSwitch.isOn {
            scheduleDailyNotification(at: timePicker.date)
        } else {
            // Cancel any scheduled notifications
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyMoodReminder"])
            print("Notifications disabled")
        }
    }
    
    @objc private func darkModeSwitchToggled() {
        let isDark = DarkModeSwitch.isOn
        UserDefaults.standard.set(isDark, forKey: "darkModeEnabled")
        
        // Apply it to the whole app
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if let window = sceneDelegate.window {
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
        }
    }
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This should appear in 10 seconds."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled in 10 seconds.")
            }
        }
    }
}
extension SettingsController {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner and play a sound even if app is in foreground
        completionHandler([.banner, .sound])
    }
}
