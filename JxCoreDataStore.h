//
//  JxCoreDataStore.h
//
//  Created by Jeanette Müller on 10/31/13.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kStoreDidChangeNotification @"kStoreDidChangeNotification"

@interface JxCoreDataStore : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;

- (id)initWithStoreName:(NSString *)storeName andTeamID:(NSString *)teamID;

- (void)setiCloudSyncAllowed:(BOOL)allowedSync;
- (BOOL)iCloudSyncAllowed;

- (NSManagedObjectContext*)newPrivateContext;

- (void)saveContext;
- (void)flushStore;
- (void)deleteAllObjects:(NSString *)entityDescription;

- (NSString *)getDBFileName;

- (BOOL)replaceCurrentSQLiteDBWithNewDB:(NSURL *)pathToNewDBFile;

@end