//
//  JxFetchResultCollectionViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultCollectionViewController.h"
#import "Logging.h"

@interface JxFetchResultCollectionViewController ()

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation JxFetchResultCollectionViewController{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LLog();
    
    
    if (!_collectionView) {
        NSLog(@"\n\n\nWARNING: please connect your UICollectionView with the Interface Builder to your View\n\n\n");
    }
    
    [_collectionView setScrollsToTop:YES];
    

}
- (void)viewWillDisappear:(BOOL)animated{
    
    [_collectionView setScrollsToTop:NO];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    
    [super viewWillDisappear:animated];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    LLog();
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    LLog();
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    
    DLog(@"count %d", count);
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LLog();
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self unloadCell:cell atIndexPath:indexPath];
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    LLog();
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    NSLog(@"object id: %@", object.objectID);
    
    
}
- (void)unloadCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    LLog();
    //do something like remove observers
    
    [[NSNotificationCenter defaultCenter] removeObserver:cell];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    LLog();
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    LLog();
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    LLog();
    if ([_sectionChanges count] > 0)
    {
        [_collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [_collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || _collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [_collectionView reloadData];
            
        } else {
            
            [_collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [_collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [_collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [_collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [_collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    LLog();
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([_collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([_collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}


//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    LLog();
//    [_collectionView reloadData];
//}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    LLog();
    [_collectionView performBatchUpdates:nil completion:nil];
}
@end
