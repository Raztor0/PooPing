//
//  DatePlot.m
//  Plot Gallery-Mac
//

#import "DatePlot.h"
#import "NSString+Emojize.h"
#import "PPUser.h"
#import "PPPing.h"
#import "PPColors.h"
#import "PPNetworkClient.h"
#import "PPSessionManager.h"

@interface DatePlot()

@property (nonatomic, readwrite, strong) NSMutableArray *plotData;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic,strong) NSDate *referenceDate;

@end

@implementation DatePlot

@synthesize plotData;

- (instancetype)init {
    if ( (self = [super init]) ) {
        self.section = kLinePlots;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshNotification:) name:PPNetworkClientUserRefreshNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWithUsers:(NSArray *)users {
    self.users = users;
}

- (void)generateData {
    self.referenceDate = [NSDate date];
    self.plotData = [NSMutableArray array];
    NSTimeInterval earliestPoopDate = [[NSDate date] timeIntervalSince1970];
    for(PPUser *user in self.users) {
        NSMutableArray *newData = [NSMutableArray array];
        for (PPPing *ping in user.recentPings) {
            NSTimeInterval pingDate = [ping.dateSent timeIntervalSince1970];
            if(pingDate < earliestPoopDate) {
                earliestPoopDate = pingDate;
            }
            NSDictionary *dataPoint = @{
                                        @(CPTScatterPlotFieldX): @([ping.dateSent timeIntervalSince1970]),
                                        @(CPTScatterPlotFieldY) : @(ping.overall),
                                        @"username" : user.username,
                                        @"comment" : ping.comment,
                                        };
            
            [newData addObject:dataPoint];
        }
        newData = [[newData sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [[obj1 objectForKey:@(CPTScatterPlotFieldX)] doubleValue] >= [[obj2 objectForKey:@(CPTScatterPlotFieldX)] doubleValue];
        }] mutableCopy];
        NSMutableDictionary *plotMetaData = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                            @"plot_data" : newData,
                                                                                            @"earliest_poop_date" : @(earliestPoopDate),
                                                                                            }];
        [plotData addObject:plotMetaData];
    }
}

- (void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated {
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    CGRect bounds = hostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:theme];
    
    for(NSInteger i = 0; i < [self.plotData count]; i++) {
        NSMutableDictionary *plotMetaData = [self.plotData objectAtIndex:i];
        NSArray *data = [plotMetaData objectForKey:@"plot_data"];
        NSTimeInterval earliestPoopDate = [[plotMetaData objectForKey:@"earliest_poop_date"] doubleValue];
        
        // Setup scatter plot space
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
        graph.plotAreaFrame.borderWidth = 0;
        plotSpace.allowsUserInteraction = YES;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(-oneDay * 2)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(10)];
        
        // Axes
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
        CPTXYAxis *x          = axisSet.xAxis;
        x.majorIntervalLength         = CPTDecimalFromDouble(oneDay);
        x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
        x.minorTicksPerInterval       = 24;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = kCFDateFormatterShortStyle;
        CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
        timeFormatter.referenceDate = self.referenceDate;
        x.labelFormatter            = timeFormatter;
        x.labelRotation             = CPTFloat(M_PI_4);
        x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self timeRangeForEarliestPoopDate:earliestPoopDate]) length:CPTDecimalFromDouble(-[self timeRangeForEarliestPoopDate:earliestPoopDate])];
        
        CPTXYAxis *y = axisSet.yAxis;
        y.majorIntervalLength         = CPTDecimalFromDouble(1);
        y.minorTicksPerInterval       = 0;
        y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
        y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(5)];
        
        // Create a plot that uses the data source method
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
        dataSourceLinePlot.identifier = @"Date Plot";
        dataSourceLinePlot.delegate = self;
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 10.0f;
        [plotMetaData setObject:dataSourceLinePlot forKey:@"plot"];
        
        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 3.0;
        lineStyle.lineColor              = [CPTColor colorWithCGColor:[PPColors randomColor].CGColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;
        
        dataSourceLinePlot.dataSource = self;
        [graph addPlot:dataSourceLinePlot];
        for (NSDictionary *plotDictionary in data) {
            NSTimeInterval poopTime = [[plotDictionary objectForKey:@(CPTScatterPlotFieldX)] doubleValue];
            poopTime = [self adjustedTimeIntervalForTime:poopTime];
            NSArray *annotationPoint = @[
                                         @(poopTime),
                                         [plotDictionary objectForKey:@(CPTScatterPlotFieldY)],
                                         ];
            NSString *poop = [@":poop:" emojizedString];
            
            CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
            annotationTextStyle.color = [CPTColor whiteColor];
            annotationTextStyle.fontSize = 16.0f;
            annotationTextStyle.fontName = @"Helvetica-Bold";
            CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:poop style:annotationTextStyle];
            
            CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:annotationPoint];
            annotation.contentLayer = textLayer;
            annotation.displacement = CGPointMake(0, 0);
            [graph.plotAreaFrame.plotArea addAnnotation:annotation];
        }
    }
    
    graph.plotAreaFrame.borderLineStyle = nil;
}

