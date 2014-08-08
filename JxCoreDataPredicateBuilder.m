//
//  JxCoreDataPredicateBuilder.m
//  autokauf
//
//  Created by Jeanette Müller on 13.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import "JxCoreDataPredicateBuilder.h"
#import "Logging.h"



@interface JxCoreDataPredicateBuilder ()

@property (strong, nonatomic) NSString *namespace;

@property (strong, nonatomic) NSDictionary *config;
@property (strong, nonatomic) NSMutableArray *dataFilter;
@property (strong, nonatomic) NSMutableDictionary *dataFiltervalues;


@end

@implementation JxCoreDataPredicateBuilder

#pragma mark init

+ (JxCoreDataPredicateBuilder *)sharedManager __deprecated_msg("Use Singleton with Namespace"){
    
    return [self sharedManagerInNamespace:@""];
}
+ (JxCoreDataPredicateBuilder *)sharedManagerInNamespace:(NSString *)newNamespace{
    static JxCoreDataPredicateBuilder *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (sharedInstance){
        
        [sharedInstance loadNamespace:newNamespace];
        
        return sharedInstance;
    }
    
    dispatch_once(&pred, ^{
        sharedInstance = [[JxCoreDataPredicateBuilder alloc] init];
    });
    
    [sharedInstance loadNamespace:newNamespace];
    
    return sharedInstance;
}
- (id)init{
    self = [super init];
    if (self) {
        [self loadPropertyConfig];
    }
    return self;
}
- (void)loadNamespace:(NSString *)namespace{

    DLog(@"namespace: %@", namespace);
    
    if (![_namespace isEqualToString:namespace]) {
        _namespace = namespace;
        _dataFilter = [NSMutableArray array];
        _dataFiltervalues = [NSMutableDictionary dictionary];
        
        [self loadFilter];
    }
}
- (void)loadPropertyConfig{
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
        DLog(@"Error reading plist: %@, format: %u", errorDesc, format);
    }else{
        
        //DLog(@"Config Load: %@", _config);
    }
    
}
#pragma mark Config
- (JxCoreDataPredicateConfig *)getConfigForKey:(NSString *)propKey{
    //DLog(@"propKey %@", propKey);
    if (!_config) {
        [self loadPropertyConfig];
    }
    
    NSDictionary *dict = [_config objectForKey:propKey];
    
    JxCoreDataPredicateConfig *config = [[JxCoreDataPredicateConfig alloc] init];
    config.filterKey = propKey;
    [config setValuesForKeysWithDictionary:dict];
    
    return config;
}
#pragma mark load/save Filters
- (void)loadFilter{
    DLog(@"namespace: %@", _namespace);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"filter%@", _namespace]] != nil) {
        _dataFilter = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"filter%@", _namespace]]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"filtervalues%@", _namespace]] != nil) {
        NSData *dataFilterValuesData = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"filtervalues%@", _namespace]];
        if (dataFilterValuesData != nil && [dataFilterValuesData isKindOfClass:[NSData class]]) {
            _dataFiltervalues = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:dataFilterValuesData]];
        }
    }

    if (!_dataFilter || [_dataFilter isKindOfClass:[NSNull class]]) {
        _dataFilter = [NSMutableArray array];
    }
    
    if (!_dataFiltervalues || [_dataFiltervalues isKindOfClass:[NSNull class]]) {
        _dataFiltervalues = [NSMutableDictionary dictionary];
    }
    
    
