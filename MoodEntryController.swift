//
//  MoodEntryController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.
// This is the view controller that the user sees first when they go into the app
import UIKit
import CoreData

class MoodEntryController: UIViewController {
    
    var defaultMood: String?
    
    private let quickAccess: UILabel = {
        let label = UILabel()
        label.text = "Quick Entry"
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a date:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.isEnabled = true
        return picker
    }()

    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Mood:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let moodSegmentedControl: UISegmentedControl = {
        let moods = ["😔", "😐", "😊", "😡"]
        let sc = UISegmentedControl(items: moods)
        sc.selectedSegmentIndex = UISegmentedControl.noSegment
        return sc
    }()
    
    private let intensityLabel: UILabel = {
        let label = UILabel()
        label.text = "Intensity (1-10):"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let intensitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = 5
        return slider
    }()
    
    private let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Journal Entry:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 8
        return tv
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Entry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(saveEntry), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add/Edit Mood"
        
        
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        view.addSubview(moodLabel)
        view.addSubview(moodSegmentedControl)
        view.addSubview(intensityLabel)
        view.addSubview(intensitySlider)
        view.addSubview(notesLabel)
        view.addSubview(notesTextView)
        view.addSubview(saveButton)
        view.addSubview(quickAccess)
        
        
        setupLayout()
        //preSelectMoodIfNeeded()
    }
    
    private func setupLayout() {
        quickAccess.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        moodSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        notesLabel.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            // trendsLabel at the top of contentView
            quickAccess.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            quickAccess.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quickAccess.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // ---------------------dateLabel-------------------------
            dateLabel.topAnchor.constraint(equalTo: quickAccess.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            // ---------------------datePicker-------------------------
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // ---------------------moodLabel-------------------------
            moodLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            moodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            // ---------------------moodSegment-------------------------
            moodSegmentedControl.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 8),
            moodSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            moodSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // ---------------------intensityLabel-------------------------
            intensityLabel.topAnchor.constraint(equalTo: moodSegmentedControl.bottomAnchor, constant: 10),
            intensityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // ---------------------intensitySlider-------------------------
            intensitySlider.topAnchor.constraint(equalTo: intensityLabel.bottomAnchor, constant: 8),
            intensitySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            intensitySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // ---------------------notesLabel-------------------------
            notesLabel.topAnchor.constraint(equalTo: intensitySlider.bottomAnchor, constant: 10),
            notesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            // ---------------------notesTextView-------------------------
            notesTextView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 8),
            notesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            notesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            notesTextView.heightAnchor.constraint(equalToConstant: 350),
            
            // ---------------------saveButton-------------------------
            saveButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /* If Home screen passed a `defaultMood`, select it in the segmented control.
    private func preSelectMoodIfNeeded() {
        guard let defaultMood = defaultMood else { return }
        let count = moodSegmentedControl.numberOfSegments
        for index in 0..<count {
            let title = moodSegmentedControl.titleForSegment(at: index)
            if title == defaultMood {
                moodSegmentedControl.selectedSegmentIndex = index
                break
            }
        }
    }*/
    
    @objc private func saveEntry() {
        //  Get the selected mood
        guard moodSegmentedControl.selectedSegmentIndex != UISegmentedControl.noSegment else {
            print("No mood selected!")
            return
        }
        let selectedEmoji = moodSegmentedControl.titleForSegment(at: moodSegmentedControl.selectedSegmentIndex) ?? "😐"
        
        // Map emoji -> description
        let moodMap: [String: String] = [
            "😔": "Sad",
            "😐": "Neutral",
            "😊": "Happy",
            "😡": "Angry"
        ]
        let moodDesc = moodMap[selectedEmoji] ?? "Neutral"
        let intensity = intensitySlider.value
        let notes = notesTextView.text ?? ""
        
        // Save to Core Data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newEntry = MoodEntry(context: context)
        newEntry.mood = selectedEmoji
        newEntry.moodDescription = moodDesc
        newEntry.intensity = intensity
        newEntry.notes = notes
        newEntry.timestamp = datePicker.date
        
        do {
            try context.save()
            print("Mood entry saved successfully!")
        } catch {
            print("Failed to save mood entry: \(error)")
        }
        // Reset the form after saving
        resetForm()
    
    }
    private func resetForm() {
        moodSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        intensitySlider.value = 5
        notesTextView.text = ""
        datePicker.setDate(Date(), animated: true) // Reset datePicker to current date
    }
}
