//
//  JxFetchResultTableViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultTableViewController.h"
//#import "Logging.h"

@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@end

@interface SVInfiniteScrollingView ()

@property (nonatomic, copy) void (^infiniteScrollingHandler)(void);

@end

static const int kLoadingCellTag = 257;


@interface JxFetchResultTableViewController ()

@property (nonatomic, assign) BOOL isCountingRows;
@property (nonatomic, assign) BOOL hasAddedPullToRefreshControl;

// Loading

- (void) _loadFirstPage;
- (void) _loadNextPage;

- (void) _loadFromPullToRefresh;

// Table View Cells & NSIndexPaths

- (UITableViewCell *) _cellForLoadingCell;
- (BOOL) _indexRepresentsLastSection:(NSInteger)section;
- (BOOL) _indexPathRepresentsLastRow:(NSIndexPath *)indexPath;
- (NSInteger) _totalNumberOfRows;
- (CGFloat) _cumulativeHeightForCellsAtIndexPaths:(NSArray *)indexPaths;

@end

@implementation JxFetchResultTableViewController

- (void) loadView {
    [super loadView];
    
    self.loadingView = [[JMStatefulTableViewLoadingView alloc] initWithFrame:self.tableView.bounds];
    self.loadingView.backgroundColor = [UIColor clearColor];
    self.errorView = [[JMStatefulTableViewErrorView alloc] initWithFrame:self.tableView.bounds];
    self.errorView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    
    self.hasAddedPullToRefreshControl = NO;
}

