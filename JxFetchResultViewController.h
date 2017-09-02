//
//  JxFetchResultViewController.m
//
//  Created by Jeanette Müller on 16.08.13.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface JxFetchResultViewController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *sectionKeyPath;
@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) NSArray *sortDescriptors;
@property (strong, nonatomic) NSNumber *fetchLimit;

- (BOOL)refetchData;

@end
