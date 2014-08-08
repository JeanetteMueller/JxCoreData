//
//  JxCoreDataStore.m
//
//  Created by Jeanette Müller on 10/31/13.
//

#import "JxCoreDataStore.h"
#import "Logging.h"

@interface JxCoreDataStore ()

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong,readwrite) NSManagedObjectContext* mainManagedObjectContext;
@property (nonatomic,strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation JxCoreDataStore

#pragma mark - Public Functions
- (id)initWithStoreName:(NSString *)storeName{
    self = [super init];
    if (self) {
        _name = storeName;
        [self setupSaveNotification];
    }

    return self;
}
- (NSManagedObjectContext*)newPrivateContext{
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return context;
}
- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.mainManagedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"ERROR %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (void)flushStore{
    
    NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
    NSPersistentStore *store = [[storeCoordinator persistentStores] lastObject];
    
    NSError *error;
    NSURL *storeURL = store.URL;

    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    
    if (storeCoordinator != nil) {
        _mainManagedObjectContext = nil;
    }
    
}
- (void)deleteAllObjects:(NSString *)entityDescription{
    LLog();
    NSManagedObjectContext *privateContext = [self newPrivateContext];
    
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityDescription];
    
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:privateContext];
    
    [fetchRequest setEntity:entity];
    
    LLog();
    
    NSError *error = nil;
    
    NSArray *resultsAll;
    
    if ((resultsAll = [privateContext executeFetchRequest:fetchRequest error:&error])) {
        LLog();
        
    
        for (NSManagedObject *managedObject in resultsAll) {
            [privateContext deleteObject:managedObject];
            DLog(@"%@ object deleted",entityDescription);
        }
        if (![privateContext save:&error]) {
            DLog(@"Error deleting %@ - error:%@",entityDescription,error);
        }
    }
}
- (BOOL)replaceCurrentSQLiteDBWithNewDB:(NSURL *)pathToNewDBFile{
    DLog(@"newDB %@", pathToNewDBFile);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:pathToNewDBFile.path]) {
        
        NSArray *stores = [[self persistentStoreCoordinator] persistentStores];
        
        for(NSPersistentStore *store in stores) {
            
            if ([store.type isEqualToString:NSSQLiteStoreType]) {
                [_persistentStoreCoordinator removePersistentStore:store error:nil];
                [fileManager removeItemAtPath:store.URL.path error:nil];
            }
        }
        
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self getDBFileName]];
        
        NSError *error;
        
        if ([fileManager removeItemAtURL:storeURL error:&error]) {
            NSLog(@"OLD DB Removed");
        }else{
            NSLog(@"NO OLD DB FOUND TO REMOVE");
        }
        
        if ([self copyExistingDBFileToWorkingdirectory:storeURL]) {
            NSLog(@"from    %@", pathToNewDBFile);
            NSLog(@"to copy %@", storeURL);
            
            if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[self getSQLiteOptions] error:&error]){
                NSLog(@"Oops, could not add PersistentStore");
                NSLog(@"ERROR %@, %@", error, [error userInfo]);
                
                //abort();
            }
            
        }else{
            NSLog(@"ERROR %@, %@", error, [error userInfo]);
            abort();
        }
    }else{
        NSLog(@"neu einzufügende DB existiert nicht");
        return NO;
    }
    
    return YES;
}
#pragma mark - Private Methods
- (void)setupSaveNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* note) {
                                                      
                                                      if (_mainManagedObjectContext) {
                                                          NSManagedObjectContext *moc = self.mainManagedObjectContext;
                                                          NSManagedObjectContext *backgroundMoc = note.object;
                                                          
                                                          if (backgroundMoc != nil &&
                                                              backgroundMoc != moc &&
                                                              moc.persistentStoreCoordinator != nil &&
                                                              backgroundMoc.persistentStoreCoordinator == moc.persistentStoreCoordinator &&
                                                              moc.persistentStoreCoordinator == [self persistentStoreCoordinator]
                                                              ) {
                                                              
                                                              [moc performBlock:^(){
                                                                  [moc mergeChangesFromContextDidSaveNotification:note];
                                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kStoreDidChangeNotification object:nil];
                                                              }];
                                                          }
                                                      }
                                                      
                                                  }];
    
}
- (NSManagedObjectContext *)mainManagedObjectContext{
    if (_mainManagedObjectContext != nil) {
        
        DLog(@"return old mainManagedObjectContext");
        return _mainManagedObjectContext;
    }
    
    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    
    DLog(@"return new mainManagedObjectContext: %@", _mainManagedObjectContext);
    return _mainManagedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:_name withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
- (NSDictionary *)getSQLiteOptions{
    return @{
             NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES],
             NSInferMappingModelAutomaticallyOption: [NSNumber numberWithBool:YES]
             };
    
}
- (NSString *)getDBFileName{
    return [NSString stringWithFormat:@"%@.sqlite", _name];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    
    if (_persistentStoreCoordinator != nil) {
        DLog(@"direct return");
        return _persistentStoreCoordinator;
    }
    
    if (![NSThread currentThread].isMainThread) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            (void)[self persistentStoreCoordinator];
        });
        
        DLog(@"return after init");
        return _persistentStoreCoordinator;
    }
    
    DLog(@"create");
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    DLog(@"Db Name \"%@\"", _name);
    NSError *error;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self getDBFileName]];
    
    [self copyExistingDBFileToWorkingdirectory:storeURL];

    

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:[self getSQLiteOptions]
                                                           error:&error]) {
        
        NSLog(@"ERROR %@, %@", error, [error userInfo]);
        //abort();
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
        
//        
//        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
//                                                       configuration:nil
//                                                                 URL:storeURL
//                                                             options:[self getSQLiteOptions]
//                                                               error:&error]) {
//            
//            NSLog(@"ERROR %@, %@", error, [error userInfo]);
//        }

    }
    
    return _persistentStoreCoordinator;
}
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (BOOL)copyExistingDBFileToWorkingdirectory:(NSURL *)storeURL{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    if (![fileManager fileExistsAtPath:storeURL.path]) {
        
        NSString *sqliteFilePath = [[NSBundle mainBundle] pathForResource:_name ofType:@"sqlite"];
        
        NSLog(@"sqliteFilePath %@", sqliteFilePath);
        if (sqliteFilePath && [sqliteFilePath isKindOfClass:[NSString class]] && ![sqliteFilePath isEqualToString:@""]) {
            
            if ([fileManager fileExistsAtPath:sqliteFilePath]){
                
                NSURL *documentPath = [NSURL fileURLWithPath:sqliteFilePath];
                NSLog(@"documentPath %@", documentPath);
                
                
                if (![fileManager copyItemAtURL:documentPath toURL:storeURL error:&error]) {
                    NSLog(@"Oops, could copy preloaded data");
                }else{
                    NSLog(@"kopiere vorhandene sqlite DB an richtigen Ort");
                    return YES;
                }
            }else{
                NSLog(@"Projekteidene sqlite DB existiert nicht");
            }
        }else{
            NSLog(@"sqliteFilePath nicht definiert");
        }
    }else{
        NSLog(@"DB existiert bereits an richtigem Ort");
        return YES;
    }
    
    NSLog(@"ERROR %@, %@", error, [error userInfo]);
    return NO;
}
@end
