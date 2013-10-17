#import <Foundation/Foundation.h>
#import "MICalendarItem.h"
#import "MIGameResult.h"

@interface MISqlLiteQuery : NSObject

extern NSString *const MICurrentSeason;

-(NSMutableArray *)getClubs;

-(NSMutableArray *)getSeasons;

-(NSMutableArray *)getGameResultsFor:(NSString *)season;

-(NSMutableArray *)getCalendarItems;

@end
