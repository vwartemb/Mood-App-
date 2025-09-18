//
//  JournalPopUpController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/9/25.
// the journal entry pop up when a user presses a cell

import UIKit
import CoreData

class JournalPopUpController: UIViewController {
    
    // We’ll store a reference to the entry we’re editing
    private var moodEntry: MoodEntry?
    
    var onSave: (() -> Void)?
    
    //  MARK: - Set up
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Journal Entry"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholderText
        label.font = UIFont.italicSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = "Add note..."
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        button.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(notesTextView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        notesTextView.addSubview(placeholderLabel)
        view.addSubview(titleLabel)

        
        notesTextView.delegate = self
        
        
        // Populate the UI if we have a moodEntry w/ existing notes
        if let entry = moodEntry {
            notesTextView.text = entry.notes
        }
        setupLayout()
    }
    
    private func setupLayout(){
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        notesTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            
            //Date label in top-right corner
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderLabel.topAnchor.constraint(equalTo: notesTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: notesTextView.trailingAnchor, constant: -8),
            
            // Notes text view in the center
            notesTextView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 32),
            notesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            notesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            notesTextView.heightAnchor.constraint(equalToConstant: 800),
            
            // Save button near the bottom-right
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Cancel/Close button near the bottom-left
            cancelButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
    }
    
    // Configure the pop-up with the selected entry
    func configure(with entry: MoodEntry) {
        self.moodEntry = entry
    }
    
    @objc private func saveTapped() {
        guard let entry = moodEntry else {
            dismiss(animated: true, completion: nil)
            return
        }
        // Update the notes in the existing entry
        entry.notes = notesTextView.text
        
        // Save to Core Data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            try context.save()
            print("Updated journal notes!")
        } catch {
            print("Failed to update entry: \(error)")
        }
        onSave?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
}
extension JournalPopUpController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView){
        //Hide the placeholder if the user types anything
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
