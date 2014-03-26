//
//  JxCoreDataPredicateFilters.m
//  autokauf
//
//  Created by Jeanette Müller on 13.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import "JxCoreDataPredicateFilters.h"
#import "Logging.h"

@implementation JxCoreDataPredicateFilter

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _key = [decoder decodeObjectForKey:@"key"];
    
    _displayMultiplier = [decoder decodeObjectForKey:@"displayMultiplier"];
    _label = [decoder decodeObjectForKey:@"label"];
    _decimals = [decoder decodeObjectForKey:@"decimals"];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_key forKey:@"key"];
    [encoder encodeObject:_displayMultiplier forKey:@"displayMultiplier"];
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_decimals forKey:@"decimals"];
    
}
- (id)initWithKey:(NSString *)key{
    if ((self = [super init])) {
        _key = key;
    }
    return self;
}
- (id)initWithKey:(NSString *)key
       multiplier:(NSNumber *)multiplier
            label:(NSString *)label
      andDecimals:(NSNumber *)decimals{
    
    
    if ((self = [self initWithKey:key])) {
        _displayMultiplier = multiplier;
        _label = label;
        _decimals = decimals;
        
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"FILTER \"%@\": ", _key];
}
@end





@implementation JxCoreDataPredicateFilterLarger

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    _larger = [decoder decodeObjectForKey:@"larger"];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_larger forKey:@"larger"];
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ LARGER: %@", [super description], _larger];
}

@end






@implementation JxCoreDataPredicateFilterSmaller

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    _smaller = [decoder decodeObjectForKey:@"smaller"];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_smaller forKey:@"smaller"];
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ SMALLER: %@", [super description], _smaller];
}

@end







@implementation JxCoreDataPredicateFilterRange

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    _from = [decoder decodeObjectForKey:@"from"];
    _to = [decoder decodeObjectForKey:@"to"];
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_from forKey:@"from"];
    [encoder encodeObject:_to forKey:@"to"];
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ RANGE: %@ - %@", [super description], _from, _to];
}

@end








@implementation JxCoreDataPredicateFilterContains

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    _contains = [decoder decodeObjectForKey:@"contains"];
    _exclude = [decoder decodeObjectForKey:@"exclude"];
    
    if (!_contains || ![_contains isKindOfClass:[NSMutableArray class]]) {
        _contains = [NSMutableArray array];
    }
    
    if (!_exclude || ![_exclude isKindOfClass:[NSMutableArray class]]) {
        _exclude = [NSMutableArray array];
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_contains forKey:@"contains"];
    [encoder encodeObject:_exclude forKey:@"exclude"];
}
- (id)initWithKey:(NSString *)key{
    if ((self = [super init])) {
        self.key = key;
        _contains = [NSMutableArray array];
        _exclude = [NSMutableArray array];
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ CONTAINS: %@ EXCLUDE %@", [super description], _contains, _exclude];
}
- (void)setContains:(NSMutableArray *)contains{
    
    if (![contains isKindOfClass:[NSMutableArray class]] && [contains isKindOfClass:[NSArray class]]) {
        contains = [NSMutableArray arrayWithArray:contains];
    }
    
    _contains = contains;
    _exclude = [NSMutableArray array];
}
- (void)setExclude:(NSMutableArray *)exclude{
    
    if (![exclude isKindOfClass:[NSMutableArray class]] && [exclude isKindOfClass:[NSArray class]]) {
        exclude = [NSMutableArray arrayWithArray:exclude];
    }
    
    _contains = [NSMutableArray array];
    _exclude = exclude;
}

@end



@implementation JxCoreDataPredicateFilterBool

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    _yesOrNo = [decoder decodeObjectForKey:@"yesOrNo"];
    
    if (!_yesOrNo || ![_yesOrNo isKindOfClass:[NSNumber class]]) {
        _yesOrNo = @(NO);
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_yesOrNo forKey:@"yesOrNo"];
}
- (id)initWithKey:(NSString *)key{
    if ((self = [super init])) {
        self.key = key;
        _yesOrNo = @(NO);
    }
    return self;
}
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ BOOL: %d YES or NO", [super description], [_yesOrNo boolValue]];
}
- (void)setYesOrNo:(NSNumber *)yesOrNo{
    
    _yesOrNo = yesOrNo;
}

@end