- (NSTimeInterval)adjustedTimeIntervalForTime:(NSTimeInterval)time {
    return time - [self.referenceDate timeIntervalSince1970];
}

- (NSTimeInterval)timeRangeForEarliestPoopDate:(NSTimeInterval)earliestPoopDate {
    return -[self roundTimeInterval:([self.referenceDate timeIntervalSince1970] - earliestPoopDate)];
}

- (NSTimeInterval)roundTimeInterval:(NSTimeInterval)time {
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSInteger remainder = fmod(time, oneDay);
    if(remainder == 0) {
        return time;
    } else {
        return time + oneDay - remainder;
    }
}

- (NSArray*)getPlotDataForPlot:(CPTPlot*)plot {
    for (NSDictionary *plotMetaData in self.plotData) {
        if([plotMetaData objectForKey:@"plot"] == plot) {
            return [plotMetaData objectForKey:@"plot_data"];
        }
    }
    
    NSAssert(NO, @"Asked for a plot which we haven't created");
    return nil;
}

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [[self getPlotDataForPlot:plot] count];
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSArray *data = [self getPlotDataForPlot:plot];
    NSTimeInterval poopTime = [data[index][@(fieldEnum)] doubleValue];
    if(fieldEnum == CPTScatterPlotFieldX) {
        poopTime = [self adjustedTimeIntervalForTime:poopTime];
    }
    return @(poopTime);
}

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx {
    NSArray *data = [self getPlotDataForPlot:plot];
    
    NSDictionary *ping = [data objectAtIndex:idx];
    NSString *username = [ping objectForKey:@"username"];
    NSString *commentString = [ping objectForKey:@"comment"];
    NSInteger overall = [[ping objectForKey:@(CPTScatterPlotFieldY)] integerValue];
    BOOL noComment = [commentString isEqualToString:@""];
    if(noComment) {
        commentString = [NSString stringWithFormat:@"no comment\n-%@", username];
    } else {
        commentString = [NSString stringWithFormat:@"\"%@\"\n-%@", commentString, username];
    }
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%ld/5 %@", (long)overall, [@":poop:" emojizedString]] message:commentString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

#pragma mark - NSNotifications

- (void)userRefreshNotification:(NSNotification*)notification {
    if(!self.users) {
        return;
    }
    PPUser *currentUser = [PPSessionManager getCurrentUser];
    NSMutableSet *usernames = [NSMutableSet set];
    [usernames addObject:currentUser.username];
    
    for(PPUser *user in self.users) {
        [usernames addObject:user.username];
    }
    
    NSMutableArray *newUsers = [NSMutableArray array];
    
    if([usernames containsObject:currentUser.username]) {
        [newUsers addObject:currentUser];
        [usernames removeObject:currentUser.username];
    }
    
    for (PPUser *friend in currentUser.friends) {
        if([usernames containsObject:friend.username]) {
            [newUsers addObject:friend];
            [usernames removeObject:friend.username];
        }
    }
    
    [self setupWithUsers:[NSArray arrayWithArray:newUsers]];
    [self generateData];
    CPTGraph *myGraph = [self.graphs firstObject];
    for(CPTPlot *plot in myGraph.allPlots) {
        plot.delegate = nil;
        [myGraph removePlot:plot];
    }
    [myGraph.plotAreaFrame removeAllAnnotations];
    myGraph.delegate = nil;
    [self.graphs removeAllObjects];
    [self renderInGraphHostingView:myGraph.hostingView withTheme:nil animated:YES];
}

@end
