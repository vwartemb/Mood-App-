//
//  PopUpController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/6/25.
//

import UIKit

class PopUpController: UIViewController {
    
    private func updateBackgroundColor(for mood: String) {
        switch mood {
            case "Happy":
                view.backgroundColor = UIColor(red: 255/255, green: 249/255, blue: 196/255, alpha: 1.0) // Soft Yellow
            case "Neutral":
                view.backgroundColor = UIColor(red: 220/255, green: 231/255, blue: 250/255, alpha: 1.0) // Soft Blue
            case "Sad":
                view.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0) // Lighter Blue
            case "Angry":
                view.backgroundColor = UIColor(red: 248/255, green: 215/255, blue: 218/255, alpha: 1.0) // Muted Red
            default:
                view.backgroundColor = .systemBackground
        }
    }
    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.text = "Hi,\nHow are we\nfeeling today?"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // Time picker configured to pick time only in a compact style
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.isEnabled = true
        return picker
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    private let emojiStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    private let intensitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 5
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Mood", for: .normal)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.addTarget(self, action: #selector(confirmMood), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private var selectedMood: String?
    
    // put moods into a key-value pair for display and saving reasons
    struct Mood {
        let emoji: String
        let description: String
    }

    private let moods: [Mood] = [
        Mood(emoji: "😊", description: "Happy"),
        Mood(emoji: "😐", description: "Neutral"),
        Mood(emoji: "😔", description: "Sad"),
        Mood(emoji: "😡", description: "Angry")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(moodLabel)
        view.addSubview(datePicker)
        view.addSubview(scrollView)
        scrollView.addSubview(emojiStackView)
        view.addSubview(intensitySlider)
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
        
        setupEmojiButtons()
        setupLayout()
    }
    
    private func setupEmojiButtons() {
        for mood in moods {
            let containerStackView = UIStackView()
            containerStackView.axis = .vertical
            containerStackView.alignment = .center
            containerStackView.spacing = 4
            
            let button = UIButton(type: .system)
            button.setTitle(mood.emoji, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 80)
            button.addTarget(self, action: #selector(emojiButtonTapped(_:)), for: .touchUpInside)
            containerStackView.addArrangedSubview(button)
            
            let label = UILabel()
            label.text = mood.description
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .black
            label.textAlignment = .center
            containerStackView.addArrangedSubview(label)
            
            emojiStackView.addArrangedSubview(containerStackView)
        }
    }

    @objc private func emojiButtonTapped(_ sender: UIButton) {
        guard let emoji = sender.title(for: .normal) else { return }
        
        // Find the matching mood struct
        if let moodStruct = moods.first(where: { $0.emoji == emoji }) {
            selectedMood = emoji
            updateBackgroundColor(for: moodStruct.description) // 🌟 Change background dynamically
        }
        print("Mood selected: \(emoji)")
    }
     
    private func setupLayout() {
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        emojiStackView.translatesAutoresizingMaskIntoConstraints = false
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Cancel/Close button in the top-right corner
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16), // Add padding from the top
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20), // Add padding from the right
            
            moodLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            moodLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: moodLabel.bottomAnchor, constant: 40),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 150), // Increased height to accommodate labels
            
            
            
            emojiStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            emojiStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            emojiStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            emojiStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            
            datePicker.topAnchor.constraint(equalTo: emojiStackView.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -90),
            
            intensitySlider.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 40),
            intensitySlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            intensitySlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            
            confirmButton.topAnchor.constraint(equalTo: intensitySlider.bottomAnchor, constant: 40),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    var onMoodSaved: (() -> Void)?
    
    @objc private func confirmMood() {
        let intensity = intensitySlider.value
        guard let mood = selectedMood else {
            print("No mood selected!")
            return
        }
        onMoodSaved?()
        print("Mood: \(mood) with intensity: \(intensity)")
        dismiss(animated: true, completion: nil)
        saveMoodToCoreData()
    }
    
    private func saveMoodToCoreData() {
        guard let mood = selectedMood else { return }
        guard let moodStruct = moods.first(where: { $0.emoji == mood }) else { return }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newEntry = MoodEntry(context: context)
        newEntry.mood = mood
        newEntry.moodDescription = moodStruct.description
        newEntry.intensity = intensitySlider.value
        newEntry.timestamp = Date()
        
        do {
            try context.save()
            print("Mood saved to Core Data")
        } catch {
            print("Failed to save mood: \(error)")
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let fraction = CGFloat(sender.value / sender.maximumValue)
        let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
        if maxOffsetX > 0 {
            let newOffset = fraction * maxOffsetX
            scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
        }
    }
}
