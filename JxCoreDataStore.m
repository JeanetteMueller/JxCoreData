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

- (BOOL)replaceCurrentSQLiteDBWithNewDB:(NSURL *)pathToNewDBFile{
    NSArray *stores = [_persistentStoreCoordinator persistentStores];
    
    for(NSPersistentStore *store in stores) {
        
        if ([store.type isEqualToString:NSSQLiteStoreType]) {
            [_persistentStoreCoordinator removePersistentStore:store error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self getDBFileName]];
    
    NSError *error;
    
    if ([[NSFileManager defaultManager] moveItemAtURL:pathToNewDBFile toURL:storeURL error:&error]) {
        
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[self getSQLiteOptions] error:&error]){
            NSLog(@"ERROR %@, %@", error, [error userInfo]);
            abort();
        }
        
    }else{
        NSLog(@"ERROR %@, %@", error, [error userInfo]);
        abort();
    }
    
    return YES;
}
#pragma mark - Private Methods
- (void)setupSaveNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* note) {
                                                      
                                                      NSManagedObjectContext *moc = self.mainManagedObjectContext;
                                                      NSManagedObjectContext *backgroundMoc = note.object;
                                                      
                                                      if (backgroundMoc != nil &&
                                                          backgroundMoc != moc &&
                                                          backgroundMoc.persistentStoreCoordinator == moc.persistentStoreCoordinator) {
                                                          
                                                          [moc performBlock:^(){
                                                              [moc mergeChangesFromContextDidSaveNotification:note];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kStoreDidChangeNotification object:nil];
                                                          }];
                                                      }
                                                  }];
    
}
- (NSManagedObjectContext *)mainManagedObjectContext{
    if (_mainManagedObjectContext != nil) {
        return _mainManagedObjectContext;
    }

    _mainManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
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
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
}
- (NSString *)getDBFileName{
    return [NSString stringWithFormat:@"%@.sqlite", _name];
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    DLog(@"Db Name \"%@\"", _name);
    NSError *error;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self getDBFileName]];
    
    if (![[[NSFileManager alloc] init] fileExistsAtPath:storeURL.path]) {
        
        NSString *sqliteFilePath = [[NSBundle mainBundle] pathForResource:_name ofType:@"sqlite"];
        
        NSLog(@"sqliteFilePath %@", sqliteFilePath);
        if (sqliteFilePath) {
            NSURL *documentPath = [NSURL fileURLWithPath:sqliteFilePath];
            NSLog(@"documentPath %@", documentPath);
            
            if ([[[NSFileManager alloc] init] fileExistsAtPath:documentPath.path]){
                
                if (![[NSFileManager defaultManager] copyItemAtURL:documentPath toURL:storeURL error:&error]) {
                    NSLog(@"Oops, could copy preloaded data");
                    NSLog(@"ERROR %@, %@", error, [error userInfo]);
                    
                }else{
                    NSLog(@"kopiere vorhandene sqlite DB an richtigen Ort");
                }
                
            }else{
                NSLog(@"Projekteidene sqlite DB existiert nicht");
            }
        }else{
            NSLog(@"sqliteFilePath nicht definiert");
        }
    }else{
        NSLog(@"DB existiert bereits an richtigem Ort");
    }
    
    
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[self getSQLiteOptions] error:&error]) {
        NSLog(@"ERROR %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
