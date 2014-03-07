//
//  JxCoreDataPredicateConfig.h
//  autokauf
//
//  Created by Jeanette Müller on 28.11.13.
//  Copyright (c) 2013 Motorpresse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JxCoreDataPredicateConfig : NSObject

@property (strong, nonatomic) NSString *filterKey;

@property (strong, nonatomic) NSString *filterSelector;
@property (strong, nonatomic) NSString *filterGetFunction;

@property (strong, nonatomic) NSNumber *from;
@property (strong, nonatomic) NSNumber *to;
@property (strong, nonatomic) NSNumber *step;

@property (strong, nonatomic) NSString *image;
@property (strong, nonatomic) NSString *highlighted;

@end
