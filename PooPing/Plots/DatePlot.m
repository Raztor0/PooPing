//
//  DatePlot.m
//  Plot Gallery-Mac
//

#import "DatePlot.h"
#import "NSString+Emojize.h"
#import "PPUser.h"
#import "PPPing.h"

@interface DatePlot()

@property (nonatomic, readwrite, strong) NSArray *plotData;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, assign) NSTimeInterval earliestPoopDate;
@property (nonatomic,strong) NSDate *referenceDate;

@end

@implementation DatePlot

@synthesize plotData;

- (instancetype)init {
    if ( (self = [super init]) ) {
        self.title   = @"Date Plot";
        self.section = kLinePlots;
        self.earliestPoopDate = DBL_MAX;
    }
    
    return self;
}

- (void)setupWithUsers:(NSArray *)users {
    self.users = users;
}

- (void)generateData {
    //    const NSTimeInterval oneDay = 24 * 60 * 60;
    if([self.users count] > 0) {
        NSMutableArray *newData = [NSMutableArray array];
        for (PPUser *user in self.users) {
            for (PPPing *ping in user.recentPings) {
                NSTimeInterval pingDate = [ping.dateSent timeIntervalSince1970];
                if(pingDate < self.earliestPoopDate) {
                    self.earliestPoopDate = pingDate;
                }
                NSDictionary *dataPoint = @{
                                            @(CPTScatterPlotFieldX): @([ping.dateSent timeIntervalSince1970]),
                                            @(CPTScatterPlotFieldY) : @(ping.overall),
                                            @"user_id" : @(ping.userId),
                                            @"comment" : ping.comment,
                                            };
                [newData addObject:dataPoint];
            }
        }
        self.plotData = newData;
    } else {
        self.earliestPoopDate = [[NSDate date] timeIntervalSince1970];
    }
    
    self.referenceDate = [NSDate date];
}

- (void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated {
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    CGRect bounds = hostingView.bounds;
    
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    graph.plotAreaFrame.borderLineStyle = nil;
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
    x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble([self timeRange]) length:CPTDecimalFromDouble(-[self timeRange])];
    
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
    
    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor lightGrayColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;
    
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    for (NSDictionary *plotDictionary in self.plotData) {
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

- (NSTimeInterval)adjustedTimeIntervalForTime:(NSTimeInterval)time {
    return time - [self.referenceDate timeIntervalSince1970];
}

- (NSTimeInterval)timeRange {
    return -[self roundTimeInterval:([self.referenceDate timeIntervalSince1970] - self.earliestPoopDate)];
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

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.plotData.count;
}

- (id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSTimeInterval poopTime = [self.plotData[index][@(fieldEnum)] doubleValue];
    if(fieldEnum == CPTScatterPlotFieldX) {
        poopTime = [self adjustedTimeIntervalForTime:poopTime];
    }
    return @(poopTime);
}

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx {
    
}

@end
