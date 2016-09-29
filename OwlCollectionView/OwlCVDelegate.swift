//
//  OwlCVDelegate.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/20/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import UIKit
import MagicalRecord
import CoreData

class OwlCVDelegate: NSObject {
    var dataSource: OwlCVDataSource!
    var collectionView: UICollectionView!
    
    var numSections = 0
    fileprivate var objectChanges:[NSFetchedResultsChangeType: Any] = [:]
    fileprivate var sectionChanges:[NSFetchedResultsChangeType: Any] = [:]
    
    
    private var _fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject> {
        get {
            if let controller = self._fetchedResultsController {
                return controller
            } else {
                let fetchRequest = self.dataSource.dataModelClass.mr_requestAllSorted(by: self.dataSource.sortBy, ascending: self.dataSource.sortAscending, with: self.dataSource.predicate)
                
                if let groupBy = self.dataSource.groupBy, groupBy.characters.count > 0 {
                    let groupByDescriptor = NSSortDescriptor(key: groupBy, ascending: self.dataSource.groupBySortAscending)
                    
                    fetchRequest.sortDescriptors?.insert(groupByDescriptor, at: 0)
                }
                
                if self.dataSource.fetchLimit > 0 {
                    fetchRequest.fetchLimit = self.dataSource.fetchLimit
                    fetchRequest.fetchBatchSize = self.dataSource.fetchBatch
                }
                
                let xx = fetchRequest as! NSFetchRequest<NSManagedObject>
                
                let theFetchedResultsController:NSFetchedResultsController<NSManagedObject> = NSFetchedResultsController.init(fetchRequest: xx, managedObjectContext: NSManagedObjectContext.mr_default(), sectionNameKeyPath: self.dataSource.groupBy, cacheName: nil)
                
                self._fetchedResultsController = theFetchedResultsController
                self._fetchedResultsController!.delegate = self
                try? self._fetchedResultsController!.performFetch()
                return self.fetchedResultsController
            }
        }
    }
    
    func numberOfItemsInFetchedResultsSection(section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if sections.count <= section {
                return 0
            }
            
            let sectionInfo = sections[section]
            let num = sectionInfo.numberOfObjects
            
            return num
        }
        return 0
        
    }
    
    func dataObjectFor(item:Any?, at indexPath:IndexPath) -> Any? {
        
        var dataObject: Any? = nil
        
        //Retrieve Data Object For Item
        
        switch self.dataSource.dataInputType {
        case .coreData:
            dataObject = self.dataObjectForFetchedResults(at: indexPath)
        case .arrayOfData:
            if (item as? UICollectionReusableView) != nil {
                dataObject = self.headerDataFromDataArray(section: indexPath.section)
            } else {
                let rowData = self.rowDataFromDataArray(section: indexPath.section) as! NSArray //Find Row Data
                dataObject = self.dataObjectFor(rowData: rowData, row:indexPath.item)
            }
        case .dataArrayAndCoreData:
            let section = indexPath.section
            let dataArraySection = self.dataArraySectionForIndexPathSection(section: section)
            
            
            let rowData = self.rowDataFromDataArray(section: dataArraySection)
            
            if let rowData = rowData as? String, rowData == kCoreData {
                let coreDataIP = self.coreDataIndexPath(indexPath: indexPath)
                dataObject = self.dataObjectForFetchedResults(at: coreDataIP)
            } else if (rowData as? NSArray) != nil {
                if (item as? UICollectionReusableView) != nil {
                    dataObject = self.headerDataFromDataArray(section: indexPath.section)
                } else {
                    let rowData = self.rowDataFromDataArray(section: indexPath.section) as! NSArray //Find Row Data
                    dataObject = self.dataObjectFor(rowData: rowData, row:indexPath.item)
                }
            }
        }
        
        return dataObject
    }
    
    func dataObjectForFetchedResults(at indexPath:IndexPath) -> Any {
        var dataObject:Any
        dataObject = self.fetchedResultsController.object(at: indexPath)
        
        return dataObject
    }
    
    func headerDataFromDataArray(section:Int) -> Any? {
        
        if section < self.dataSource.data.count { //ERROR PROTECTION
            let sectionInfo = self.dataSource.data[section]
            let headerData: Any? //Find Header Data
            
            //If section info is a dictionary it may contain header data, if not no header exits
            if let sectionInfo = sectionInfo as? NSDictionary {
                headerData = sectionInfo[kHeaderData]
                return headerData
            }
        }
        
        return nil
    }
    
    func dataObjectFor(rowData:NSArray, row:Int) -> Any? {
        var dataObject:Any? = nil
        
        if row < rowData.count {
            dataObject = rowData[row]
        }
        
        return dataObject
    }
    
    func coreDataIndexPath(indexPath:IndexPath) -> IndexPath {
        var coreDataSection = indexPath.section - self.numDataArraySectionsBeforeCoreData()
        coreDataSection = (coreDataSection >= 0 ? coreDataSection : 0) //ERROR PROTECTION
        
        let coreDataIP = IndexPath(item: indexPath.item, section: coreDataSection)
        
        return coreDataIP
    }
}

