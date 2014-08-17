//
//  DBManager.m
//  DBTest
//
//  Created by Guozhen Li on 7/31/14.
//  Copyright (c) 2014 Guangzhen Li. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
#import "Utils.h"

#define DBNAME     @"codenavigator.sqlite"

// Project table
// Table: id project_name project_nickname
#define PROJECT_TABLE_NAME  @"project_table"
#define PROJECT_NAME        @"project_name"
#define PROJECT_NICKNAME    @"project_nickname"
#define PROJ_TABLE_SQL      @"CREATE TABLE  IF NOT EXISTS project_table (ID INTEGER PRIMARY KEY AUTOINCREMENT, project_name TEXT, project_nickname TEXT)"

// Record table
// Table: id project_id record_time
#define FREQUENCY_TABLE     @"record_table"
#define PROJECT_ID          @"project_id"
#define TIME_START          @"record_time"
#define FREQUENCY_TABLE_SQL @"CREATE TABLE  IF NOT EXISTS record_table (ID INTEGER PRIMARY KEY AUTOINCREMENT, project_id integer, record_time datetime)"

// App started and ended
#define APP_STARTED         -1
#define APP_ENDED           -2

// For Test
#define APPSTART @"a"
#define APPEND  @"b"
#define PROJECT1 @"project_a"
#define PROJECT2 @"project_b"
#define PROJECT3 @"project_c"

@interface Record : NSObject

@property (nonatomic, unsafe_unretained) int _id;
@property (nonatomic, unsafe_unretained) int _projectID;
@property (nonatomic, strong) NSDate* dateTime;

@end

@implementation Record
@synthesize dateTime;
@synthesize _id;
@synthesize _projectID;
@end

@implementation DBManager {
    sqlite3 *db;
}

-(id) init
{
    self = [super init];
    [self initDatabase];
    return self;
}

-(void) initDatabase {
    BOOL needInitTable = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) {
        NSLog(@"init DB failed 0");
        return;
    }
    NSString *documents = [paths objectAtIndex:0];
//    NSString *database_path = [documents stringByAppendingPathComponent:@".settings"];
    NSString* database_path = documents;
    database_path = [database_path stringByAppendingPathComponent:DBNAME];
    
//    [[NSFileManager defaultManager] removeItemAtPath:database_path error:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:database_path]) {
        needInitTable = YES;
    }
    int error = sqlite3_open([database_path UTF8String], &db);
    if (error != SQLITE_OK) {
        database_path = [database_path stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:database_path withIntermediateDirectories:YES attributes:nil error:nil];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            [self closeDB];
            NSLog(@"init DB failed 1");
            return;
        }
    }
    
    if (needInitTable) {
        [self initDatabaseTable];
    }
//    [self getUsageTimePerDay:nil andEnd:nil andProject:PROJECT1];
//    [self getUsageTimeForWeek:PROJECT1];
}

-(void) initDatabaseTable {
    [self execSql:PROJ_TABLE_SQL];
    [self execSql:FREQUENCY_TABLE_SQL];
    
    // For test
    // Init Data
//    [self initTestDate];
}

