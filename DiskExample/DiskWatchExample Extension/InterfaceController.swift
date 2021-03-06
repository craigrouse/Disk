//
//  InterfaceController.swift
//  DiskWatchExample Extension
//
//  Created by Craig Rouse on 29/05/2019.
//  Copyright © 2019 Saoud Rizwan. All rights reserved.
//

import WatchKit
import Foundation
import Disk

class InterfaceController: WKInterfaceController {
    
    // MARK: Properties
    
    var posts = [Post]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: IBActions
    
    @IBAction func getJSONFromWeb() {
        getPostsFromWeb { posts in
            print("Posts retrieved from network request successfully!")
            self.posts = posts
        }
    }
    
    @IBAction func saveJSONToDisk() {
        // Disk is thorough when it comes to error handling, so make sure you understand why an error occurs when it does.
        do {
            try Disk.save(self.posts, to: .documents, as: "posts.json")
        } catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
        // Notice how we use a do, catch, try block when using Disk, this is because almost all of Disk's methods
        // are throwing functions, meaning they will throw an error if something goes wrong. In almost all cases, these
        // errors come with a lot of information like a description, failure reason, and recover suggestions.
        
        // You could alternatively use try! or try? instead of do, catch, try blocks
        // try? Disk.save(self.posts, to: .documents, as: "posts.json") // returns a discardable result of nil
        // try! Disk.save(self.posts, to: .documents, as: "posts.json") // will crash the app during runtime if this fails
        
        // You can also save files in folder hierarchies, for example:
        // try? Disk.save(self.posts, to: .caches, as: "Posts/MyCoolPosts/1.json")
        // This will automatically create the Posts and MyCoolPosts folders
        
        // If you want to save new data to a file location, you can treat the file as an array and simply append to it as well.
        let newPost = Post(userId: 0, id: self.posts.count + 1, title: "Appended Post", body: "...")
        try? Disk.append(newPost, to: "posts.json", in: .documents)
        
        print("Saved posts to disk!")
    }
    
    @IBAction func retrieveJSONFromDisk() {
        // We'll keep things simple here by using try?, but it's good practice to handle Disk with do, catch, try blocks
        // so you can make sure everything is going according to plan.
        do {
            let retrievedPosts = try Disk.retrieve("posts.json", from: .documents, as: [Post].self)
            // If you Option+Click 'retrievedPosts' above, you'll notice that its type is [Post]
            // Pretty neat, huh?
            
            var result: String = ""
            for post in retrievedPosts {
                result.append("\(post.id): \(post.title)\n\(post.body)\n\n")
            }
            
            let alert = WKAlertAction(title: "Disk Alert", style: .cancel) {
                
            }
            presentAlert(withTitle: "Disk Alert", message: result, preferredStyle: .actionSheet, actions: [alert])
            
            print("Retrieved posts from disk!")
        }
        catch DiskError.noFileFound {
            
            let alert = WKAlertAction(title: "Disk Alert", style: .cancel) {
                
            }
            presentAlert(withTitle: "Disk Error", message: "No file saved to disk yet!", preferredStyle: .actionSheet, actions: [alert])
            
            print ("No file found to retrieve posts from.")
        }
        catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
}
