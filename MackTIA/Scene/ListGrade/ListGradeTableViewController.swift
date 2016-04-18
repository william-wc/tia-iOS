//
//  ListGradeViewController.swift
//  MackTIA
//
//  Created by Joaquim Pessoa Filho on 14/04/16.
//  Copyright (c) 2016 Mackenzie. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit

protocol ListGradeTableViewControllerInput {
    func displayFetchedGrades(viewModel: ListGradeViewModel)
}

protocol ListGradeTableViewControllerOutput {
    func fetchGrades(request: ListGradeRequest)
}

class ListGradeTableViewController: UITableViewController, ListGradeTableViewControllerInput {
    var output: ListGradeTableViewControllerOutput!
    var router: ListGradeRouter!
    var grades:[Grade] = []
    
    @IBOutlet weak var reloadButtonItem: UIBarButtonItem!
    
    // Interface Animation Parameters
    var selectedCellIndexPath:NSIndexPath?
    let selectedCellHeight:CGFloat = 293
    let unselectedCellHeight:CGFloat = 58
    let school31CellHeight:CGFloat = 80
    
    // MARK: Object lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ListGradeConfigurator.sharedInstance.configure(self)
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doSomethingOnLoad()
        configInterfaceAnimations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.selectedCellIndexPath != nil {
            self.tableView.deselectRowAtIndexPath(self.selectedCellIndexPath!, animated: false)
            self.selectedCellIndexPath = nil
        }
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    // MARK: Interface Animation
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func configInterfaceAnimations() {
        self.refreshControl?.addTarget(self, action: #selector(ListGradeTableViewController.handleRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    private func startReloadAnimation() {
        reloadButtonItem.enabled = false
    }
    
    private func stopReloadAnimation() {
        reloadButtonItem.enabled = true
        refreshControl?.endRefreshing()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        startReloadAnimation()
        let delayInSeconds = 1.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.fetchGrades()
        }
    }
    
    // MARK: Event handling
    
    private func fetchGrades() {
        startReloadAnimation()
        let request = ListGradeRequest()
        output.fetchGrades(request)
    }
    
    @IBAction func reloadData(sender: AnyObject) {
        fetchGrades()
    }
    
    func doSomethingOnLoad() {
        fetchGrades()
    }
    
    // MARK: Display logic
    
    func displayFetchedGrades(viewModel: ListGradeViewModel) {
        stopReloadAnimation()
        if viewModel.errorTitle != nil && viewModel.errorMessage != nil {
            let alert = UIAlertController(title: viewModel.errorTitle!, message: viewModel.errorMessage!, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        self.grades = viewModel.grades
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableView.reloadData()
        }
    }
}

extension ListGradeTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath != self.selectedCellIndexPath {
            self.selectedCellIndexPath = indexPath
        } else {
            if let _ = self.selectedCellIndexPath {
                self.tableView.deselectRowAtIndexPath(self.selectedCellIndexPath!, animated: true)
            }
            self.selectedCellIndexPath = nil
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.grades.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if grades[indexPath.row].schoolCode == "31" {
            let cell = tableView.dequeueReusableCellWithIdentifier("grade31SchoolCell")
            cell?.textLabel?.text = grades[indexPath.row].className
            cell?.detailTextLabel?.text = "Em desenvolvimento para escola FAU"
            return cell!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("gradeCell") as! ListGradeTableViewCell
        cell.config(grades[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if grades[indexPath.row].schoolCode == "31" {
            return self.school31CellHeight
        }
        
        if self.selectedCellIndexPath == indexPath {
            return self.selectedCellHeight
        }
        return self.unselectedCellHeight
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Remove seperator inset
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
}