-(void) initTestDate {
    NSArray* array = [[NSArray alloc] initWithObjects:
                      APPSTART, @"2013-03-01 20:01:10",
                      APPEND,   @"2013-03-01 20:10:20",
                      APPSTART, @"2013-03-02 08:01:10",
                      PROJECT1, @"2013-03-02 08:01:20",
                      APPEND,   @"2013-03-02 08:40:20",
                      APPSTART, @"2013-03-02 19:01:10",
                      PROJECT1, @"2013-03-02 19:01:10",
                      PROJECT2, @"2013-03-02 19:10:10",
                      APPEND,   @"2013-03-02 19:20:20",
                      APPSTART, @"2013-03-02 20:01:10",
                      PROJECT2, @"2013-03-02 20:01:10",
                      PROJECT1, @"2013-03-02 20:30:10",
                      PROJECT3, @"2013-03-02 21:01:10",
                      PROJECT2, @"2013-03-02 21:30:10",
                      APPEND,   @"2013-03-02 22:01:20",
                      APPSTART, @"2013-03-05 23:01:10",
                      PROJECT2, @"2013-03-05 23:01:10",
                      APPEND,   @"2013-03-06 01:01:20",
                      APPSTART, @"2013-03-06 08:01:10",
                      PROJECT3, @"2013-03-06 08:01:10",
                      APPEND,   @"2013-03-06 08:30:20",
                      APPSTART, @"2013-03-06 20:01:10",
                      PROJECT3, @"2013-03-06 20:01:10",
                      APPEND,   @"2013-03-06 22:01:20",
                      APPSTART, @"2013-05-01 20:01:10",
                      PROJECT2, @"2013-05-01 20:01:10",
                      APPEND,   @"2013-05-01 22:01:20",
                      APPSTART, @"2013-05-02 09:01:10",
                      PROJECT1, @"2013-05-02 09:01:10",
                      APPEND,   @"2013-05-02 09:31:20",
                      APPSTART, @"2013-05-07 12:11:10",
                      PROJECT2, @"2013-05-07 12:11:10",
                      APPEND,   @"2013-05-07 12:32:20",
                      APPSTART, @"2013-05-09 16:41:10",
                      PROJECT3, @"2013-05-09 16:41:10",
                      APPEND,   @"2013-05-09 18:01:20",
                      APPSTART, @"2013-05-10 12:12:10",
                      PROJECT2, @"2013-05-10 12:12:10",
                      APPEND,   @"2013-05-10 13:01:20",
                      APPSTART, @"2013-05-15 20:01:10",
                      PROJECT1, @"2013-05-15 20:01:10",
                      APPEND,   @"2013-05-15 22:01:20",
                      APPSTART, @"2013-05-16 22:01:20",
                      APPEND,   @"2013-05-16 23:01:20"
                      , nil];
    
    for (int i=0; i<[array count]; i+=2) {
        if ([array objectAtIndex:i] == nil) {
            break;
        } else if ([[array objectAtIndex:i] isEqualToString:APPSTART]) {
            [self appStarted:[self stringToDate:[array objectAtIndex:i+1]]];
        } else if ([[array objectAtIndex:i] isEqualToString:APPEND]) {
            [self appEnded:[self stringToDate:[array objectAtIndex:i+1]]];
        } else {
            [self startRecord:[array objectAtIndex:i] andTime:[self stringToDate:[array objectAtIndex:i+1]]];
        }
    }
}

-(NSDate*) stringToDate:(NSString*)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [dateFormatter dateFromString:dateStr];
    return date;
}

-(NSString*) dateToString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

-(void) appStarted:(NSDate*) date{
    if (date == nil) {
        date = [NSDate date];
    }
    NSArray* array = [self getLastRecord];
    if ([array count] == 1) {
        Record* record = [array objectAtIndex:0];
//        [self deleteRecord:record._id];
        if (record._projectID == APP_STARTED) {
            return;
        }
    } else if ([array count] == 2) {
        Record* record = [array objectAtIndex:0];
        if (record._projectID != APP_ENDED) {
            NSLog(@"DB Error: record error, app started not after app ended");
        }
        if (record._projectID == APP_STARTED) {
            return;
        }
    }
    
    NSString* dateStr = [self dateToString:date];
    NSString *sql1 = [NSString stringWithFormat:
                      @"INSERT INTO record_table (project_id, record_time) VALUES ('%d', '%@')",
                      APP_STARTED, dateStr];
    
    [self execSql:sql1];
}

-(void) appEnded:(NSDate*) date {
    if (date == nil) {
        date = [NSDate date];
    }
    NSArray* array = [self getLastRecord];
    if ([array count] == 2) {
        Record* record = [array objectAtIndex:0];
        if (record._projectID == APP_ENDED) {
            [self deleteRecord:record._id];
        }
    } else if ([array count] == 0) {
        return;
    }
    
    NSString* dateStr = [self dateToString:date];
    NSString *sql1 = [NSString stringWithFormat:
                      @"INSERT INTO record_table (project_id, record_time) VALUES ('%d', '%@')",
                      APP_ENDED, dateStr];
    
    [self execSql:sql1];
}