//    NSLog(@"load filter %@", _dataFilter);
//    NSLog(@"load values %@", _dataFiltervalues);
}
- (void)saveFilter{
    LLog();
    
//    NSLog(@"save filter %@", _dataFilter);
//    NSLog(@"save values %@", _dataFiltervalues);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:_dataFilter forKey:[NSString stringWithFormat:@"filter%@", _namespace]];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_dataFiltervalues] forKey:[NSString stringWithFormat:@"filtervalues%@", _namespace]];
    
    [defaults synchronize];
    
    NSLog(@"saved filter %@", [defaults objectForKey:[NSString stringWithFormat:@"filter%@", _namespace]]);
    NSLog(@"saved values %@", [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:[NSString stringWithFormat:@"filtervalues%@", _namespace]]]);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kJxCoreDataPredicateDidChange object:nil];
}
#pragma mark Create Filter
- (void)resetFilterAllNamespaces{
    LLog();
    
    _dataFilter = [NSMutableArray array];
    _dataFiltervalues = [NSMutableDictionary dictionary];
    [self saveFilter];
}
- (void)resetFilter{
    [self resetFilterSilent:NO];
}
- (void)resetFilterSilent:(BOOL)silent{
    DLog(@"silent %d", silent);
    
    [_dataFilter removeAllObjects];
    [_dataFiltervalues removeAllObjects];
    
    if (!silent) {
        [self saveFilter];
    }
    
}
- (NSMutableArray *)filter{
    
    return _dataFilter;
}
- (NSMutableDictionary *)filtervalues{
    return _dataFiltervalues;
}
- (void)addFilterType:(NSString *)filterType{
    
    [_dataFilter addObject:filterType];
    
    [self saveFilter];
}
- (void)addFilter:(id)newFilterValues forType:(NSString *)filterType{
    
    DLog(@"typ %@\nvalues %@", filterType, newFilterValues);
    
    if (![_dataFilter containsObject:filterType]) {
        [_dataFilter addObject:filterType];
    }
    
    [_dataFiltervalues setObject:newFilterValues forKey:filterType];
    
    [self saveFilter];
}
- (void)removeFilterByType:(NSString *)filterType{
    [self removeFilterByType:filterType inSilence:NO];
}
- (void)removeFilterByType:(NSString *)filterType inSilence:(BOOL)silent{
    DLog(@"remove %@", filterType);
    
    if (_dataFilter) {
        [_dataFilter removeObject:filterType];
    }
    if (_dataFiltervalues) {
        [_dataFiltervalues removeObjectForKey:filterType];
    }
    
    if (!silent) {
        [self saveFilter];
    }
    
}
- (JxCoreDataPredicateFilter *)getFilterValueFromFilter:(NSString *)filterName{
    
    DLog(@"_dataFiltervalues: %@", _dataFiltervalues);
    
    return [_dataFiltervalues objectForKey:filterName];
}

