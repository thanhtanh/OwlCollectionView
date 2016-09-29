//
//  ViewController.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/20/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import UIKit
import MagicalRecord

class ViewController: UIViewController {
    @IBOutlet weak var grid:UICollectionView!
    
    var del: OwlDel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupGrid()
        self.setupData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGrid() {
//        let dataSource = OwlCVDataSource.datasourceConfig_dataClass(dataModelClass: Owl.self, predicate: NSPredicate.init(value: true), sortBy: "height", sortAscending: true, groupBy: nil)
        
//        let dataSource = OwlCVDataSource.dataSourceConfigWith(data: [1, 2, 3])
        
        let data = [
            [kHeaderData : ["1", "2", "3"],
            kRowData : kCoreData]
        ]
        
        let dataSource = OwlCVDataSource.datasourceConfig_data(data: data, dataModelClass: Owl.self, predicate: NSPredicate.init(value: true), sortBy: "height", sortAscending: true, groupBy: nil)
        
        self.del = OwlDel.delegateForCV(grid: self.grid, withVC:self, datasource:dataSource)
        
//        if self.grid.delegate.respondsToSelector:#selector(setFetchedResultsController:) {
//            self.grid.delegate.performSelector(#selector(setFetchedResultsController:), withObject:nil)
            self.grid.reloadData()
//        }
    }
    
    func setupData() {
        Owl.mr_deleteAll(matching: NSPredicate(value:true))
        Timer.scheduledTimer(timeInterval: 2.0,
                                             target:self,
                                             selector:#selector(createOwl),
                                             userInfo:nil,
                                             repeats:true)
    }
    
    func createOwl() {
        let randNum = Int(arc4random_uniform(6) + 1)
        let height = NSNumber(integerLiteral: randNum)
        let predicate = NSPredicate(format:"height == %@", height)
        
        var isNewEntity = false
        
        var owl = Owl.mr_findFirst(with: predicate)
        if (owl == nil) {
            owl = Owl.mr_createEntity()
            isNewEntity = true
        }
        
        if height == 2 && !isNewEntity {
            owl?.mr_deleteEntity()
        } else {
            let color = UIColor.generateRandomColorHexString()
            owl!.height = height
            owl!.name = color
            owl!.color = color
        }
        
        self.saveToDisk()
    }
    
    
    func context() -> NSManagedObjectContext {
        return NSManagedObjectContext.mr_default()
    }
    
    func saveToDisk() {
        self.context().mr_saveToPersistentStore() {(success, error) in
            
            if success {
                print("COMPLETED SAVE")
            } else if (error != nil) {
                print("Error saving context: %@", error)
            }
        }
    }
}

