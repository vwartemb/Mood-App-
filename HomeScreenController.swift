//
//  HomeScreenController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.
//
import UIKit
import CoreData

class HomeScreenController: UIViewController {
    
    // stores all fetched moods entries from core data
    private var moodEntries: [MoodEntry] = []

    private var tableView: UITableView!
    
    // Dynamically chnages the background color based on the user's mood
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
    
    private let HomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Home"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let moodIntroLabel: UILabel = {
        let label = UILabel()
        label.text = "Today we are feeling"
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let moodEmojiLabel: UILabel = {
        let label = UILabel()
        label.text = "<No mood logged yet>"
        label.font = UIFont.systemFont(ofSize: 30) // Larger font for emoji
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let RecentEntriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Entries"
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        
        tableView = UITableView(frame: .zero, style: .plain)
        
        // register a basic UITableViewCell usder the identifier "RecentCell"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentCell")
        
        // This assigns this class as data source and delegate, so the table can display the data
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        view.addSubview(HomeLabel)
        view.addSubview(moodIntroLabel)
        view.addSubview(moodEmojiLabel)
        view.addSubview(RecentEntriesLabel)
        
        setupLayout()
        
        updateMoodLabel()
        fetchMoodEntries()
        
        // checks if the user has logged in an emotion for today
        let hasLoggedMoodToday = checkIfMoodLoggedForToday()
        if !hasLoggedMoodToday {
            presentMoodEntryScreen()
        }
    }
    
    // added a viewwillAppear to force a refresh each time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMoodLabel()
        fetchMoodEntries()
    }
    
    
    private func setupLayout() {
        HomeLabel.translatesAutoresizingMaskIntoConstraints = false
        moodIntroLabel.translatesAutoresizingMaskIntoConstraints = false
        moodEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        RecentEntriesLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            HomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            HomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            moodIntroLabel.topAnchor.constraint(equalTo: HomeLabel.bottomAnchor, constant: 40),
            moodIntroLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodIntroLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moodIntroLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            moodEmojiLabel.topAnchor.constraint(equalTo: moodIntroLabel.topAnchor, constant: 40),
            moodEmojiLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            moodEmojiLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            RecentEntriesLabel.topAnchor.constraint(equalTo: moodEmojiLabel.bottomAnchor, constant: 50),
            RecentEntriesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            tableView.topAnchor.constraint(equalTo: RecentEntriesLabel.topAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Pop-Up Logic
    
    // Checks if the user has already logged a mood today (via UserDefaults) by comparing the last logged date with the current date
    private func checkIfMoodLoggedForToday() -> Bool {
        if let lastLoggedDate = UserDefaults.standard.object(forKey: "lastLoggedDate") as? Date {
            return Calendar.current.isDateInToday(lastLoggedDate)
        } else {
            return false
        }
    }
    
    // Presents a pop-up or modal screen prompting the user to log a mood
    private func presentMoodEntryScreen() {
        let moodVC = PopUpController()
        
        // Provide a callback that refreshes the Home screen
        moodVC.onMoodSaved = { [weak self] in
            self?.updateMoodLabel()
        }
        moodVC.modalPresentationStyle = .automatic
        present(moodVC, animated: true, completion: nil)
    }
    
    
    // MARK: - Fetching & Displaying the Mood
    
    // Fetch today's mood from Core Data and update `moodLabel`.
    private func updateMoodLabel() {
        guard let todaysEntry = fetchTodaysMood(),
              let emoji = todaysEntry.mood,
              let desc = todaysEntry.moodDescription else {
            moodIntroLabel.text = "Today we are feeling"
            moodEmojiLabel.text = "<No mood logged yet>"
            return
        }

        moodIntroLabel.text = "Today we are feeling"
        moodEmojiLabel.font = .systemFont(ofSize: 35)
        moodEmojiLabel.text = "\(emoji)"
        updateBackgroundColor(for: desc)
    }
    // Fetches ALL mood entries from Core data, sorted by timestamp
    private func fetchMoodEntries() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        // Sort by timestamp descending
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        do {
            moodEntries = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Failed to fetch mood entries: \(error)")
        }
    }
    
    // Presents a pop-up or modal screen prompting the user to log a journal entry
    private func presentJournalEntryScreen() {
        let moodVC = PopUpController()

        moodVC.modalPresentationStyle = .automatic
        present(moodVC, animated: true, completion: nil)
    }
    
    
    // Fetches today's mood entry from Core Data (if it exists)
    private func fetchTodaysMood() -> MoodEntry? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        // Start and end of today's date
        let startOfDay = Calendar.current.startOfDay(for: Date())
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
        
        // Only fetch entries where timestamp is today
        request.predicate = NSPredicate(
            format: "timestamp >= %@ AND timestamp < %@",
            startOfDay as NSDate, endOfDay as NSDate
        )
        
        // Sort descending in case the user logged multiple times today
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch today's mood: \(error)")
            return nil
        }
    }
}

// MARK: - UITableViewDataSource
extension HomeScreenController: UITableViewDataSource {
    // how many rows I want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moodEntries.count
    }
    // Provides the cell for each row at the indexpath
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath)
        let entry = moodEntries[indexPath.row]
        let emoji = entry.mood ?? ""
        let desc = entry.moodDescription ?? ""
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: entry.timestamp ?? Date())
        
        // Truncate notes to ~30 chars
        let notesPreview = entry.notes ?? ""
        let truncated = notesPreview.count > 30 ? String(notesPreview.prefix(30)) + "..." : notesPreview
        
        cell.textLabel?.text = "\(emoji) Feeling \(desc)\n      \(dateString)"
        cell.textLabel?.numberOfLines = 2
        
        // Customize cell appearance
        cell.contentView.layer.cornerRadius = 12 // Round corners
        cell.contentView.layer.masksToBounds = true // Clip to bounds
        cell.selectionStyle = .none
        
        // Add padding/margins to the content view
        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        
        return cell
    }
    
    // Implements swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Access the Core Data context
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let entryToDelete = moodEntries[indexPath.row]
            
            context.delete(entryToDelete)
            do {
                try context.save()
                moodEntries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Failed to delete mood entry: \(error)")
            }
        }
    }
}

extension HomeScreenController:  UITableViewDelegate {
    // sets a fixed height for each row in the table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80
    }
    // Handles the event where a user taps on a row in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entry = moodEntries[indexPath.row]
        let popup = JournalPopUpController()
        
        popup.configure(with: entry)
      
        popup.modalPresentationStyle = .fullScreen
     
        popup.onSave = { [weak self] in
            self?.fetchMoodEntries()
        }
        present(popup, animated: true, completion: nil)
    }
    
}