#pragma mark Get Filter
- (NSPredicate *)getPredicate{
    return [self getPredicateUseSubquerys:YES];
}
- (NSPredicate *)getPredicateUseSubquerys:(BOOL)useSubQuerys{
    LLog();
    NSMutableArray *predicates = [NSMutableArray array];
    
    if (_dataFiltervalues && [_dataFiltervalues isKindOfClass:[NSMutableDictionary class]]) {
        
        for (NSString *filter in [_dataFiltervalues allKeys]) {
            NSLog(@"Filter: %@", filter);
            
            id filterv = [_dataFiltervalues objectForKey:filter];
            
            //NSLog(@"filterv %@", filterv);
            
            if ([[filterv class] isSubclassOfClass:[JxCoreDataPredicateFilter class]]) {
                
                if ([filterv isKindOfClass:[JxCoreDataPredicateFilterContains class]]) {
                    JxCoreDataPredicateFilterContains *filterObject = (JxCoreDataPredicateFilterContains *)filterv;
                    
                    NSString *compare = @"LIKE";

                    if (filterObject != nil && [filterObject isKindOfClass:[JxCoreDataPredicateFilterContains class]]) {
                        if ([[filterObject exclude] count] > 0) {
                            
                            NSMutableArray *excludePredicates = [NSMutableArray array];
                            
                            
                            
                            for (NSString *v in filterObject.exclude) {
                                
                                if ([v isKindOfClass:[NSNumber class]]) {
                                    compare = @"=";
                                }
                                NSString *format = [NSString stringWithFormat:@"NOT ( %@ %@ %%@ ) ", filter, compare];
                                [excludePredicates addObject:[NSPredicate predicateWithFormat:format, v]];
                            }
                            
                            [predicates addObject:[NSCompoundPredicate andPredicateWithSubpredicates:excludePredicates]];
                            
                        }else if ([[filterObject contains] count] > 0) {

                            NSMutableArray *containsPredicates = [NSMutableArray array];
                            
                            
                            
                            for (id v in filterObject.contains) {
                                
                                if ([v isKindOfClass:[NSNumber class]]) {
                                    compare = @"=";
                                }
                                NSString *format = [NSString stringWithFormat:@"%@ %@ %%@", filter, compare];
                                [containsPredicates addObject:[NSPredicate predicateWithFormat:format, v]];
                            }
                            
                            [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:containsPredicates]];
                        }
                    }
                    
                }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterRange class]]) {
                    
                    JxCoreDataPredicateFilterRange *filterObject = (JxCoreDataPredicateFilterRange *)filterv;
                    float from = [filterObject.from floatValue];
                    float to = [filterObject.to floatValue];
                    
                    NSArray *filterParts = [filter componentsSeparatedByString:@"."];
                    if ([filterParts count] > 1 && useSubQuerys) {
                        NSString *filterSubKeyPath = @"";
                        NSString *filterMainKey = @"";
                        int count = 0;
                        for (NSString *part in filterParts) {
                            if (count == 0) {
                                filterMainKey = part;
                            }else{
                                filterSubKeyPath = [filterSubKeyPath stringByAppendingFormat:@".%@", part];
                            }
                            count++;
                        }
                        
                        NSString *filterFormat = [NSString stringWithFormat:@" SUBQUERY(%@, $p, $p%@ >= %%f AND $p%@ <= %%f).@count > 0 ", filterMainKey, filterSubKeyPath, filterSubKeyPath];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, from, to]];
                    }else{
                        
                        NSString *filterFormat = [NSString stringWithFormat:@" %@ BETWEEN {%%f, %%f} ", filter];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, from, to]];
                    }
                    
                }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterSmaller class]]){
                    
                    JxCoreDataPredicateFilterSmaller *filterObject = (JxCoreDataPredicateFilterSmaller *)filterv;
                    float smaller = [filterObject.smaller floatValue];
                    
                    NSArray *filterParts = [filter componentsSeparatedByString:@"."];
                    if ([filterParts count] > 1) {
                        NSString *filterSubKeyPath = @"";
                        NSString *filterMainKey = @"";
                        int count = 0;
                        for (NSString *part in filterParts) {
                            if (count == 0) {
                                filterMainKey = part;
                            }else{
                                filterSubKeyPath = [filterSubKeyPath stringByAppendingFormat:@".%@", part];
                            }
                            count++;
                        }
                        NSString *filterFormat = [NSString stringWithFormat:@" SUBQUERY(%@, $p, $p%@ <= %%f).@count > 0 ", filterMainKey, filterSubKeyPath];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, smaller]];
                    }else{
                        NSString *filterFormat = [NSString stringWithFormat:@" %@ <= %%f ", filter];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, smaller]];
                    }
                    
                }else if ([filterv isKindOfClass:[JxCoreDataPredicateFilterLarger class]]){
                    
                    JxCoreDataPredicateFilterLarger *filterObject = (JxCoreDataPredicateFilterLarger *)filterv;
                    float larger = [filterObject.larger floatValue];
                    
                    NSArray *filterParts = [filter componentsSeparatedByString:@"."];
                    if ([filterParts count] > 1) {
                        NSString *filterSubKeyPath = @"";
                        NSString *filterMainKey = @"";
                        int count = 0;
                        for (NSString *part in filterParts) {
                            if (count == 0) {
                                filterMainKey = part;
                            }else{
                                filterSubKeyPath = [filterSubKeyPath stringByAppendingFormat:@".%@", part];
                            }
                            count++;
                        }
                        NSString *filterFormat = [NSString stringWithFormat:@" SUBQUERY(%@, $p, $p%@ >= %%f).@count > 0 ", filterMainKey, filterSubKeyPath];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, larger]];
                    }else{
                        NSString *filterFormat = [NSString stringWithFormat:@" %@ >= %%f ", filter];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, larger]];
                    }
                    
                }else if([filterv isKindOfClass:[JxCoreDataPredicateFilterBool class]]){
                    JxCoreDataPredicateFilterBool *filterObject = (JxCoreDataPredicateFilterBool *)filterv;
                    BOOL yesOrNo = [filterObject.yesOrNo boolValue];
                    
                    NSArray *filterParts = [filter componentsSeparatedByString:@"."];
                    if ([filterParts count] > 1) {
                        NSString *filterSubKeyPath = @"";
                        NSString *filterMainKey = @"";
                        int count = 0;
                        for (NSString *part in filterParts) {
                            if (count == 0) {
                                filterMainKey = part;
                            }else{
                                filterSubKeyPath = [filterSubKeyPath stringByAppendingFormat:@".%@", part];
                            }
                            count++;
                        }
                        NSString *filterFormat = [NSString stringWithFormat:@" SUBQUERY(%@, $p, $p%@ = %%@).@count > 0 ", filterMainKey, filterSubKeyPath];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, yesOrNo]];
                    }else{
                        NSString *filterFormat = [NSString stringWithFormat:@" %@ = %%d ", filter];
                        [predicates addObject:[NSPredicate predicateWithFormat:filterFormat, yesOrNo]];
                    }
                }
            }
        }
    }
    
    if ([predicates count] > 0) {
        
        NSPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        
        NSLog(@"\n\n\npredicateString: %@\n\n\n", resultPredicate.predicateFormat);
        
        return resultPredicate;
        
    }
    
    NSLog(@"return nil");
    return nil;
}



@end
