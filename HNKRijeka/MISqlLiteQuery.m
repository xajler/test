#import "MISqlLiteQuery.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "MIClub.h"
#import "MIGameResult.h"
#import "MICalendarItem.h"

@implementation MISqlLiteQuery

FMDatabase *db;
NSMutableArray *clubs;
NSString *path;
NSString *currentSeason = @"2013/14";

-(id)init
{
    self = [super init];
    
    if (self)
    {
        path = [[NSBundle mainBundle] pathForResource:@"rijeka" ofType:@"db3"];
        // NSLog(@"Path: %@", path);
        db = [FMDatabase databaseWithPath:path];
    }
    
    return self;
}


-(NSMutableArray *)getClubs
{
    [db open];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [db executeQuery:@"SELECT id, name, short_name, image_name FROM clubs ORDER BY is_current DESC"];
    
    while ([resultSet next])
    {
        MIClub *club = [[MIClub alloc] init];
        
        club.id = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
        club.name = [resultSet stringForColumn:@"name"];
        club.shortName = [resultSet stringForColumn:@"short_name"];
        club.imageName = [resultSet stringForColumn:@"image_name"];
        
        // NSLog(@"ID: %@ and Name: %@", club.id, club.name);
        
        [result addObject:club];
    }
    
    [db close];
    
    return result;
}

-(NSMutableArray *)getGameResultsFor:(NSString *)season
{
    clubs = [self getClubs];
    
    [db open];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT id, season, date, home_clubid, guest_clubid, home_goals, guest_goals, number FROM results WHERE season = ? ORDER BY date";
    FMResultSet *resultSet;
    
    if (!season) { season = currentSeason; }
    
    NSLog(@"%@", query);
    resultSet = [db executeQueryWithFormat:query, season];
    
    while ([resultSet next])
    {
        MIGameResult *gameResult = [[MIGameResult alloc] init];
        gameResult.id = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
        gameResult.season = [self getSeasonBySeason:[resultSet stringForColumn:@"season"]];
        gameResult.date = [resultSet dateForColumn:@"date"];
        gameResult.homeClub = [self getClubById:[NSNumber numberWithInt:[resultSet intForColumn:@"home_clubid"]]];
        gameResult.guestClub = [self getClubById:[NSNumber numberWithInt:[resultSet intForColumn:@"guest_clubid"]]];
        gameResult.homeGoals = [NSNumber numberWithInt:[resultSet intForColumn:@"home_goals"]];
        gameResult.guestGoals = [NSNumber numberWithInt:[resultSet intForColumn:@"guest_goals"]];
        gameResult.number = [NSNumber numberWithInt:[resultSet intForColumn:@"number"]];
        
        [result addObject:gameResult];
    }
    
    [db close];
    
    return result;
}

-(NSMutableArray *)getSeasons
{
    NSArray *seasons = @[ @"2013/14",
                          @"2012/13",
                          @"2011/12",
                          @"2010/11",
                          @"2009/10",
                          @"2008/09",
                          @"2007/08",
                          @"2006/07",
                          @"2005/06",
                          @"2004/05",
                          @"2003/04",
                          @"2002/03",
                          @"2001/02",
                          @"2000/01",
                          @"1999/00",
                          @"1998/99",
                          @"1997/98",
                          @"1996/97",
                          @"1995/96",
                          @"1994/95",
                          @"1993/94",
                          @"1992/93",
                          @"1992"
                          ];
    
    return [NSMutableArray arrayWithArray:seasons];
}

-(NSMutableArray *)getCalendarItems
{
    clubs = [self getClubs];
    
    [db open];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [db executeQuery:@"SELECT id, home_clubid, guest_clubid, match_date FROM calendar_items ORDER BY match_date"];
    
    while ([resultSet next])
    {
        MICalendarItem *calendarItem = [[MICalendarItem alloc] init];
        calendarItem.id = [NSNumber numberWithInt:[resultSet intForColumn:@"id"]];
        calendarItem.homeClub = [self getClubById:[NSNumber numberWithInt:[resultSet intForColumn:@"home_clubid"]]];
        calendarItem.guestClub = [self getClubById:[NSNumber numberWithInt:[resultSet intForColumn:@"guest_clubid"]]];
        calendarItem.matchDate = [resultSet dateForColumn:@"match_date"];
        
        [result addObject:calendarItem];
    }
    
    [db close];
    
    return result;
}

-(MIClub *)getClubById:(NSNumber *)id
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:clubs];
    [result filterUsingPredicate:[NSPredicate predicateWithFormat:@"id == %@", id]];
    
//    MIClub *club = result[0];
//    NSLog(@"Id: %@", id);
//    NSLog(@"Count: %lu; Club Name: %@", [result count], club.name);
    
    return result[0];
}

-(NSString *)getSeasonBySeason:(NSString *)season
{
    NSMutableArray *result = [self getSeasons];
    [result filterUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", season]];
    
//    NSLog(@"Season: %@", season);
//    NSLog(@"Count: %lu; Season: %@", [result count], result[0]);
    
    return result[0];
}

@end