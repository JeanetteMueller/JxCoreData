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
    LLog();
    
    

    if (self.isMovingToParentViewController == NO){
        //back buton pressed
        
    }else{
        //erster aufruf
        
        
    }
    
    [self refetchData];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    LLog();
}
- (void)viewWillDisappear:(BOOL)animated{
    //LLog();
    [super viewWillDisappear:animated];
}

#pragma mark - Fetched results controller

- (void)refetchData {
    LLog();
    NSError *error;
    
    @try {        
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Error %@: %@", error, error.description);
        };

    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@: %@", exception.name, exception.reason);
    }
  
}
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    DLog(@"self.entityName: %@", self.entityName);
    
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
    
    NSLog(@"fetchRequest %@", fetchRequest);
    NSLog(@"managedObjectContext %@", self.managedObjectContext);
    NSLog(@"sectionKeyPath %@", self.sectionKeyPath);
    LLog();
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:self.sectionKeyPath
                                                                                                           cacheName:nil];
    
    LLog();
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    LLog();
    
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
