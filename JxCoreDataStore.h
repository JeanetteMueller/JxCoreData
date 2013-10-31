//
//  JxCoreDataStore.h
//
//  Created by Jeanette Müller on 10/31/13.
//

#import <Foundation/Foundation.h>

#define kStoreDidChangeNotification @"kStoreDidChangeNotification"

@interface JxCoreDataStore : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;

- (id)initWithStoreName:(NSString *)storeName;

- (NSManagedObjectContext*)newPrivateContext;

- (void)saveContext;

- (BOOL)replaceCurrentSQLiteDBWithNewDB:(NSURL *)pathToNewDBFile;

@end
