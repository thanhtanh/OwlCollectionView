# OwlCollectionView

Are you tired when you want to make data be synced between viewcontrollers? Such as you want:

- When you add an item, it will be added into list immediately
- When you delete/edit an item from CoreData, it will be deleted/edited in list
- When you change the value of one item, and want to reorder the items in list, it also do that for you, immediately

This library is written based on `NSFetchedResultsController`, to listen the `data changed` event from CoreData, then update data to UI for you. You will not have to implement `NSFetchedResultsControllerDelegate` by youself for every viewcontroller.

# How to use
## Configuration:
What you need is two classes `OwlCVDataSource` and `OwlCVDelegate`. So, copy them to anywhere in your project.
Because this library use `MagicalRecord`, so you should have `MagicalRecord` in your `Podfile`.

## Implementation
When you want to implement a `UICollectionView` in your project, you usually do steps like below:

- Add a `UICollectionView` to your storyboard. Assume that I name it `collectionView`
- Add a cell to your collection view.
- Prepare datasource data for you collection view
- Make your `viewcontroller` conform `UICollectionViewDelegate`, `UICollectionViewDataSource`

With `OwlCollectionView`, you just need to change some small things:

- Create collection view data source with `OwlCVDataSource`

        let dataSource = OwlCVDataSource.datasourceConfig_dataClass(dataModelClass: Owl.self, predicate: NSPredicate.init(value: true), sortBy: "height", sortAscending: true, groupBy: nil)
        // `Owl` is the model for entity in CoreData

- Create a subclass of `OwlCVDelegate` and implement any method of `UICollectionViewDelegate` and `UICollectionViewDataSource` as the normal way

        class OwlDel: OwlCVDelegate {
            var vc: ViewController!

            class func delegateForCV(grid:UICollectionView,
                withVC vc:ViewController,
                datasource:OwlCVDataSource) -> OwlDel {
                let delegate = OwlDel()

                delegate.vc = vc
                delegate.collectionView = grid

                grid.delegate = delegate
                grid.dataSource = delegate

                delegate.dataSource = datasource

                return delegate
            }

            override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let obj = self.dataObjectFor(item: nil, at: indexPath) as! Owl

                ....
                return item
            }

            override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

                return CGSize(width: 200, height: 50)
            }
        }

- Initial an `delegate` object for your collection view

        var del: OwlDel! // class variable
        // init with the dataSource we create above
        // `grid` is the collectionview we want to use
        self.del = OwlDel.delegateForCV(grid: self.grid, withVC:self, datasource:dataSource)

- Reload collectionview

        self.grid.reloadData()

# Example
Please take a look on my attached example to more clean what I said above.
Screenshot:

[![screenshot][1]][1]


[1]: http://i.stack.imgur.com/jgUSg.gif


Explain the screenshot:

- Requirement: A timer will add an `owl` after each 2 seconds with random height (the number at the end of each item). If the new owl with the height already existed in the list, it just been updated info (a random color) only. If height = 2, remove that existed owl. All owls in the list will be sorted by height.
- Solve: At you can see the example in project, I just add/update/delete new owl to CoreData, and don't care how UI update. It also update when you a view controller is not displayed to user.



