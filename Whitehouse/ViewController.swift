//
//  ViewController.swift
//  Whitehouse
//
//  Created by user163948 on 4/9/20.
//  Copyright © 2020 lecosas. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var filteresPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            //urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            //urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
            } else {
                showError()
            }
        } else {
            showError()
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
               
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showFilterText))
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showFilterText() {
        let ac = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let action = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] action in
            guard let text = ac?.textFields?[0].text else { return }
            self?.filterPetitions(expression: text)
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    func filterPetitions(expression: String) {
        /*filteresPetitions = petitions.filter { (petition) -> Bool in
            return petition.body.localizedCaseInsensitiveContains(expression) || petition.title.localizedCaseInsensitiveContains(expression)
        }*/
        filteresPetitions = petitions.filter { $0.body.localizedCaseInsensitiveContains(expression) || $0.title.localizedCaseInsensitiveContains(expression)
        }
        tableView.reloadData()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteresPetitions = petitions
            tableView.reloadData()
            return
        }
        
        showError()
    }

    func showError() {
        let ac = UIAlertController(title: "Error", message:  "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteresPetitions.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteresPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteresPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
}

