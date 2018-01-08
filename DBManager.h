//
//  DBManager.h
//  melody
//
//  Created by coding Brains on 20/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DBManager : NSObject
{
 NSString *databasePath;
}
+(DBManager*)getSharedInstance;
-(BOOL)createDB;
//-(BOOL) saveData:(NSString*)registerNumber name:(NSString*)name department:(NSString*)department year:(NSString*)year;
- (BOOL) saveInstrument:(NSString*)instrument_id instrument_path:(NSString*)instrument_path
         intrument_type:(NSString*)intrument_type;
-(NSArray*) findByRegisterNumber:(NSString*)registerNumber;
- (NSArray*) findByIntrumentType:(NSString*)intrument_type;
- (BOOL) DeleteFromTable:(NSString*)tableName;

/******************functions for chat*********************/
- (BOOL) savemsg:(NSString*)msg_text sender_id:(NSString*)sender_id type:(NSString*)msg_type receiver_id:(NSString*)receiver_id
         date:(NSString*)date;

-(NSArray*) findMsgsBySenderidAndReceiverid:(NSString*)Sender_id Receiver_id:(NSString*)Receiver_id;

/*******************************************************/
@end
