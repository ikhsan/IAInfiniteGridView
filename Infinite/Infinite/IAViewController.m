//
//  IAViewController.m
//  Infinite
//
//  Created by Ikhsan Assaat on 10/1/12.
//  Copyright (c) 2012 3kunci. All rights reserved.
//

#import "IAViewController.h"

#define kNumberLabelTag 9999

@interface IAViewController ()

@property (weak, nonatomic) IBOutlet IAInfiniteGridView *gridView;
- (IBAction)switchCircularMode:(id)sender;

@end

@implementation IAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (IBAction)switchCircularMode:(id)sender {
    UISwitch *circularModeSwitch = (UISwitch *)sender;
    
    [self.gridView setCircular:circularModeSwitch.isOn];
    [self.gridView jumpToIndex:0];
}

- (IBAction)switchPaging:(id)sender {
    UISwitch *pagingModeSwitch = (UISwitch *)sender;
    
    [self.gridView setPaging:pagingModeSwitch.isOn];
    [self.gridView jumpToIndex:0];
}

#pragma mark - Data Source Methods

- (UIView *)infiniteGridView:(IAInfiniteGridView *)gridView forIndex:(NSInteger)gridIndex {
    UIView *grid = [self.gridView dequeueReusableGrid];
	
	CGFloat gridWidth = [self infiniteGridView:gridView widthForIndex:gridIndex];
	CGRect frame = CGRectMake(0.0, 0.0, gridWidth, gridView.bounds.size.height);
	
	UILabel *numberLabel;
    if (grid == nil) {
		grid = [[UIView alloc] initWithFrame:frame];
        
        numberLabel = [[UILabel alloc] initWithFrame:frame];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        [numberLabel setTextColor:[UIColor whiteColor]];
		[numberLabel setFont:[UIFont boldSystemFontOfSize:(gridView.bounds.size.height * .4)]];
        [numberLabel setTextAlignment:NSTextAlignmentCenter];
        [numberLabel setTag:kNumberLabelTag];
        [grid addSubview:numberLabel];
    } else {
		grid.frame = frame;
		numberLabel = (UILabel *)[grid viewWithTag:kNumberLabelTag];
		numberLabel.frame = frame;
	}
    
    // set properties    
    NSInteger mods = gridIndex % [self numberOfGridsInInfiniteGridView:gridView];
    if (mods < 0) mods += [self numberOfGridsInInfiniteGridView:gridView];
    CGFloat red = mods * (1 / (CGFloat)[self numberOfGridsInInfiniteGridView:gridView]);
    grid.backgroundColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0];
    
    // set text
    [numberLabel setText:[NSString stringWithFormat:@"[%d]", gridIndex]];
    
    return grid;
}

- (NSUInteger)numberOfGridsInInfiniteGridView:(IAInfiniteGridView *)gridView {
	return 10;
}

- (CGFloat)infiniteGridView:(IAInfiniteGridView *)gridView widthForIndex:(NSInteger)gridIndex {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 300.0;
    }
    
    return 150.0;
}

- (void)infiniteGridView:(IAInfiniteGridView *)gridView didSelectGridAtIndex:(NSInteger)gridIndex {
	NSLog(@"grid index : %d", gridIndex);
}

- (void)infiniteGridView:(IAInfiniteGridView *)gridView didScrollToPage:(NSInteger)pageIndex {
    NSLog(@"scroll to page : %d", pageIndex);
}

@end
