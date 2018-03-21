//
//  AllSurahViewController.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/20/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class AllSurahViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTextField: UITextField!
    
    
    var surah: [Surah] = []
    var filtered: [Surah] = []
    
    var searchKeyword: String = "" {
        didSet {
            filtered = surah.filter({ return $0.name.contains(searchKeyword) })
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        surah = DBHelper.shared.getAllSurah()
        initTableView()
    }

    
    
    
    //MARK: - IBActions
    @IBAction func menuAction() {
        self.openRight()
    }
    
    @IBAction func searchAction() {
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func searchTextChangeAction() {
        searchKeyword = searchTextField.text ?? ""
    }
}

//MARK: - table view
extension AllSurahViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchKeyword.isEmpty ? surah.count : filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurahTableViewCell
        cell.initWith(sura: searchKeyword.isEmpty ? surah[indexPath.row] : filtered[indexPath.row])
        return cell
    }
    
    
    /// init all surah table view for the first time
    func initTableView()  {
        tableView.register(UINib(nibName: "SurahTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
}
