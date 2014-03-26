//
//  JxCoreDataPredicateFilters.h
//  autokauf
//
//  Created by Jeanette Müller on 13.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	// Apple NetworkStatus Compatible Names.
	JxCoreDataPredicateFilterKindInclude = 0,
	JxCoreDataPredicateFilterKindExclude = 1
} JxCoreDataPredicateFilterKind;


@interface JxCoreDataPredicateFilter : NSObject <NSCoding>

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSNumber *displayMultiplier;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSNumber *decimals;

- (id)initWithKey:(NSString *)key;

- (id)initWithKey:(NSString *)key
       multiplier:(NSNumber *)multiplier
            label:(NSString *)label
      andDecimals:(NSNumber *)decimals;

@end




@interface JxCoreDataPredicateFilterLarger : JxCoreDataPredicateFilter <NSCoding>

@property (strong, nonatomic) NSNumber *larger;

@end




@interface JxCoreDataPredicateFilterSmaller : JxCoreDataPredicateFilter <NSCoding>

@property (strong, nonatomic) NSNumber *smaller;

@end




@interface JxCoreDataPredicateFilterRange : JxCoreDataPredicateFilter

@property (strong, nonatomic) NSNumber *from;
@property (strong, nonatomic) NSNumber *to;

@end




@interface JxCoreDataPredicateFilterContains : JxCoreDataPredicateFilter

@property (strong, nonatomic) NSMutableArray *contains;
@property (strong, nonatomic) NSMutableArray *exclude;

@end



@interface JxCoreDataPredicateFilterBool : JxCoreDataPredicateFilter

@property (strong, nonatomic) NSNumber *yesOrNo;

@end
