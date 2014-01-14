//
//  JxFetchResultTableViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import "JxFetchResultTableViewController.h"
#import "Logging.h"

@interface JxFetchResultTableViewController ()

@end

@implementation JxFetchResultTableViewController

- (UITableView *)tableView{
    return (UITableView *)self.view;
}
- (void)viewDidLoad{
    _page = 1;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LLog();
    [self.tableView setScrollsToTop:YES];
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    LLog();
    [self.tableView setScrollsToTop:NO];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    LLog();
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    
    DLog(@"count %d", count);
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
        int oldLimit = self.fetchedResultsController.fetchRequest.fetchLimit;

        int loadedItemsCount = [self.fetchedResultsController.fetchedObjects count];
        
        if (loadedItemsCount == oldLimit) {
            

        
            int sectionCount = [tableView numberOfSections];
        
            int itemsInLastSection = 0;
            if (sectionCount > 0) {
                itemsInLastSection = [tableView numberOfRowsInSection:sectionCount-1];
            }
            
            
            [self.fetchedResultsController.fetchRequest setFetchLimit:oldLimit+[self.fetchLimit intValue]];
            [self refetchData];
            
            //int newLoadedItemsCount = [self.fetchedResultsController.fetchedObjects count];
            
            //if (newLoadedItemsCount > loadedItemsCount) {
            
            DLog(@"step 1");
            [self.tableView beginUpdates];
            
            int newItemsInLastSection = [self tableView:tableView numberOfRowsInSection:sectionCount-1];
            int newSectionCount = [self numberOfSectionsInTableView:tableView];
            
            
            
            if (itemsInLastSection < newItemsInLastSection) {
                
                int i = itemsInLastSection;
                NSMutableArray *insertPathes = [NSMutableArray array];
                
                while (i < newItemsInLastSection) {
                    [insertPathes addObject:[NSIndexPath indexPathForRow:i inSection:sectionCount-1]];
                    i++;
                }
                DLog(@"insertPathes %@", insertPathes);
                [self.tableView insertRowsAtIndexPaths:insertPathes withRowAnimation:UITableViewRowAnimationNone];
            }
            
            if (sectionCount < newSectionCount) {
                
                int s = sectionCount;
                NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
                while (s < newSectionCount) {
                    [insertSections addIndex:s];
                    s++;
                }
                DLog(@"insertSections %@", insertSections);
                [self.tableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationNone];
            }
            
            LLog();
            
            [self.tableView endUpdates];
            
        }else{
            DLog(@"step 2");
            _lastPageReached = YES;
            
            [self reachedLastElement];
        }

    }
    
    
}
- (void)reachedLastElement{
    LLog();
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    LLog();
    
    //NSLog(@"offset %f + height %f = %f", scrollView.contentOffset.y, scrollView.frame.size.height, scrollView.contentOffset.y+scrollView.frame.size.height);
    
    NSLog(@"size %f", scrollView.contentSize.height);
    
    
    if (scrollView.contentOffset.y+scrollView.frame.size.height > scrollView.contentSize.height-50 ) {
        [self pagingCellFor:(UITableView *)scrollView atIndexPath:nil];
    }
    
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LLog();
//    // Return NO if you do not want the specified item to be editable.
//    return NO;
//}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LLog();
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//        
//        
//        NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self.view);
//        UIMenuController* menuController = [UIMenuController sharedMenuController];
//
//        ///self.selectedIndex = indexPath.row;
//        [menuController setTargetRect:[tableView rectForRowAtIndexPath:indexPath] inView:tableView];
//
//        [menuController setMenuItems:@[
//                                       [[UIMenuItem alloc] initWithTitle:@"Play" action:@selector(playVideo:)],
//                                       [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(editVideo:)],
//                                       [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteVideo:)],
//                                       [[UIMenuItem alloc] initWithTitle:@"Share" action:@selector(shareVideo:)],
//                                       [[UIMenuItem alloc] initWithTitle:@"Cancel" action:@selector(cancelMenu:)]
//                                       ]];
//        
//        menuController.arrowDirection = UIMenuControllerArrowDefault;
//        
//        [menuController setMenuVisible:YES animated:NO];
//        
//        [tableView setEditing:NO animated:YES];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
//}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LLog();
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[DetailViewController alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */


}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleNone;
//}
//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}



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
    LLog();
    
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self unloadCell:cell atIndexPath:indexPath];
    
}
- (void)unloadCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    LLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:cell];
}

#pragma mark - Fetched results controller
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if ((self.navigationController == nil || [[self.navigationController visibleViewController] isEqual:self]) && self.dynamicUpdate) {
        LLog();
        [self.tableView beginUpdates];
    }

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    if ((self.navigationController == nil || [[self.navigationController visibleViewController] isEqual:self] ) && self.dynamicUpdate) {
        LLog();
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationRight];
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    if (( self.navigationController == nil || [[self.navigationController visibleViewController] isEqual:self]) && self.dynamicUpdate) {
        LLog();
        UITableView *tableView = self.tableView;
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                
                [self startCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    LLog();
    if (self.navigationController == nil || [[self.navigationController visibleViewController] isEqual:self]) {
        
        
        if (self.dynamicUpdate) {
            [self.tableView endUpdates];
        }else{
            [self.tableView reloadData];
        }
        
    }
}



@end
