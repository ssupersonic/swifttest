//
//  MainTableViewController.swift
//  SwiftTest
//
//  Created by Olexii Strilets on 12/19/18.
//  Copyright © 2018 supersonic. All rights reserved.
//

import UIKit

struct Hits: Codable {
    let hits: [Hit]
}

struct Hit: Codable {
    let createdAt, title: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case title
    }
}

let url = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page="

class MainTableViewController: UITableViewController {
    
    var postList = [Post]()
    var currentPage = 0
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        
        return text.isEmpty
    }
    
    private var filtredPosts = [Post]()
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the SearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //register custom UITableViewCell
        self.tableView.register(UINib.init(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        self.navigationItem.title = NSString(string: "0 - Selected posts") as String
        
        //create refreshControl
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        //load data from server
        receiveDataFor(page: 0)
    }
    
    @objc func refresh() {
        receiveDataFor(page: 0)
    }
    
    func receiveDataFor(page: Int) {
        //check url string
        guard let url = URL(string: "\(url)\(page)") else {
            return
        }
        
        //create URLSession with url
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            //check server response for error map data
            do {
                let hits = try JSONDecoder().decode(Hits.self, from: data)
                self.fillDate(hits: hits)
            } catch {
                print(error)
            }
            
            //need update tableView after receive response
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
            }.resume()
    }
    
    //fill Post model with server data
    func fillDate(hits: Hits) {
        for hit in hits.hits {
            let post = Post(title: hit.title, date: hit.createdAt, status: false)
            postList.append(post)
        }
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPosts.count
        }
        return self.postList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell")! as! CustomTableViewCell
        
        //get Post object by indexPath.row
        var post: Post
        
        if isFiltering {
            post = filtredPosts[indexPath.row]
        } else {
            post = postList[indexPath.row]
        }
        
        cell.titleLabel?.text = post.title
        cell.subtitleLabel?.text = post.date
        cell.simpleSwitch.isOn = post.status
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        //get Post object by indexPath.row
        let post = self.postList[indexPath.row]
        post.status = !post.status
        
        //update navigation title
        updatePostCountLabel()
        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.postList.count - 1 {
            currentPage += 1
            
            receiveDataFor(page: currentPage)
        }
    }
    
    func updatePostCountLabel() {
        //get objects with true status
        let filteredArray = self.postList.filter(){ $0.status == true }
        self.navigationItem.title = NSString(string: "\(filteredArray.count) - Selected posts") as String
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
    
        filtredPosts = postList.filter({ (post: Post) -> Bool in
            return post.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}
