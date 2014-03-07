//
//  JxCoreDataPredicateBuilder.h
//  autokauf
//
//  Created by Jeanette Müller on 13.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JxCoreDataPredicateFilters.h"
#import "JxCoreDataPredicateConfig.h"


#define kJxCoreDataPredicateDidChange @"jxCoreDataPredicateDidChange" 

@interface JxCoreDataPredicateBuilder : NSObject

#pragma mark init

+ (JxCoreDataPredicateBuilder *)sharedManager __deprecated_msg("Use Singleton with Namespace");
+ (JxCoreDataPredicateBuilder *)sharedManagerInNamespace:(NSString *)newNamespace;

#pragma mark Config
- (JxCoreDataPredicateConfig *)getConfigForKey:(NSString *)propKey;

#pragma mark Create Filter
- (void)resetFilter;
- (NSMutableArray *)filter;
- (NSMutableDictionary *)filtervalues;
- (void)setFilter:(NSMutableArray *)newFilter;
- (void)addFilterType:(NSString *)filterType;
- (void)addFilter:(id)newFilterValues forType:(NSString *)filterType;
- (void)removeFilterByType:(NSString *)filterType;
- (JxCoreDataPredicateFilter *)getFilterValueFromFilter:(NSString *)filterName;

#pragma mark Get Filter
- (NSPredicate *)getPredicate;
- (NSPredicate *)getPredicateUseSubquerys:(BOOL)useSubQuerys;



@end
