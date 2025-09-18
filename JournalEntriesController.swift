//
//  JournalEntriesController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.
// list of all journal entries ever created
import UIKit
import CoreData

class JournalEntriesController: UIViewController, NSFetchedResultsControllerDelegate{
    
    
    // MARK: - UI
    private let searchBar = UISearchBar()
   
    private let JournalEntryLabel: UILabel = {
        let label = UILabel()
        label.text = "Journal Entries"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    private var tableView: UITableView!
    
    // MARK: - Search Helpers
    private var filteredEntries: [MoodEntry] = []
    private var isSearching: Bool = false
    
    // MARK: - Fetched Results Controller
    private lazy var moodEntries: NSFetchedResultsController<MoodEntry> = {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        // Sort by timestamp descending
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: context,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Journal Entries"
        
        // Set up the search bar
        searchBar.delegate = self
        searchBar.placeholder = "Search entries..."
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoodCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        view.addSubview(JournalEntryLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        JournalEntrySetUp()
        fetchMoodEntries()
        
        let hasLoggedMoodToday = checkIfMoodLoggedForToday()
        if !hasLoggedMoodToday {
            presentMoodEntryScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMoodEntries()
    
        // Fix the tab bar (make it non-transparent)
        if let tabBar = tabBarController?.tabBar {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .white
            tabBar.standardAppearance = tabBarAppearance
            
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBarAppearance
            }
            
            tabBar.isTranslucent = false
        }
    }
    
    private func JournalEntrySetUp() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        JournalEntryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            JournalEntryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            JournalEntryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            JournalEntryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchBar.topAnchor.constraint(equalTo: JournalEntryLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // if theres no mood present the pop up else don't using a boolean func
    private func checkIfMoodLoggedForToday() -> Bool {
        if let lastLoggedDate = UserDefaults.standard.object(forKey: "lastLoggedDate") as? Date {
            // Check if lastLoggedDate is "today"
            return Calendar.current.isDateInToday(lastLoggedDate)
        } else {
            return false
        }
    }
  
    // for the mood entry pop up
    private func presentMoodEntryScreen() {
        let moodVC = PopUpController()

        moodVC.modalPresentationStyle = .automatic
        present(moodVC, animated: true, completion: nil)
    }
    
    // for the journal entry pop up
    private func presentJournalEntryScreen() {
        let moodVC = PopUpController()

        moodVC.modalPresentationStyle = .automatic
        present(moodVC, animated: true, completion: nil)
    }
    
    private func fetchMoodEntries() {
        do {
            try self.moodEntries.performFetch()
        } catch {
            debugPrint("error")
        }
    }
}
// MARK: - UISearchBarDelegate
extension JournalEntriesController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let allEntries = moodEntries.fetchedObjects else {
            return
        }
        
        if searchText.isEmpty {
            // Show all entries if the search is empty
            isSearching = false
            filteredEntries.removeAll()
        } else {
            // Filter the entries
            isSearching = true
            
            filteredEntries = allEntries.filter { entry in
                let moodMatch = entry.mood?.localizedCaseInsensitiveContains(searchText) ?? false
                let descMatch = entry.moodDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                let notesMatch = entry.notes?.localizedCaseInsensitiveContains(searchText) ?? false
                
                // Format the timestamp to search by date string
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                let dateString = formatter.string(from: entry.timestamp ?? Date())
                let dateMatch = dateString.localizedCaseInsensitiveContains(searchText)
                
                return moodMatch || descMatch || notesMatch || dateMatch
            }
        }
        
        tableView.reloadData()
    }
    
    //Dismiss keyboard when search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension JournalEntriesController: UITableViewDataSource, UITableViewDelegate {
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredEntries.count
        } else {
            return moodEntries.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoodCell", for: indexPath)

        let entry: MoodEntry
        if isSearching {
            // Use filtered entries
            entry = filteredEntries[indexPath.row]
        } else {
            // Use all fetched entries
            guard let allEntries = moodEntries.fetchedObjects else {
                return cell
            }
            entry = allEntries[indexPath.row]
        }
        
        
        // Now configure the cell with `entry`
        let emoji = entry.mood ?? ""
        let desc = entry.moodDescription ?? ""
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: entry.timestamp ?? Date())
        
        // Truncate notes to ~30 chars
        let notesPreview = entry.notes ?? ""
        let truncated = notesPreview.count > 30 ? String(notesPreview.prefix(30)) + "..." : notesPreview
        
        cell.textLabel?.text = "\(emoji) Feeling \(desc) - \(truncated)\n      \(dateString)"
        cell.textLabel?.numberOfLines = 2
        
        // Customize cell appearance
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        // Add padding to the content view
        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        
        return cell
    }
    
    // Set cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80
    }
    
    // handle row tap for editing or detail
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let entry = moodEntries.fetchedObjects?[indexPath.row] else {
            return
        }
        let popup = JournalPopUpController()
        popup.configure(with: entry)
        popup.modalPresentationStyle = .fullScreen
        popup.onSave = { [weak self] in
            self?.fetchMoodEntries()
        }
        present(popup, animated: true, completion: nil)
    }
    
    // Enable swipe-to-delete functionality
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Access the Core Data context
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entryToDelete: MoodEntry
            
            if isSearching {
                // Get the entry from filtered array when searching
                entryToDelete = filteredEntries[indexPath.row]
                filteredEntries.remove(at: indexPath.row)
            } else {
                // Get the entry from the fetched objects
                guard let allEntries = moodEntries.fetchedObjects else { return }
                entryToDelete = allEntries[indexPath.row]
            }
            
            // Delete the entry from Core Data
            context.delete(entryToDelete)
            do {
                try context.save()
            } catch {
                print("Error saving context after deletion: \(error)")
            }
            
            // Remove the row from the table view with an animation
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