extension OwlCVDelegate: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.dequeueCell(withIdentifier: "", cellClass: "", collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(inSection: section)
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return self.dequeueCell(withIdentifier: "", cellClass: "", collectionView: collectionView, indexPath: indexPath)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 1, height: 1)
    }
    
    func dequeueCell(withIdentifier cellIdentifier:String,
                     cellClass cellClassName:String,
                     collectionView:UICollectionView,
                     indexPath:IndexPath) -> UICollectionViewCell {
        var cellId = cellIdentifier
        if cellId == "" {
            cellId = "cellIdentifier"
        }
        
        if (cellClassName == "") {//IF not in storyboard
            collectionView.register(UICollectionView.self, forCellWithReuseIdentifier: cellId)
        }
        
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                      for:indexPath)
        
        return item
    }
    
    
    private func numberOfItems(inSection section:Int) -> Int {
        switch self.dataSource.dataInputType {
        case .coreData:
            let numRows = self.numberOfItemsInFetchedResultsSection(section: section)
            
            NSLog("%d Items in Section: %d found for Core Data Grid", numRows, section)
            return numRows
        case .arrayOfData:
            var numRows = 0
            let rowData = self.rowDataFromDataArray(section: section)
            if let rowData = rowData as? NSArray {
                numRows = rowData.count
            }
            
            return numRows
            
        case .dataArrayAndCoreData:
            //Determine if Section datasource is CoreData or DataArray
            let dataArraySection = self.dataArraySectionForIndexPathSection(section: section)
            
            
            let rowData = self.rowDataFromDataArray(section: dataArraySection)
            
            var numRows = 0
            if rowData is String &&
                (rowData as! String) == kCoreData {
                //CoreData
                var coreDataSection = section - self.numDataArraySectionsBeforeCoreData()
                coreDataSection = (coreDataSection >= 0 ? coreDataSection : 0) //ERROR PROTECTION
                numRows = self.numberOfItemsInFetchedResultsSection(section: coreDataSection)
                NSLog("%d Items in Core Data Section: %d Actual Section %d", numRows, coreDataSection, section)
            } else if let rowData = rowData as? NSArray {
                //Data Array
                numRows = rowData.count
            }
            return numRows
        }
    }
    
    func rowDataFromDataArray(section: Int) -> Any? {
        if section < self.dataSource.data.count { //ERROR PROTECTION
            let sectionInfo = self.dataSource.data[section]
            var rowData:Any? //Find Row Data
            
            if let sectionInfo = sectionInfo as? NSDictionary {
                rowData = sectionInfo.object(forKey: kRowData)
                
                //If section info is an array, it is effectively a sectioninfo dictionary with only the rowData key
            } else if sectionInfo is NSArray {
                rowData = sectionInfo
            }
            
            if !(rowData is NSArray) {
                return kCoreData
            }
            
            return rowData
        } else {
            return nil
        }
    }
    
    func dataArraySectionForIndexPathSection(section:Int) -> Int {
        let numSectionsBeforeCoreData = self.numDataArraySectionsBeforeCoreData()
        let numSectionsUpToAndIncludingCoreData = numSectionsBeforeCoreData + self.numberOfCoreDataSections()
        
        //Determine section in Data Array (all core data sections should be the same data array section)
        var dataArraySection = 0
        if section < numSectionsBeforeCoreData {
            dataArraySection = section
        } else if section >= numSectionsBeforeCoreData &&
            section < numSectionsUpToAndIncludingCoreData {
            dataArraySection = numSectionsBeforeCoreData //Core Data Section
        } else if (section >= numSectionsUpToAndIncludingCoreData) {
            //Handle case when data array specifies rows of data after core data sections
            dataArraySection = section - self.numberOfCoreDataSections() + 1 //Count all core data sections as 1
        }
        
        dataArraySection = (dataArraySection >= 0 ? dataArraySection : 0) //ERROR PROTECTION
        return dataArraySection
    }
    
    func numberOfCoreDataSections() -> Int {
        if let sections = self.fetchedResultsController.sections {
            let numSections = sections.count
            return numSections
        }
        return 0
    }
    
    func numDataArraySectionsBeforeCoreData() -> Int {
        var numSectionsBefore = 0
        let numSectionsTotal = self.numSections > 0 ? self.numSections : self.numberOfSections()
        for s in 0..<numSectionsTotal {
            let rowData = self.rowDataFromDataArray(section: s)
            if rowData is String &&
                (rowData as! String) == kCoreData {
                return numSectionsBefore
            }
            
            if rowData != nil {
                numSectionsBefore += 1
            }
        }
        
        return numSectionsBefore
    }
    
    func numberOfSections() -> Int {
        switch (self.dataSource.dataInputType) {
        case .coreData:
            
            self.numSections = self.numberOfCoreDataSections()
             NSLog("%d Sections found for Core Data Grid", self.numSections)
            return numSections
        case .arrayOfData:
            self.numSections =  self.dataSource.data.count
            return self.numSections
            
        case .dataArrayAndCoreData:
            //eDataArrayPlusCoreData currently assumes only one core data predicate per table
            let numDataArraySections = self.dataSource.data.count - 1 //-1 for core data ('data' array must include a section labeled core data)
            let numCoreDataSections = self.numberOfCoreDataSections()
            let numSections = numDataArraySections + numCoreDataSections
            NSLog("%d Sections found for Data Array Plus Core Data Grid", numSections)
            self.numSections = numSections
            return numSections
        }
    }
}