- (void)viewDidLoad{
    self.page = 1;
    
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated{
    LLog();
    [_tableView setScrollsToTop:NO];
    
    [super viewWillDisappear:animated];
}
- (void) viewDidUnload {
    [super viewDidUnload];
    
    self.loadingView = nil;
    self.errorView = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    
    __block __typeof(self)safeSelf = self;
    
    BOOL shouldPullToRefresh = YES;
    if([self.statefulDelegate respondsToSelector:@selector(statefulTableViewControllerShouldPullToRefresh:)]) {
        shouldPullToRefresh = [self.statefulDelegate statefulTableViewControllerShouldPullToRefresh:self];
    }
    
    if(!self.hasAddedPullToRefreshControl && shouldPullToRefresh) {
        if([self respondsToSelector:@selector(refreshControl)]) {
            //self.refreshControl = [[UIRefreshControl alloc] init];
            //[self.refreshControl addTarget:self action:@selector(_loadFromPullToRefresh) forControlEvents:UIControlEventValueChanged];
        } else {
            [self.tableView addPullToRefreshWithActionHandler:^{
                [safeSelf _loadFromPullToRefresh];
            }];
        }
        
        self.hasAddedPullToRefreshControl = YES;
    }
    
    BOOL shouldInfinitelyScroll = YES;
    if([self.statefulDelegate respondsToSelector:@selector(statefulTableViewControllerShouldInfinitelyScroll:)]) {
        shouldInfinitelyScroll = [self.statefulDelegate statefulTableViewControllerShouldInfinitelyScroll:self];
    }
    
    [self updateInfiniteScrollingHandlerAndFooterView:shouldInfinitelyScroll];
    
    
    
    [super viewWillAppear:animated];
    
    [self _loadFirstPage];
    
    if (!_tableView) {
        NSLog(@"\n\n\nWARNING: please connect your UITableView with the Interface Builder to this Controller\n\n\n");
    }
    
    [_tableView setScrollsToTop:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSArray *sections = [self.fetchedResultsController sections];
    NSInteger count = 0;
    
    if ([sections count] > section) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
    }
    
    DLog(@"count %ld", (long)count);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLog();
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    LLog();
    [self startCell:cell atIndexPath:indexPath];
    
    //[self pagingCellFor:tableView atIndexPath:indexPath];
    
}
- (void)pagingCellFor:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    LLog();
    
    if (!_lastPageReached) {
        DLog(@"DO IT");
        NSUInteger oldLimit = self.fetchedResultsController.fetchRequest.fetchLimit;

        NSUInteger loadedItemsCount = [self.fetchedResultsController.fetchedObjects count];
        
        if (loadedItemsCount == oldLimit) {
            

        
            NSInteger sectionCount = [tableView numberOfSections];
        
            NSInteger itemsInLastSection = 0;
            if (sectionCount > 0) {
                itemsInLastSection = [tableView numberOfRowsInSection:sectionCount-1];
            }
            
            
            [self.fetchedResultsController.fetchRequest setFetchLimit:oldLimit+[self.fetchLimit intValue]];
            [self refetchData];

            //int newLoadedItemsCount = [self.fetchedResultsController.fetchedObjects count];
            
            //if (newLoadedItemsCount > loadedItemsCount) {
            
            DLog(@"step 1");
            [tableView beginUpdates];
            
            NSInteger newItemsInLastSection = [self tableView:tableView numberOfRowsInSection:sectionCount-1];
            NSInteger newSectionCount = [self numberOfSectionsInTableView:tableView];
            
            
            
            if (itemsInLastSection < newItemsInLastSection) {
                
                NSInteger i = itemsInLastSection;
                NSMutableArray *insertPathes = [NSMutableArray array];
                
                while (i < newItemsInLastSection) {
                    [insertPathes addObject:[NSIndexPath indexPathForRow:i inSection:sectionCount-1]];
                    i++;
                }
                DLog(@"insertPathes %@", insertPathes);
                [tableView insertRowsAtIndexPaths:insertPathes withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (sectionCount < newSectionCount) {
                
                NSInteger s = sectionCount;
                NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
                while (s < newSectionCount) {
                    [insertSections addIndex:s];
                    s++;
                }
                DLog(@"insertSections %@", insertSections);
                [tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationNone];
            }
            
            LLog();
            
            [tableView endUpdates];
            
        
        }else{
            DLog(@"step 2");
            self.lastPageReached = YES;
            
            [self reachedLastElement];
        }

    }
    
    
}
- (void)reachedLastElement{
    LLog();
}
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    LLog();
//    
//    if ([scrollView isEqual:self.tableView]) {
//        
//        NSLog(@"size %f", scrollView.contentSize.height);
//        
//        
//        if (scrollView.contentOffset.y+scrollView.frame.size.height > scrollView.contentSize.height-50 ) {
//            [self pagingCellFor:(UITableView *)scrollView atIndexPath:nil];
//        }
//    }
//}



#pragma mark - Table view delegate


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Actions";
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return YES;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    LLog();

    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSLog(@"object id: %@", object.objectID);
    
    cell.textLabel.text = [object.objectID description];

}
- (void)startCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{

    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    [self unloadCell:cell];
    
}
- (void)unloadCell:(UITableViewCell *)cell{

    
    [[NSNotificationCenter defaultCenter] removeObserver:cell];
}

#pragma mark - Fetched results controller
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if ([[self.navigationController.viewControllers lastObject] isEqual:self] && self.dynamicUpdate) {

        [_tableView beginUpdates];
    }

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    
    if ([[self.navigationController.viewControllers lastObject] isEqual:self] && self.dynamicUpdate) {
        
        LLog();
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationMiddle];
                break;
                
            case NSFetchedResultsChangeDelete:
                
                
                
                [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationMiddle];
                break;
            default:
                
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if ([[self.navigationController.viewControllers lastObject] isEqual:self] && self.dynamicUpdate) {
        
        LLog();
        UITableView *tableView = _tableView;
        
        switch(type) {
            case NSFetchedResultsChangeInsert:{

                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }break;
                
            case NSFetchedResultsChangeDelete:{
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                [[NSNotificationCenter defaultCenter] removeObserver:cell];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }break;
                
            case NSFetchedResultsChangeUpdate:{
                
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                
                [[NSNotificationCenter defaultCenter] removeObserver:cell];
                
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                
                [self startCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }break;
                
            case NSFetchedResultsChangeMove:{
//                [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath ];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if ([[self.navigationController.viewControllers lastObject] isEqual:self] && self.dynamicUpdate) {
        
        [_tableView endUpdates];
    }else{
        [_tableView reloadData];
    }
        
    
}







//stateful table
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if ( self) {
        self.statefulState = JMStatefulTableViewControllerStateIdle;
        self.statefulDelegate = self;
    }
    return self;
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    self.statefulState = JMStatefulTableViewControllerStateIdle;
    self.statefulDelegate = self;
    
    return self;
}
- (void) dealloc {
    self.statefulDelegate = nil;
}

#pragma mark - Loading Methods

- (void) loadNewer {
    if([self _totalNumberOfRows] == 0) {
        [self _loadFirstPage];
    } else {
        [self _loadFromPullToRefresh];
    }
}

- (void) _loadFirstPage {
    if(self.statefulState == JMStatefulTableViewControllerStateInitialLoading || ([self _totalNumberOfRows] > 0 && self.fetchedResultsController.fetchedObjects.count > 0)) return;
    
    self.statefulState = JMStatefulTableViewControllerStateInitialLoading;
    
    [self.tableView reloadData];
    
    __weak __typeof(self)weakSelf = self;
    __strong __typeof(weakSelf)strongSelf = weakSelf;
    [self.statefulDelegate statefulTableViewControllerWillBeginInitialLoading:self completionBlock:^{
        
        [strongSelf.tableView reloadData]; // We have to call reloadData before we call _totalNumberOfRows otherwise the new count (after loading) won't be accurately reflected.
        
        if(([strongSelf _totalNumberOfRows] > 0 && strongSelf.fetchedResultsController.fetchedObjects.count > 0)) {
            strongSelf.statefulState = JMStatefulTableViewControllerStateIdle;
        } else {
            strongSelf.statefulState = JMStatefulTableViewControllerStateEmpty;
        }
    } failure:^(NSError *error) {
        strongSelf.statefulState = JMStatefulTableViewControllerError;
    }];
}
- (void) _loadNextPage {
    if(self.statefulState == JMStatefulTableViewControllerStateLoadingNextPage) return;
    
    if([self.statefulDelegate statefulTableViewControllerShouldBeginLoadingNextPage:self]) {
        self.tableView.showsInfiniteScrolling = YES;
        
        self.statefulState = JMStatefulTableViewControllerStateLoadingNextPage;
        
        [self.statefulDelegate statefulTableViewControllerWillBeginLoadingNextPage:self completionBlock:^{
            [self.tableView reloadData];
            
            if(![self.statefulDelegate statefulTableViewControllerShouldBeginLoadingNextPage:self]) {
                self.tableView.showsInfiniteScrolling = NO;
            };
            
            if(([self _totalNumberOfRows] > 0 && self.fetchedResultsController.fetchedObjects.count > 0)) {
                self.statefulState = JMStatefulTableViewControllerStateIdle;
            } else {
                self.statefulState = JMStatefulTableViewControllerStateEmpty;
            }
        } failure:^(NSError *error) {
            //TODO What should we do here?
            self.statefulState = JMStatefulTableViewControllerStateIdle;
        }];
    } else {
        self.tableView.showsInfiniteScrolling = NO;
    }
}

- (void) _loadFromPullToRefresh {
    if(self.statefulState == JMStatefulTableViewControllerStateLoadingFromPullToRefresh) return;
    
    self.statefulState = JMStatefulTableViewControllerStateLoadingFromPullToRefresh;
    
    [self.statefulDelegate statefulTableViewControllerWillBeginLoadingFromPullToRefresh:self completionBlock:^(NSArray *indexPaths) {
        if([indexPaths count] > 0) {
            CGFloat totalHeights = [self _cumulativeHeightForCellsAtIndexPaths:indexPaths];
            
            //Offset by the height of the pull to refresh view when it's expanded:
            CGFloat offset = 0.0f;
            
            if([self respondsToSelector:@selector(refreshControl)]) {
                //offset = self.refreshControl.frame.size.height;
            } else {
                offset = self.tableView.pullToRefreshView.frame.size.height;
            }
            
            [self.tableView setContentInset:UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f)];
            [self.tableView reloadData];
            
            if(self.tableView.contentOffset.y == 0) {
                self.tableView.contentOffset = CGPointMake(0, (self.tableView.contentOffset.y + totalHeights) - 60.0);
            } else {
                self.tableView.contentOffset = CGPointMake(0, (self.tableView.contentOffset.y + totalHeights));
            }
        }
        
        self.statefulState = JMStatefulTableViewControllerStateIdle;
        [self _pullToRefreshFinishedLoading];
    } failure:^(NSError *error) {
        //TODO: What should we do here?
        
        self.statefulState = JMStatefulTableViewControllerStateIdle;
        [self _pullToRefreshFinishedLoading];
    }];
}

#pragma mark - Table View Cells & NSIndexPaths

- (UITableViewCell *) _cellForLoadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.center;
    [cell addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    cell.tag = kLoadingCellTag;
    
    return cell;
}
- (BOOL) _indexRepresentsLastSection:(NSInteger)section {
    NSInteger totalNumberOfSections = [self numberOfSectionsInTableView:self.tableView];
    if(section != (totalNumberOfSections - 1)) return NO; //section is not the last section!
    
    return YES;
}
- (BOOL) _indexPathRepresentsLastRow:(NSIndexPath *)indexPath {
    NSInteger totalNumberOfSections = [self numberOfSectionsInTableView:self.tableView];
    if(indexPath.section != (totalNumberOfSections - 1)) return NO; //indexPath.section is not the last section!
    
    NSInteger totalNumberOfRowsInSection = [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
    if(indexPath.row != (totalNumberOfRowsInSection - 1)) return NO; //indexPath.row is not the last row in this section!
    
    return YES;
}
- (NSInteger) _totalNumberOfRows {
    self.isCountingRows = YES;
    
    NSInteger numberOfRows = 0;
    
    NSInteger numberOfSections = [self numberOfSectionsInTableView:self.tableView];
    for(NSInteger i = 0; i < numberOfSections; i++) {
        numberOfRows += [self tableView:self.tableView numberOfRowsInSection:i];
    }
    
    self.isCountingRows = NO;
    
    return numberOfRows;
}
- (CGFloat) _cumulativeHeightForCellsAtIndexPaths:(NSArray *)indexPaths {
    if(!indexPaths) return 0.0;
    
    CGFloat totalHeight = 0.0;
    
    for(NSIndexPath *indexPath in indexPaths) {
        totalHeight += [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    }
    
    return totalHeight;
}

- (void) _pullToRefreshFinishedLoading {
    [self.tableView.pullToRefreshView stopAnimating];
    if([self respondsToSelector:@selector(refreshControl)]) {
        //[self.refreshControl endRefreshing];
    }
}

#pragma mark - Setter Overrides

- (void) setStatefulState:(JMStatefulTableViewControllerState)statefulState {
    if([self.statefulDelegate respondsToSelector:@selector(statefulTableViewController:willTransitionToState:)]) {
        [self.statefulDelegate statefulTableViewController:self willTransitionToState:statefulState];
    }
    
    _statefulState = statefulState;
    
    switch (_statefulState) {
        case JMStatefulTableViewControllerStateIdle:
            [self.tableView.infiniteScrollingView stopAnimating];
            
            self.tableView.backgroundView = nil;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.tableView.scrollEnabled = YES;
            self.tableView.tableHeaderView.hidden = NO;
            self.tableView.tableFooterView.hidden = NO;
            [self.tableView reloadData];
            
            break;
            
        case JMStatefulTableViewControllerStateInitialLoading:
            self.tableView.backgroundView = self.loadingView;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.scrollEnabled = NO;
            self.tableView.tableHeaderView.hidden = YES;
            self.tableView.tableFooterView.hidden = YES;
            [self.tableView reloadData];
            
            break;
            
        case JMStatefulTableViewControllerStateEmpty:
            [self.tableView.infiniteScrollingView stopAnimating];
            
            self.tableView.backgroundView = nil;
//            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.scrollEnabled = YES;
            self.tableView.tableHeaderView.hidden = NO;
            self.tableView.tableFooterView.hidden = NO;
            [self.tableView reloadData];
            
        case JMStatefulTableViewControllerStateLoadingNextPage:
            // TODO
            break;
            
        case JMStatefulTableViewControllerStateLoadingFromPullToRefresh:
            // TODO
            break;
            
        case JMStatefulTableViewControllerError:
            [self.tableView.infiniteScrollingView stopAnimating];
            
            self.tableView.backgroundView = self.errorView;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.scrollEnabled = NO;
            self.tableView.tableHeaderView.hidden = YES;
            self.tableView.tableFooterView.hidden = YES;
            [self.tableView reloadData];
            break;
            
        default:
            break;
    }
    
    if([self.statefulDelegate respondsToSelector:@selector(statefulTableViewController:didTransitionToState:)]) {
        [self.statefulDelegate statefulTableViewController:self didTransitionToState:statefulState];
    }
}

#pragma mark - View Lifecycle
- (void) updateInfiniteScrollingHandlerAndFooterView:(BOOL)shouldInfinitelyScroll {
    if (shouldInfinitelyScroll) {
        if(self.tableView.infiniteScrollingView.infiniteScrollingHandler == nil) {
            __block __typeof(self)safeSelf = self;
            
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                [safeSelf _loadNextPage];
            }];
        }
    } else {
        self.tableView.infiniteScrollingView.infiniteScrollingHandler = nil;
        self.tableView.tableFooterView = nil;
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - JMStatefulTableViewControllerDelegate

- (void) statefulTableViewControllerWillBeginInitialLoading:(JxFetchResultTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"statefulTableViewControllerWillBeginInitialLoading:completionBlock:failure: is meant to be implementd by it's subclasses!");
}

- (void) statefulTableViewControllerWillBeginLoadingFromPullToRefresh:(JxFetchResultTableViewController *)vc completionBlock:(void (^)(NSArray *indexPathsToInsert))success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"statefulTableViewControllerWillBeginLoadingFromPullToRefresh:completionBlock:failure: is meant to be implementd by it's subclasses!");
}

- (void) statefulTableViewControllerWillBeginLoadingNextPage:(JxFetchResultTableViewController *)vc completionBlock:(void (^)())success failure:(void (^)(NSError *))failure {
    NSAssert(NO, @"statefulTableViewControllerWillBeginLoadingNextPage:completionBlock:failure: is meant to be implementd by it's subclasses!");
}
- (BOOL) statefulTableViewControllerShouldBeginLoadingNextPage:(JxFetchResultTableViewController *)vc {
    NSAssert(NO, @"statefulTableViewControllerShouldBeginLoadingNextPage is meant to be implementd by it's subclasses!");    
    
    return NO;
}
@end
