# OwlCollectionView

Are you tired when you want to make data be synced between viewcontroller. Such as you want:
- When you add an item, it will be added into list immediately
- When you delete/edit an item from CoreData, it will be deleted/edited in list
- When you change the value of one item, and want to reorder the items in list, it also do that for you, immediately

This library is written based on `NSFetchedResultsController`, to listen the `data changed` event from CoreData, then update data to UI for you. You will not have to implement `NSFetchedResultsControllerDelegate` by youself for every viewcontroller.

# How to use

# Example