-(void) startRecord:(NSString*)project andTime:(NSDate*)date {
    project = [[Utils getInstance] getProjectFolder:project];
    if (project == nil) {
        return;
    }
    project = [project lastPathComponent];
    if ([project compare:@"Help.html"] == NSOrderedSame) {
        return;
    }
    // Update project
    int projId = [self updateProject:project];
    
    if (date == nil) {
        date = [NSDate date];
    }
    
    NSString* dateStr = [self dateToString:date];
    NSString *recordSql = [NSString stringWithFormat:
                      @"INSERT INTO record_table (project_id, record_time) VALUES ('%d', '%@')",
                      projId, dateStr];
    
    NSArray* array = [self getLastRecord];
    // First record after start
    if ([array count] <= 1) {
        [self execSql:recordSql];
        [self appEnded:[NSDate date]];
    } else if ([array count] == 2) {
        Record* last = [array objectAtIndex:0];
        Record* last_1 = [array objectAtIndex:1];
        if (last._projectID == APP_ENDED) {
            [self deleteRecord:last._id];
            if (last_1._projectID == projId) {
                [self deleteRecord:last_1._id];
            }
        }
        [self execSql:recordSql];
        [self appEnded:[NSDate date]];
    }
}

-(void) deleteRecord:(int)_id {
    NSString *sql1 = [NSString stringWithFormat:
                      @"delete from record_table where id=%d", _id];
    [self execSql:sql1];
}

-(NSArray*) getLastRecord {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM record_table ORDER BY ID DESC LIMIT 2"];
    sqlite3_stmt * statement;
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Record *record = [[Record alloc] init];
            record._id = sqlite3_column_int(statement, 0);
            record._projectID = sqlite3_column_int(statement, 1);
            char* dateTime = (char*)sqlite3_column_text(statement, 2);
            record.dateTime = [self stringToDate:[NSString stringWithCString:dateTime encoding:NSUTF8StringEncoding]];
            [array addObject:record];
        }
    }
    sqlite3_finalize(statement);
    return array;
}

-(int) updateProject:(NSString*) project {
    int _id = [self getIDForProject:project];
    if (_id != -3) {
        return _id;
    }
    
    // Insert new project
    NSString *sql1 = [NSString stringWithFormat:
                      @"INSERT INTO project_table ('%@', '%@') VALUES ('%@', '%@')",
                      PROJECT_NAME, PROJECT_NICKNAME, project, project];

    [self execSql:sql1];
    _id = [self getIDForProject:project];
    return _id;
}

-(int) getIDForProject:(NSString*)project {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT %@ FROM project_table where %@='%@'", @"id", PROJECT_NAME, project];
    sqlite3_stmt * statement;
    int _id = -3;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            _id = sqlite3_column_int(statement, 0);
        }
    }
    sqlite3_finalize(statement);
    return _id;
}

-(NSArray*) getAllProjects {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT project_nickname FROM project_table"];
    sqlite3_stmt * statement;
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSString* proj;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            const char* str = (const char*)sqlite3_column_text(statement, 0);
            proj = [NSString stringWithUTF8String:str];
            [array addObject:proj];
        }
    }
    sqlite3_finalize(statement);
    return array;
}

-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        [self closeDB];
        NSLog(@"Error sql: %@", sql);
    }
}

-(void) closeDB {
    if (db != 0) {
        sqlite3_close(db);
    }
    db = 0;
}

-(void) dealloc {
    [self closeDB];
}

-(NSDate*) dateToDay:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate* date2 = [dateFormatter dateFromString:strDate];
    return date2;
}

