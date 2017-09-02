//
//  JxFetchResultTableViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import <UIKit/UIKit.h>

#import "JxFetchResultViewController.h"
#import "SVPullToRefresh.h"
#import "JMStatefulTableViewLoadingView.h"
#import "JMStatefulTableViewEmptyView.h"
#import "JMStatefulTableViewErrorView.h"

typedef enum {
    JMStatefulTableViewControllerStateIdle = 0,
    JMStatefulTableViewControllerStateInitialLoading = 1,
    JMStatefulTableViewControllerStateLoadingFromPullToRefresh = 2,
    JMStatefulTableViewControllerStateLoadingNextPage = 3,
    JMStatefulTableViewControllerStateEmpty = 4,
    JMStatefulTableViewControllerError = 5,
} JMStatefulTableViewControllerState;

@class JxFetchResultTableViewController;

@protocol JMStatefulTableViewControllerDelegate <NSObject>

@required
- (void) statefulTableViewControllerWillBeginInitialLoading:(JxFetchResultTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void) statefulTableViewControllerWillBeginLoadingFromPullToRefresh:(JxFetchResultTableViewController *)vc completionBlock:(void (^)(NSArray *indexPathsToInsert))success failure:(void (^)(NSError *error))failure;

- (void) statefulTableViewControllerWillBeginLoadingNextPage:(JxFetchResultTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *error))failure;

- (BOOL) statefulTableViewControllerShouldBeginLoadingNextPage:(JxFetchResultTableViewController *)vc;

@optional
- (void) statefulTableViewController:(JxFetchResultTableViewController *)vc willTransitionToState:(JMStatefulTableViewControllerState)state;

- (void) statefulTableViewController:(JxFetchResultTableViewController *)vc didTransitionToState:(JMStatefulTableViewControllerState)state;

- (BOOL) statefulTableViewControllerShouldPullToRefresh:(JxFetchResultTableViewController *)vc;

- (BOOL) statefulTableViewControllerShouldInfinitelyScroll:(JxFetchResultTableViewController *)vc;

@end

@interface JxFetchResultTableViewController : JxFetchResultViewController <UITableViewDataSource, UITableViewDelegate, JMStatefulTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite) int page;
@property (nonatomic, readwrite) BOOL lastPageReached;
@property (nonatomic, readwrite) BOOL dynamicUpdate;
@property (strong, nonatomic) NSString *cellIdentifier;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)startCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)unloadCell:(UITableViewCell *)cell;

- (void)reachedLastElement;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;




//stateful table
@property (nonatomic) JMStatefulTableViewControllerState statefulState;

@property (strong, nonatomic) UIView *emptyView;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIView *errorView;

@property (nonatomic, unsafe_unretained) id <JMStatefulTableViewControllerDelegate> statefulDelegate;

- (void) loadNewer;

- (void) updateInfiniteScrollingHandlerAndFooterView:(BOOL)shouldInfinitelyScroll;

@end


