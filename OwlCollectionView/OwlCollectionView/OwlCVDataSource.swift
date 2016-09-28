//
//  OwlCVDataSource.swift
//  OwlCollectionView
//
//  Created by t4nhpt on 9/20/16.
//  Copyright © 2016 T4nhpt. All rights reserved.
//

import UIKit

let kHeaderData = "HeaderData"
let kItemData = "ItemData"
let kRowData = "RowData"
let kCoreData = "kCoreData"

enum DataInputType {
    case coreData
    case arrayOfData
    case dataArrayAndCoreData
}

class OwlCVDataSource: NSObject {
    var dataInputType:DataInputType = .arrayOfData
    var dataModelClass: AnyClass!
    var predicate: NSPredicate!
    var groupBy:String?
    var sortBy:String = ""
    var sortAscending = false
    var groupBySortAscending = false
    var fetchLimit = 0
    var fetchBatch = 0
    
    var data:[Any] = []
    
    class func dataSourceConfigWith(data:[Any]) -> OwlCVDataSource {
        let datasource = OwlCVDataSource()
        datasource.dataInputType = .arrayOfData
        datasource.data = data
        
        //WARNING
        var allNestedObjectsAreArrays = true
        for object in data {
            if !(object is NSArray) {
                if let object = object as? NSDictionary {
                    let rowData = object[kRowData]
                    if rowData is NSArray {
                        continue //Nested Row Data Array
                    } else if let rowData = rowData as? String, rowData == kCoreData {
                        continue //Core Data indicator
                    }
                }
                
                allNestedObjectsAreArrays = false //Allows for simple tables w/ one section to be represented without nesting e.g. @[@[<row data>]]
                break
            }
        }
        
        if data.count == 0 || !allNestedObjectsAreArrays {
            NSLog("WARNING: section data array does not have embedded arrays for row data")
            return self.dataSourceConfigWith(data: [data])
        }
        
        return datasource
    }
    
    class func datasourceConfig_dataClass(dataModelClass: AnyClass,
                                          predicate:NSPredicate,
                                          sortBy:String,
                                          sortAscending:Bool,
                                          groupBy:String?) -> OwlCVDataSource {
        let datasource = OwlCVDataSource()
        datasource.dataInputType = .coreData
        datasource.dataModelClass = dataModelClass
        datasource.predicate = predicate
        datasource.sortBy = sortBy
        datasource.sortAscending = sortAscending
        datasource.groupBy = groupBy
        
        return datasource
    }
    
    class func datasourceConfig_data(data:[Any],
                                     dataModelClass: AnyClass,
                                     predicate:NSPredicate,
                                     sortBy:String,
                                     sortAscending:Bool,
                                     groupBy:String?) -> OwlCVDataSource {
        return self.datasourceConfig_data(data: data,
                                          dataModelClass:dataModelClass,
                                          predicate:predicate,
                                          sortBy:sortBy,
                                          sortAscending:sortAscending,
                                          groupBy:groupBy,
                                          groupAscending:true)
    }
    
    class func datasourceConfig_data(data:[Any],
                                     dataModelClass: AnyClass,
                                     predicate:NSPredicate,
                                     sortBy:String,
                                     sortAscending:Bool,
                                     groupBy:String?,
                                     groupAscending:Bool) -> OwlCVDataSource {
        let datasource = OwlCVDataSource.dataSourceConfigWith(data: data)
        datasource.dataInputType = .dataArrayAndCoreData
        datasource.dataModelClass = dataModelClass
        datasource.predicate = predicate
        datasource.sortBy = sortBy
        datasource.sortAscending = sortAscending
        datasource.groupBy = groupBy
        datasource.groupBySortAscending = groupAscending
        return datasource
    }
}
