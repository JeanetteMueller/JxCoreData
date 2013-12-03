//
//  JxCoreDataPredicateBuilder.m
//  autokauf
//
//  Created by Jeanette Müller on 13.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import "JxCoreDataPredicateBuilder.h"
#import "AKFilterViewController.h"

#import "Logging.h"



@interface JxCoreDataPredicateBuilder ()

@property (strong, nonatomic) NSDictionary *config;
@property (strong, nonatomic) NSMutableArray *dataFilter;
@property (strong, nonatomic) NSMutableDictionary *dataFiltervalues;

@end

@implementation JxCoreDataPredicateBuilder

#pragma mark init

+ (JxCoreDataPredicateBuilder *)sharedManager{
    static JxCoreDataPredicateBuilder *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance) return sharedInstance;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[JxCoreDataPredicateBuilder alloc] init];
    });
    
    return sharedInstance;
}
- (id)init{
    if ((self = [super init])) {
        LLog();
        
        _dataFilter = [NSMutableArray array];
        _dataFiltervalues = [NSMutableDictionary dictionary];
        
        [self loadPropertyConfig];
        
        [self loadFilter];
        
    }
    return self;
}
- (void)loadPropertyConfig{
    LLog();
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"CoreDataPredicateConfig.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"CoreDataPredicateConfig" ofType:@"plist"];
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    _config = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!_config)
    {
        DLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }else{
        
        //DLog(@"Config Load: %@", _config);
    }
    
}
#pragma mark Config
- (JxCoreDataPredicateConfig *)getConfigForKey:(NSString *)propKey{
    LLog();
    if (!_config) {
        [self loadPropertyConfig];
    }
    
    NSDictionary *dict = [_config objectForKey:propKey];
    
    JxCoreDataPredicateConfig *config = [[JxCoreDataPredicateConfig alloc] init];
    
    [config setValuesForKeysWithDictionary:dict];
    
    return config;
}
#pragma mark load/save Filters
- (void)loadFilter{
    LLog();
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"filter"] != nil) {
        _dataFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"filter"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"filtervalues"] != nil) {
        NSData *dataFilterValuesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"filtervalues"];
        if (dataFilterValuesData != nil && [dataFilterValuesData isKindOfClass:[NSData class]]) {
            _dataFiltervalues = [NSKeyedUnarchiver unarchiveObjectWithData:dataFilterValuesData];
        }
    }

    if (!_dataFilter) {
        _dataFilter = [NSMutableArray array];
    }
    
    if (!_dataFiltervalues) {
        _dataFiltervalues = [NSMutableDictionary dictionary];
    }
    
    
    NSLog(@"load filter %@", _dataFilter);
    NSLog(@"load values %@", _dataFiltervalues);
}
- (void)saveFilter{
    LLog();
    
    DLog(@"save filter %@", _dataFilter);
    DLog(@"save values %@", _dataFiltervalues);
    
    
    [[NSUserDefaults standardUserDefaults] setObject:_dataFilter forKey:@"filter"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataFiltervalues] forKey:@"filtervalues"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DLog(@"saved filter %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter"]);
    DLog(@"saved values %@", [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"filtervalues"]]);
}
#pragma mark Create Filter
- (void)resetFilter{
    LLog();
    
    _dataFilter = [NSMutableArray array];
    _dataFiltervalues = [NSMutableDictionary dictionary];
    [self saveFilter];
}
- (NSMutableArray *)filter{
    
    return _dataFilter;
}
- (NSMutableDictionary *)filtervalues{
    return _dataFiltervalues;
}
- (void)setFilter:(NSMutableArray *)newFilter{
    
    _dataFilter = newFilter;
    
    [self saveFilter];
}
- (void)addFilterType:(NSString *)filterType{
    
    [_dataFilter addObject:filterType];
    
    [self saveFilter];
}
- (void)addFilter:(id)newFilterValues forType:(NSString *)filterType{
    
    //DLog(@"typ %@\nvalues %@", filterType, newFilterValues);
    
    if (![_dataFilter containsObject:filterType]) {
        [_dataFilter addObject:filterType];
    }
    
    [_dataFiltervalues setObject:newFilterValues forKey:filterType];
    
    [self saveFilter];
}
- (void)removeFilterByType:(NSString *)filterType{
    
    //DLog(@"remove %@", filterType);
    
    [_dataFilter removeObject:filterType];
    [_dataFiltervalues removeObjectForKey:filterType];
    
    [self saveFilter];
}
- (JxCoreDataPredicateFilter *)getFilterValueFromFilter:(NSString *)filterName{
    return [_dataFiltervalues objectForKey:filterName];
}

