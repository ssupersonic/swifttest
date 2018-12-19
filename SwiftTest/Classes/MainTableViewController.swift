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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib.init(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        self.navigationItem.title = NSString(string: "0 - Selected posts") as String
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        receiveDataFor(page: 0)
    }
    
    @objc func refresh() {
        receiveDataFor(page: 0)
    }
    
    func receiveDataFor(page: Int) {
        guard let url = URL(string: "\(url)\(page)") else {
            return
        }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let hits = try JSONDecoder().decode(Hits.self, from: data)
                self.fillDate(hits: hits)
            } catch {
                print(error)
            }
            
            
            
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            
            }.resume()
    }
    
    func fillDate(hits: Hits) {
        for hit in hits.hits {
            let post = Post(title: hit.title, date: hit.createdAt, status: false)
            postList.append(post)
        }
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell")! as! CustomTableViewCell
        let post = self.postList[indexPath.row]
        
        cell.titleLabel?.text = post.title
        cell.subtitleLabel?.text = post.date
        cell.simpleSwitch.isOn = post.status
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let post = self.postList[indexPath.row]
        post.status = !post.status
        
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
        let filteredArray = self.postList.filter(){ $0.status == true }
        
        self.navigationItem.title = NSString(string: "\(filteredArray.count) - Selected posts") as String
    }
}
