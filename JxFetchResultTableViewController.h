//
//  JxFetchResultTableViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import <UIKit/UIKit.h>

#import "JxFetchResultViewController.h"


@interface JxFetchResultTableViewController : JxFetchResultViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite) int page;
@property (nonatomic, readwrite) BOOL lastPageReached;
@property (nonatomic, readwrite) BOOL dynamicUpdate;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)startCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)unloadCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)reachedLastElement;

@end
