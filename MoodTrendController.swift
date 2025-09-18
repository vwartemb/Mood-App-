//
//  MoodTrendController.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.


import UIKit
import CoreData

class MoodTrendController: UIViewController {
    
    // Maps each mood to a display label and a color.
    struct MoodLegendItem {
        let moodEmoji: String
        let moodLabel: String
        let color: UIColor
    }

    private let moodLegend: [MoodLegendItem] = [
        MoodLegendItem(moodEmoji: "😊", moodLabel: "Happy", color: .systemYellow),
        MoodLegendItem(moodEmoji: "😔", moodLabel: "Sad",   color: .systemBlue),
        MoodLegendItem(moodEmoji: "😡", moodLabel: "Angry", color: .systemRed),
        MoodLegendItem(moodEmoji: "😐", moodLabel: "Neutral", color: .systemMint),
    ]
    
    private func createLegendView() -> UIStackView {
        let legendStack = UIStackView()
        legendStack.axis = .vertical
        legendStack.alignment = .leading
        legendStack.spacing = 8
        
        for item in moodLegend {
            // A horizontal stack for each row
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.alignment = .center
            rowStack.spacing = 8
            
            // The colored dot
            let colorDot = UIView()
            colorDot.backgroundColor = item.color
            colorDot.layer.cornerRadius = 8
            colorDot.widthAnchor.constraint(equalToConstant: 16).isActive = true
            colorDot.heightAnchor.constraint(equalToConstant: 16).isActive = true
            
            // label
            let moodLabel = UILabel()
            moodLabel.text = "\(item.moodEmoji) \(item.moodLabel)"
            moodLabel.font = UIFont.systemFont(ofSize: 16)
            
            // dot + label
            rowStack.addArrangedSubview(colorDot)
            rowStack.addArrangedSubview(moodLabel)
            
            // Add row to the main legend stack
            legendStack.addArrangedSubview(rowStack)
        }
        
        return legendStack
    }

    // MARK: - Scroll & Content
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = true
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    private let contentView = UIView()
    
    // MARK: - Calendar Controls
    private var headerView: UIStackView!
    private var previousMonthButton: UIButton!
    private var nextMonthButton: UIButton!
    private var monthYearLabel: UILabel!
    
    private var collectionView: UICollectionView!
    private var moods: [Date: String] = [:] // Maps normalized dates to mood emojis
    private var currentDate = Date() // Tracks the currently displayed month
    
    // MARK: - UI Elements
    private let trendsLabel: UILabel = {
        let label = UILabel()
        label.text = "Mood \nTrends"
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Week", "Month", "Year"])
        control.selectedSegmentIndex = 1 // default to "Month"
        return control
    }()
    
    private let chartView: DonutChartView = {
        let view = DonutChartView()
        view.backgroundColor = .clear
        view.ringWidth = 40
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mood Trends"

        // Add the scrollView to the main view
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        // Add contentView inside the scrollView
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Constrain scrollView & contentView
        NSLayoutConstraint.activate([
            // Make scrollView fill the entire safe area
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // contentView matches the scrollView’s edges (vertical scrolling)
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            // Match the scrollView’s width so there’s no horizontal scrolling
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        setupViewsAndConstraints()
        
        // create and add the legendView AFTER chartView is in the same hierarchy
        let legendView = createLegendView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(legendView)
        
        NSLayoutConstraint.activate([
            legendView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 60),
            legendView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            legendView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
        ])
        loadChartData(for: .month)
        fetchMoods()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMoods()
    }
    
    // MARK: - Setup All Views & Constraints
    private func setupViewsAndConstraints() {
        // ----- Create previous/next month buttons + month label -----
        previousMonthButton = UIButton(type: .system)
        previousMonthButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousMonthButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        previousMonthButton.addTarget(self, action: #selector(didTapPreviousMonth), for: .touchUpInside)
        
        nextMonthButton = UIButton(type: .system)
        nextMonthButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextMonthButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        nextMonthButton.addTarget(self, action: #selector(didTapNextMonth), for: .touchUpInside)
        
        monthYearLabel = UILabel()
        monthYearLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        monthYearLabel.textAlignment = .center
        updateMonthYearLabel()
        
        headerView = UIStackView(arrangedSubviews: [previousMonthButton, monthYearLabel, nextMonthButton])
        headerView.axis = .horizontal
        headerView.alignment = .center
        headerView.distribution = .equalCentering
        headerView.spacing = 16
        
        // ----- Create the collection view for the calendar -----
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        // ----- Add subviews to contentView (not to the main view) -----
        contentView.addSubview(trendsLabel)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(chartView)
        contentView.addSubview(headerView)
        contentView.addSubview(collectionView)
        
        // ----- Disable autoresizing masks -----
        trendsLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        chartView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // ----- Setup segmented control action -----
        segmentedControl.addTarget(self, action: #selector(timeRangeChanged(_:)), for: .valueChanged)
        
        // ----- Constrain everything within contentView -----
        NSLayoutConstraint.activate([
            // trendsLabel at the top of contentView
            trendsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            trendsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trendsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // segmentedControl below trendsLabel
            segmentedControl.topAnchor.constraint(equalTo: trendsLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // chartView below segmentedControl
            chartView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200),
            
            
            // headerView below the chartView
            headerView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 40),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 50),
            
            // collectionView below the headerView, with a fixed height
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 400),
            
            // IMPORTANT: anchor the bottom of collectionView to contentView bottom
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
    
    // MARK: - Calendar Actions
    @objc private func didTapPreviousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            updateMonthYearLabel()
            collectionView.reloadData()
        }
    }
    
    @objc private func didTapNextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            updateMonthYearLabel()
            collectionView.reloadData()
        }
    }
    