-(NSDictionary*) getUsageTimePerDay:(NSDate*)from andEnd:(NSDate*)end andProject:(NSString*)project {
    if (from == nil) {
        from = [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    if (end == nil) {
        end = [NSDate date];
    }
    
    
    NSString* fromStr = [self dateToString:from];
    NSString* endStr = [self dateToString:end];
    NSString *sqlQuery;
    
    if ([project length] == 0) {
        sqlQuery = [NSString stringWithFormat:@"SELECT * FROM RECORD_TABLE WHERE project_id<0 AND record_time>='%@' AND record_time <= '%@'", fromStr, endStr];
    } else {
        int projectID = [self getIDForProject:project];
        sqlQuery = [NSString stringWithFormat:@"SELECT * FROM RECORD_TABLE WHERE project_id<0 OR project_id=%d AND record_time>='%@' AND record_time <= '%@'", projectID, fromStr, endStr];
    }

    sqlite3_stmt * statement;
    
    NSMutableArray* array = [[NSMutableArray alloc] init];

    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Record* record = [[Record alloc] init];
            record._id = sqlite3_column_int(statement, 0);
            record._projectID = sqlite3_column_int(statement, 1);
            char* dateTime = (char*)sqlite3_column_text(statement, 2);
            record.dateTime = [self stringToDate:[NSString stringWithCString:dateTime encoding:NSUTF8StringEncoding]];
            [array addObject:record];
        }
    }
    sqlite3_finalize(statement);
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    // Caculate
    if ([project length] == 0) {
        int startTime = 0;
        for (int i=0; i<[array count]; i++) {
            Record* record = [array objectAtIndex:i];
            if (record._projectID == APP_STARTED) {
                startTime = [record.dateTime timeIntervalSinceReferenceDate];
            } else if (record._projectID == APP_ENDED) {
                if (startTime == 0) {
                    //TODO
                    continue;
                }
                int interval = [record.dateTime timeIntervalSinceReferenceDate] - startTime;
                NSDate* dateTime = [self dateToDay:record.dateTime];
                NSNumber* number = [dictionary objectForKey:dateTime];
                if (number == nil) {
                    [dictionary setObject:[NSNumber numberWithInt:interval] forKey:dateTime];
                } else {
                    [dictionary setObject:[NSNumber numberWithInt:interval + [number intValue]] forKey:dateTime];
                }
                startTime = 0;
            }
        }
    } else {
        int startTime = 0;
        int recordProjectID = -10;
        for (int i=0; i<[array count]; i++) {
            Record* record = [array objectAtIndex:i];
            if (record._projectID == APP_STARTED) {
                startTime = [record.dateTime timeIntervalSinceReferenceDate];
                recordProjectID = -10;
            } else if (record._projectID == APP_ENDED) {
                if (recordProjectID != -10) {
                    int interval = [record.dateTime timeIntervalSinceReferenceDate] - startTime;
                    NSDate* dateTime = [self dateToDay:record.dateTime];
                    NSNumber* number = [dictionary objectForKey:dateTime];
                    if (number == nil) {
                        [dictionary setObject:[NSNumber numberWithInt:interval] forKey:dateTime];
                    } else {
                        [dictionary setObject:[NSNumber numberWithInt:interval + [number intValue]] forKey:dateTime];
                    }
                }
                startTime = 0;
                recordProjectID = -10;
            } else {
                if (recordProjectID != -10) {
                    int interval = [record.dateTime timeIntervalSinceReferenceDate] - startTime;
                    NSDate* dateTime = [self dateToDay:record.dateTime];
                    NSNumber* number = [dictionary objectForKey:dateTime];
                    if (number == nil) {
                        [dictionary setObject:[NSNumber numberWithInt:interval] forKey:dateTime];
                    } else {
                        [dictionary setObject:[NSNumber numberWithInt:interval + [number intValue]] forKey:dateTime];
                    }
                }
                recordProjectID = record._projectID;
                startTime = [record.dateTime timeIntervalSinceReferenceDate];
            }
        }
    }
    
    return dictionary;
}

-(long)getDayWeek:(NSDate*)dateTime{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:dateTime];
    long weekNumber = [comps weekday];
//    NSArray* weekArray = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
//    if (weekNumber >0 && weekNumber < 8) {
//        weekDay = [weekArray objectAtIndex:weekNumber - 1];
//    }
    return weekNumber - 1;
}

-(NSArray*) getUsageTimeForWeek:(NSString*)project {
    NSDictionary* recordForDays = [self getUsageTimePerDay:nil andEnd:nil andProject:project];
    NSMutableArray* recordForWeeks = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i=0; i<7; i++) {
        [recordForWeeks setObject:[NSNumber numberWithInt:0] atIndexedSubscript:i];
    }
    
    NSNumber* interval;
    NSArray* keys = [recordForDays allKeys];
    for (int i=0; i<[keys count]; i++) {
        NSDate* key = [keys objectAtIndex:i];
        interval = [recordForDays objectForKey:key];
        long weekDay = [self getDayWeek:key];
        if (weekDay < 0 || weekDay > 6) {
            NSLog(@"Error: week number error");
            continue;
        }
        NSNumber* intervalNumber = [recordForWeeks objectAtIndex:weekDay];
        int tmp = [interval intValue] + [intervalNumber intValue];
        [recordForWeeks setObject:[NSNumber numberWithInt:tmp] atIndexedSubscript:weekDay];
    }
    return recordForWeeks;
}

-(NSDate*) getFirstRecordDay {
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM record_table ORDER BY ID LIMIT 1"];
    sqlite3_stmt * statement;
    NSDate* date;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char* dateTime = (char*)sqlite3_column_text(statement, 2);
            date = [self stringToDate:[NSString stringWithCString:dateTime encoding:NSUTF8StringEncoding]];
        }
    }
    sqlite3_finalize(statement);
    return date;
}

@end