extension OwlCVDelegate : NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.objectChanges = [:]
        self.sectionChanges = [:]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //Reset sectionIndex to account for possible offset in Core Data (occurs when grid is DataArrayPlusCoreData type)
        NSLog("Section Index In Core Data: %d", sectionIndex)
        
        let indexPath = self.indexPathForCoreDataPath(coreDataIP: IndexPath(item: 0, section: sectionIndex))
        if let indexPath = indexPath {
            let newSectionIndex = indexPath.section
            NSLog("Section Index In Actual Table: %d", sectionIndex)
            
            if type == .insert || type == .delete {
                if let changeSet = self.sectionChanges[type] as? NSMutableIndexSet {
                    changeSet.add(newSectionIndex)
                    //                [changeSet addIndex:newSectionIndex]
                } else {
                    self.sectionChanges[type] = NSMutableIndexSet(index: newSectionIndex)
                }
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //Reset Index Paths to account for possible offset in Core Data IP (occurs when grid is DataArrayPlusCoreData type)
        NSLog("Section Index In Core Data: %d", indexPath?.section ?? -1)
        NSLog("New Section Index In Core Data: %d", newIndexPath?.section ?? -1)
        let oldIP = self.indexPathForCoreDataPath(coreDataIP: indexPath)
        let newIP = self.indexPathForCoreDataPath(coreDataIP: newIndexPath)
        NSLog("Section Index In Actual Table: %d", indexPath?.section ?? -1)
        NSLog("New Section Index In Actual Table: %d", newIndexPath?.section ?? -1)
        
        var changeSet = self.objectChanges[type] as? [Any]
        if changeSet == nil {
            changeSet = []
            self.objectChanges[type] = changeSet
        }
        
        if var changeSet = self.objectChanges[type] as? [Any] {
            switch(type) {
            case .insert:
                changeSet.append(newIP)
                break
            case .delete:
                changeSet.append(oldIP)
                break
            case .update:
                changeSet.append(oldIP)
                break
            case .move:
                changeSet.append((old:oldIP, new:newIP))
                break
            }
            
            self.objectChanges[type] = changeSet
        } else {
            self.objectChanges[type] = [:]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        var moves:NSMutableArray = []
        if let temp = self.objectChanges[.move] as? NSMutableArray {
            moves = temp
        }
        
        if (moves.count > 0) {
            var updatedMoves:[AnyObject] = []
            
            let insertSections = self.sectionChanges[.insert] as? NSMutableIndexSet ?? NSMutableIndexSet()
            let deleteSections = self.sectionChanges[.delete] as? NSMutableIndexSet ?? NSMutableIndexSet()
            for move in moves {
                let fromIP = (move as! NSArray)[0] as! IndexPath
                let toIP = (move as! NSArray)[1] as! IndexPath
                
                if deleteSections.contains(fromIP.section) {
                    if !insertSections.contains(toIP.section) {
                        if var changeSet = self.objectChanges[.insert] as? [AnyObject] {
                            changeSet.append(toIP as AnyObject)
                        } else {
                            let changeSet = [toIP]
                            self.objectChanges[.insert] = changeSet
                        }
                    }
                } else if insertSections.contains(toIP.section) {
                    if var changeSet = self.objectChanges[.delete] as? [AnyObject] {
                        changeSet.append(fromIP as AnyObject)
                    } else {
                        let changeSet = [fromIP]
                        self.objectChanges[.delete] = changeSet
                    }
                } else {
                    updatedMoves.append(move as AnyObject)
                }
            }
            
            if (updatedMoves.count > 0) {
                self.objectChanges[.move] = updatedMoves
            } else {
                self.objectChanges.removeValue(forKey: .move)
            }
        }
        
        if let deletes = self.objectChanges[.delete] as? NSArray, deletes.count > 0 {
            let deletedSections = self.sectionChanges[.delete] as? NSMutableIndexSet
            deletes.filtered(using: NSPredicate.init(block: { (evaluatedObject, bindings) -> Bool in
                if let deletedSections = deletedSections {
                    let ip = evaluatedObject as! IndexPath
                    return !deletedSections.contains(ip.section)
                } else {
                    return false
                }
            }))
        }
        
        if let inserts = self.objectChanges[.insert] as? NSArray, inserts.count > 0 {
            let insertedSections = self.sectionChanges[.insert] as? NSMutableIndexSet
            
            inserts.filtered(using: NSPredicate.init(block: { (evaluatedObject, bindings) -> Bool in
                let ip = evaluatedObject as! IndexPath
                if let insertedSections = insertedSections {
                    return !insertedSections.contains(ip.section)
                } else {
                    return false
                }
            }))
        }
        
        var movedItems = self.objectChanges[.move] as? [(old:IndexPath, new:IndexPath)]
        
        let collectionView = self.collectionView!
        
        
        collectionView.performBatchUpdates({ [unowned self] in
            if let deletedSections = self.sectionChanges[.delete] as? IndexSet, deletedSections.count > 0 {
                collectionView.deleteSections(deletedSections)
            }
            
            if let insertedSections = self.sectionChanges[.insert] as? IndexSet, insertedSections.count > 0 {
                collectionView.insertSections(insertedSections)
            }
            
            if let deletedItems = self.objectChanges[.delete] as? [IndexPath], deletedItems.count > 0 {
                for path in deletedItems {
                    NSLog("Deleting Item at Index Path: S:%d R:%d",
                          path.section,
                          path.item)
                    var row = path.row
                    row = row + 1 //Remove Unused Var Warning
                    
                }
                collectionView.deleteItems(at: deletedItems)
            }
            
            if let insertedItems = self.objectChanges[.insert] as? [IndexPath], insertedItems.count > 0 {
                for path in insertedItems {
                     NSLog("Inserting Item at Index Path: S:%d R:%d", path.section, path.item)
                    var row = path.row
                    row = row + 1 //Remove Unused Var Warning
                }
                collectionView.insertItems(at: insertedItems)
            }
            
            if let reloadItems = self.objectChanges[.update] as? [IndexPath], reloadItems.count > 0 {
                for path in reloadItems {
                    NSLog("Reloading Item at Index Path: S:%d R:%d", path.section, path.item)
                    var row = path.row
                    row = row + 1 //Remove Unused Var Warning
                }
                collectionView.reloadItems(at: reloadItems)
            }
            
            if let moveItems = self.objectChanges[.move] as? [(old:IndexPath, new:IndexPath)] {
                for paths in moveItems {
                    NSLog("Moving Item at Index Path: S:%d R:%d to Index Path: S:%d R:%d",
                          paths.old.section,
                          paths.old.item,
                          paths.new.section,
                          paths.new.item)
                    collectionView.moveItem(at: paths.old, to:paths.new)
                }
            }
            
        }) { finished in
            if (finished) {
                
                if let movedItems = movedItems, movedItems.count > 0 {
                    var reloadPaths:[IndexPath] = []
                    for paths in movedItems {
                        let path = paths.new
                        NSLog("Reloading Moved Item at Index Path: S:%d R:%d", path.section, path.item)
                        reloadPaths.append(path)
                    }
                    collectionView.reloadItems(at: reloadPaths)
                    
                    
                    
                }
                movedItems = []
            }
        }
        
        self.objectChanges = [:]
        self.sectionChanges = [:]
    }
    
    func indexPathForCoreDataPath(coreDataIP: IndexPath?) -> IndexPath? {
        if let coreDataIP = coreDataIP {
            let actualSection = coreDataIP.section + self.numDataArraySectionsBeforeCoreData()
            let actualIP = IndexPath(item:coreDataIP.item, section:actualSection)
            return actualIP
        }
        return nil
    }
    
}














