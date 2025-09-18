//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Vanessa Wartemberg on 3/3/25.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Defines the Core Data stack and is responsible for managing the core data model (NSManagedObjectModel), the persistent store (the database) and the context (NSManagedObjectModel) (we use lazy because we only want to access this for the 1st time)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MoodModel")
        
        // loads the persistent store (the actual database) associated with the model
        container.loadPersistentStores{ storeDescription, error in
            // error handles any errors while loading the store
            if let error = error as NSError?{
                fatalError("Unresolved error\(error), \(error.userInfo)")
            }
        }
        return container; // after loading the store the container is returned and stored in the persistentContainer variable
    }()
    
    var window: UIWindow?
    
    //Mark: - Core Data Saving Support
    func saveContext () {
        // fetches the view context from the persistentContainer, which is the context that interacts with the UI
        let context = persistentContainer.viewContext
        
        if context.hasChanges { // if there has been chnages...
            do {
                try context.save() // then save...
            } catch {
                // else if an error occurs while saving the catch block prints the error and stops the app
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

