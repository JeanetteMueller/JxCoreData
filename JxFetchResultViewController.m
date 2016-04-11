//
//  JxFetchResultViewController.m
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultViewController.h"
//#import "Logging.h"

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
    
}
- (void)viewDidDisappear:(BOOL)animated{
    LLog();

    [super viewDidDisappear:animated];
}
- (void)dealloc{
    self.managedObjectContext = nil;
}

#pragma mark - Fetched results controller
- (void)refetchData{
    LLog();
    NSError *error;
    
    @try {
        
        if (![self.fetchedResultsController performFetch:&error]) {
            NSLog(@"Error %@: %@", error, error.description);
        };
        
        //NSLog(@"fetchedObjects %@", self.fetchedResultsController.fetchedObjects);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@: %@", exception.name, exception.reason);
    }
    
}
- (NSFetchedResultsController *)fetchedResultsController{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    //DLog(@"self.entityName: %@", self.entityName);
    
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

    
    [fetchRequest setFetchBatchSize:25];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:self.sectionKeyPath
                                                                                                           cacheName:nil];
    
    
    

    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    
    NSLog(@"return _fetchedResultsController");
    return _fetchedResultsController;
}
@end
