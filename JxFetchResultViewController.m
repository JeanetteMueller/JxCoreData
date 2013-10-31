//
//  JxFetchResultViewController.m
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultViewController.h"
#import "Logging.h"

@interface JxFetchResultViewController ()

@end

@implementation JxFetchResultViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //LLog();
    
    

    [self refetchData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //LLog();
}
- (void)viewWillDisappear:(BOOL)animated{
    //LLog();
    [super viewWillDisappear:animated];
}

#pragma mark - Fetched results controller

- (void)refetchData {
    LLog();
    [self.fetchedResultsController performFetch:nil];
}
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    LLog();
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    fetchRequest.resultType = NSManagedObjectResultType;
    
    if (self.predicate != nil) {
        [fetchRequest setPredicate:self.predicate];
    }
    
    if (self.sortDescriptors != nil) {
        fetchRequest.sortDescriptors = self.sortDescriptors;
    }
    
    fetchRequest.returnsObjectsAsFaults = NO;
    [fetchRequest setFetchLimit:[self.fetchLimit intValue]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:self.sectionKeyPath
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
//    NSError *error = nil;
//	if (![self.fetchedResultsController performFetch:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//	    abort();
//	}
    
    NSLog(@"return _fetchedResultsController");
    return _fetchedResultsController;
}
@end