#pragma mark Get Filter
- (NSPredicate *)getPredicate{
    LLog();
    NSString *predicateString = @"";
    
    for (NSString *filter in [_dataFiltervalues allKeys]) {
        NSLog(@"Filter: %@", filter);
        
        
        id filterv = [_dataFiltervalues objectForKey:filter];
        
        NSLog(@"filterv %@", filterv);
        
        if ([[filterv class] isSubclassOfClass:[JxCoreDataPredicateFilter class]]) {
            
            if ([filterv isKindOfClass:[JxCoreDataPredicateFilterContains class]]) {
                JxCoreDataPredicateFilterContains *filterObject = (JxCoreDataPredicateFilterContains *)filterv;
                
                if ([filterObject.exclude count] > 0) {
                    predicateString = [predicateString stringByAppendingFormat:@" AND ( "];
                    for (NSString *v in filterObject.exclude) {
                        predicateString = [predicateString stringByAppendingFormat:@" NOT ( %@ LIKE '%@' ) AND ", filter, v];
                    }
                    
                    predicateString = [predicateString substringToIndex:predicateString.length-4];
                    predicateString = [predicateString stringByAppendingFormat:@" ) "];
                    
                }else if ([filterObject.contains count] > 0) {
                    predicateString = [predicateString stringByAppendingFormat:@" AND ( "];
                    for (NSString *v in filterObject.contains) {
                        predicateString = [predicateString stringByAppendingFormat:@"%@ LIKE '%@' OR ", filter, v];
                    }
                    
                    predicateString = [predicateString substringToIndex:predicateString.length-3];
                    predicateString = [predicateString stringByAppendingFormat:@" ) "];
                    
                }
            }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterRange class]]) {
                
                JxCoreDataPredicateFilterRange *filterObject = (JxCoreDataPredicateFilterRange *)filterv;
                NSInteger from = [filterObject.from integerValue];
                NSInteger to = [filterObject.to integerValue];
                
                predicateString = [predicateString stringByAppendingFormat:@" AND ( %@ <= %d AND %@ >= %d ) ", filter, to, filter, from];
                
            }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterSmaller class]]){
                
                JxCoreDataPredicateFilterSmaller *filterObject = (JxCoreDataPredicateFilterSmaller *)filterv;
                NSInteger smaller = [filterObject.smaller integerValue];
                
                predicateString = [predicateString stringByAppendingFormat:@" AND ( %@ <= %d ) ", filter, smaller];
                
            }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterLarger class]]){
                
                JxCoreDataPredicateFilterLarger *filterObject = (JxCoreDataPredicateFilterLarger *)filterv;
                NSInteger larger = [filterObject.larger integerValue];
                
                predicateString = [predicateString stringByAppendingFormat:@" AND ( %@ >= %d ) ", filter, larger];
            }
        }
    }
    
    
    if (![predicateString isEqualToString:@""]) {
        predicateString = [predicateString substringFromIndex:4];
        if (![predicateString isEqualToString:@""]) {
            NSLog(@"\n\n\npredicateString: %@\n\n\n", predicateString);
        
            return [NSPredicate predicateWithFormat:predicateString];
        }
    }
    
    NSLog(@"return nil");
    return nil;
    
}



@end
