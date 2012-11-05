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
    if (grid == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, [self infiniteGridSize].width, [self infiniteGridSize].height);
        grid = [[UIView alloc] initWithFrame:frame];
        
        UILabel *numberLabel = [[UILabel alloc] initWithFrame:frame];
        [numberLabel setBackgroundColor:[UIColor clearColor]];
        [numberLabel setFont:[UIFont boldSystemFontOfSize:([self infiniteGridSize].height * .4)]];
        [numberLabel setTextColor:[UIColor whiteColor]];
        [numberLabel setTextAlignment:NSTextAlignmentCenter];
        [numberLabel setTag:kNumberLabelTag];
        [grid addSubview:numberLabel];
    }
    
    // set properties    
    NSInteger mods = gridIndex % [self numberOfInfiniteGrids];
    if (mods < 0) mods += [self numberOfInfiniteGrids];
    CGFloat red = mods * (1 / (CGFloat)[self numberOfInfiniteGrids]);
    
    grid.backgroundColor = [UIColor colorWithRed:red green:0.0 blue:0.0 alpha:1.0];
    
    UILabel *numberLabel = (UILabel *)[grid viewWithTag:kNumberLabelTag];
    [numberLabel setText:[NSString stringWithFormat:@"[%d]", gridIndex]];
    
    return grid;
}

- (NSUInteger)numberOfInfiniteGrids {
    return 10;
}

- (CGSize)infiniteGridSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(300.0, 300.0);
    }
    
    return CGSizeMake(150.0, 150.0);
}
- (void)infiniteGridView:(IAInfiniteGridView *)gridView didSelectRowAtIndex:(NSInteger)gridIndex {
    NSLog(@"Index: %i", gridIndex);
}
@end
