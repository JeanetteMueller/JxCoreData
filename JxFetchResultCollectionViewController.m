//
//  JxFetchResultCollectionViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultCollectionViewController.h"
#import "Logging.h"

@interface JxFetchResultCollectionViewController ()

@property (assign, nonatomic) BOOL shouldReloadCollectionView;
@property (strong, nonatomic) NSBlockOperation *blockOperation;

@property (strong, nonatomic) NSMutableArray *objectChanges;
@property (strong, nonatomic) NSMutableArray *sectionChanges;
- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation JxFetchResultCollectionViewController{
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.objectChanges = [NSMutableArray array];
    self.sectionChanges = [NSMutableArray array];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LLog();
    
    
    if (!_collectionView) {
        NSLog(@"\n\n\nWARNING: please connect your UICollectionView with the Interface Builder to this Controller\n\n\n");
    }
    
    [_collectionView setScrollsToTop:YES];
    

}
- (void)viewWillDisappear:(BOOL)animated{
    
    [_collectionView setScrollsToTop:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [super viewWillDisappear:animated];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    [collectionView.collectionViewLayout invalidateLayout];
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    
    DLog(@"count %ld", (long)count);
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self unloadCell:cell];
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    LLog();
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    NSLog(@"object id: %@", object.objectID);
    
    
}
- (void)unloadCell:(UICollectionViewCell *)cell{
    LLog();
    //do something like remove observers
    
    [[NSNotificationCenter defaultCenter] removeObserver:cell];
}



//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)section InfoatIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
//    LLog();
//    if ([[self.navigationController.viewControllers lastObject] isEqual:self]){
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            //change[@(type)] = @(sectionIndex);
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            //change[@(type)] = @(sectionIndex);
//            break;
//        default:
//            break;
//    }
//    
//    }
//}

//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
//    LLog();
//    if ([[self.navigationController.viewControllers lastObject] isEqual:self]){
//        switch(type) {
//                
//            case NSFetchedResultsChangeInsert:
//                if (newIndexPath.section > self.collectionView.numberOfSections-1) {
//                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
//                }
//                
//                [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//                break;
//                
//            case NSFetchedResultsChangeDelete:
//                NSLog(@"didChangeObject - delete");
//                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//                break;
//                
//            case NSFetchedResultsChangeUpdate:
//                NSLog(@"didChangeObject - update");
//
//                [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
//                break;
//                
//            case NSFetchedResultsChangeMove:
//                NSLog(@"didChangeObject - move");
//                
//                [_collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
//                
////            if (indexPath.section == newIndexPath.section) {
////                [_collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
////                [_collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
////            }else{
////                [self.collectionView reloadData];
////            }
//                break;
//        }
//    }
//}
//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
//    LLog();
//    
//    //bei weiterne problemen könnte das helfen
//    //[NSFetchedResultsController deleteCacheWithName:controller.cacheName];
//}
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
//    LLog();
//    //[self.collectionView reloadData];
//}

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




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    LLog();
    [_collectionView performBatchUpdates:nil completion:nil];
}









- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//#warning provisorisch auf YES gesetzt da update nicht richtig klappen wollte
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > indexPath.section && [self.collectionView numberOfSections] > newIndexPath.section) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            
//                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                if ([self.collectionView numberOfSections] > newIndexPath.section) {
                    if ([self.collectionView numberOfItemsInSection:newIndexPath.section] == 0) {
                        self.shouldReloadCollectionView = YES;
                    } else {
                        [self.blockOperation addExecutionBlock:^{
                            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                        }];
                    }
                }else {
                    self.shouldReloadCollectionView = YES;
                }
               
            
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    if (self.shouldReloadCollectionView) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}
@end
