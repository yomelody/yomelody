//
//  DBManager.m
//  melody
//
//  Created by coding Brains on 20/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "DBManager.h"
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
@implementation DBManager
+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}
-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"InstaMelody3.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
          /*  char *errMsg;
const char *sql_stmt ="create table if not exists studentsDetail (regno integer primary key, name text, department text, year text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            else
            {7607745937
                
            
            }
            sqlite3_close(database);
            return  isSuccess;
           */
            
            char *errMsg;
            const char *sql_stmt ="create table if not exists Instruments3 (instrument_id integer, instrument_path text, intrument_type text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table Instruments3");
            }
           
            const char *sql_stmt2 ="create table if not exists messages (id integer,msg_id text, msg text, sender_id integer, receiver_id integer, chat_id integer, msg_type text,date_time text)";
            if (sqlite3_exec(database, sql_stmt2, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table messages");
            }
            else
            {
            NSLog(@"table messages created");
            }
            
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    else{
    
        
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            /*  char *errMsg;
             const char *sql_stmt ="create table if not exists studentsDetail (regno integer primary key, name text, department text, year text)";
             if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
             != SQLITE_OK)
             {
             isSuccess = NO;
             NSLog(@"Failed to create table");
             }
             else
             {7607745937
             
             
             }
             sqlite3_close(database);
             return  isSuccess;
             */
            
            char *errMsg;
            const char *sql_stmt ="create table if not exists Instruments3 (instrument_id integer, instrument_path text, intrument_type text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table Instruments3");
            }
            
            const char *sql_stmt2 ="create table if not exists messages (id integer AUTOINCREMENT,msg_id text, msg text, sender_id integer, receiver_id integer, chat_id integer, msg_type text,date_time text)";
            if (sqlite3_exec(database, sql_stmt2, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table messages");
            }
            else
            {
                NSLog(@"table messages created");
            }
            
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }

        
        
        
        
    }
    return isSuccess;
}


- (BOOL) saveInstrument:(NSString*)instrument_id instrument_path:(NSString*)instrument_path
         intrument_type:(NSString*)intrument_type;
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into Instruments3 (instrument_id, instrument_path, intrument_type) values(\"%ld\",\"%@\", \"%@\")",(long)[instrument_id integerValue],instrument_path, intrument_type];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else {
            return NO;
        }
        
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into studentsDetail (regno,name, department, year) values(\"%ld\",\"%@\", \"%@\", \"%@\")",(long)[registerNumber integerValue],name, department, year];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            return YES;
//        }
//        else {
//            return NO;
//        }
        
        sqlite3_reset(statement);
    }
    return NO;
}

- (BOOL) savemsg:(NSString*)msg_text sender_id:(NSString*)sender_id type:(NSString*)msg_type receiver_id:(NSString*)receiver_id date:(NSString*)date{


    return NO;
}



- (BOOL) DeleteFromTable:(NSString*)tableName
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement))
            {
                
                return YES;
                
                
            }
            else{
                NSLog(@"Not found");
                return NO;
            }
            sqlite3_reset(statement);
        }
    }
    return NO;
}

- (NSArray*) findByIntrumentType:(NSString*)intrument_type
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select * from Instruments3 where intrument_type=\"%@\"",intrument_type];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
//                NSString *name = [[NSString alloc] initWithUTF8String:
//                                  (const char *) sqlite3_column_text(statement, 0)];
//                [resultArray addObject:name];
//                NSString *department = [[NSString alloc] initWithUTF8String:
//                                        (const char *) sqlite3_column_text(statement, 1)];
//                [resultArray addObject:department];
//                NSString *year = [[NSString alloc]initWithUTF8String:
//                                  (const char *) sqlite3_column_text(statement, 2)];
//                [resultArray addObject:year];
//                return resultArray;
                
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    // Init the Data Dictionary
                    NSMutableDictionary *_dataDictionary=[[NSMutableDictionary alloc] init];
                    
                    NSString *inst_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                    // NSLog(@"_userName = %@",_userName);
                    
                    NSString *path = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    // NSLog(@"_emailID = %@",_emailID);
                    
                    NSString *type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    // NSLog(@"_contactNumber = %@",_contactNumber);
                    
                
                    
                    [_dataDictionary setObject:[NSString stringWithFormat:@"%@",inst_id] forKey:@"inst_id"];
                    [_dataDictionary setObject:[NSString stringWithFormat:@"%@",path] forKey:@"inst_path"];
                    [_dataDictionary setObject:[NSString stringWithFormat:@"%@",type] forKey:@"type"];
                    
                    [resultArray addObject:_dataDictionary];
                }
                
                return resultArray;
                
                
            }
            else{
                NSLog(@"Not found");
                return nil;
            }
            sqlite3_reset(statement);
        }
    }
    return nil;
}



/*
- (NSArray*) findByRegisterNumber:(NSString*)registerNumber
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select name, department, year from studentsDetail where regno=\"%@\"",registerNumber];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
                NSString *department = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:department];
                NSString *year = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:year];
                return resultArray;
            }
            else{
                NSLog(@"Not found");
                return nil;
            }
            sqlite3_reset(statement);
        }
    }
    return nil;
}*/
@end
