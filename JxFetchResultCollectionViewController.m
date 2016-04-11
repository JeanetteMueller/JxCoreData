//
//  JxFetchResultCollectionViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultCollectionViewController.h"
#import "Logging.h"

@interface JxFetchResultCollectionViewController ()

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


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
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
//    //NSMutableDictionary *change = [NSMutableDictionary new];
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
//    //[_sectionChanges addObject:change];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
//    LLog();
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
////            NSLog(@"didChangeObject - insert");
//            
//            if (newIndexPath.section > self.collectionView.numberOfSections-1) {
//                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section]];
//            }
//            
//            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            NSLog(@"didChangeObject - delete");
//            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            NSLog(@"didChangeObject - update");
//
//            [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            NSLog(@"didChangeObject - move");
//            
//            if (indexPath.section == newIndexPath.section) {
//                [_collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
//                [_collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
//            }else{
//                [self.collectionView reloadData];
//            }
//            break;
//    }
//
//}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    LLog();
    
    //bei weiterne problemen könnte das helfen
    //[NSFetchedResultsController deleteCacheWithName:controller.cacheName];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    LLog();
    [self.collectionView reloadData];
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




- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    LLog();
    [_collectionView performBatchUpdates:nil completion:nil];
}
@end