    private func updateMonthYearLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthYearLabel.text = formatter.string(from: currentDate)
    }
    
    // MARK: - Segmented Control
    @objc private func timeRangeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadChartData(for: .week)
        case 1:
            loadChartData(for: .month)
        default:
            loadChartData(for: .year)
        }
    }
    
    // MARK: - Load Chart Data from Core Data
    private func loadChartData(for range: TimeRange) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        let calendar = Calendar.current
        var startDate: Date?
        var endDate: Date?
        
        switch range {
        case .week:
            if let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) {
                startDate = interval.start
                endDate = interval.end
            }
        case .month:
            if let interval = calendar.dateInterval(of: .month, for: Date()) {
                startDate = interval.start
                endDate = interval.end
            }
        case .year:
            if let interval = calendar.dateInterval(of: .year, for: Date()) {
                startDate = interval.start
                endDate = interval.end
            }
        }
        
        // Set predicate to filter entries by the computed date range
        if let start = startDate, let end = endDate {
            request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@", start as NSDate, end as NSDate)
        }
        
        do {
            // Fetch mood entries in the specified date range
            let entries = try context.fetch(request)
            
            // mood counts
            var moodCounts: [String: Int] = [:]
            for entry in entries {
                if let mood = entry.mood {
                    moodCounts[mood, default: 0] += 1
                }
            }
            
            // Convert counts into chart segments
            var segments: [ChartSegment] = []
            for (mood, count) in moodCounts {
                let segment = ChartSegment(value: CGFloat(count), color: color(for: mood))
                segments.append(segment)
            }
            
            // Update the donut chart on the main thread
            DispatchQueue.main.async {
                self.chartView.segments = segments
                self.chartView.setNeedsDisplay()
            }
        } catch {
            print("Failed to fetch mood entries: \(error)")
        }
    }
    
    private func color(for mood: String) -> UIColor {
        switch mood {
        case "😊": return .systemYellow
        case "😔": return .systemBlue
        case "😡": return .systemRed
        case "😐": return .systemMint
        default:
            return .systemGray2
        }
    }

    
    // MARK: - Fetch Moods
    private func fetchMoods() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        
        do {
            let entries = try context.fetch(request)
            let calendar = Calendar.current
            for entry in entries {
                if let timestamp = entry.timestamp, let mood = entry.mood {
                    let normalizedDate = calendar.startOfDay(for: timestamp)
                    moods[normalizedDate] = mood
                }
            }
            collectionView.reloadData()
        } catch {
            print("Failed to fetch mood entries: \(error)")
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MoodTrendController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    // 6 rows x 7 columns
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        42
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CalendarDayCell",
            for: indexPath
        ) as! CalendarDayCell
        
        let calendar = Calendar.current
        let startOfMonth = currentDate.startOfMonth()
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let day = indexPath.row - firstWeekday + 2
        
        if day > 0,
           let range = calendar.range(of: .day, in: .month, for: currentDate),
           day <= range.count {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let normalizedDate = calendar.startOfDay(for: date)
            cell.configure(with: moods[normalizedDate], day: day)
        } else {
            cell.configure(with: nil, day: nil)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoodTrendController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: width)
    }
}

// MARK: - CalendarDayCell
class CalendarDayCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let moodLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dayLabel)
        contentView.addSubview(moodLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        moodLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moodLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moodLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with mood: String?, day: Int?) {
        dayLabel.text = day.map { "\($0)" } ?? ""
        moodLabel.text = mood ?? ""
    }
}

// MARK: - TimeRange
enum TimeRange {
    case week, month, year
}

// MARK: - Date Extension
extension Date {
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
}
