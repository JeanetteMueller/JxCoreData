//
//  JxFetchResultCollectionViewController.h
//
//  Created by Jeanette Müller on 16.08.13.
//

#import <UIKit/UIKit.h>

#import "JxFetchResultViewController.h"

@interface JxFetchResultCollectionViewController : JxFetchResultViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (UICollectionView *)collectionView;

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)unloadCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
