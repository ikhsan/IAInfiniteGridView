#IAInfiniteGridView

![image](http://dl.dropbox.com/u/10627916/IAInfiniteGridView-1.png)
![image](http://dl.dropbox.com/u/10627916/IAInfiniteGridView-2.png)


##Infinite grid view with UITableView-esque data source methods

If you want to have an infinite scroll view with our own grids, just drag IAInfiniteGridView, set and implement its data source, and your good to go!

##Features
* Circular mode
* Custom paging
* Familiar data source method to implement
* Using reuse queue for better performance

##How To

* Drag the `IAInfiniteGridView` to your project
* Add the class via code or in Interface Builder
* Set your view controller to conform `IAInfiniteGridDataSource`
* Set its data source via code ```	infiniteGridView.dataSource = self
``` 
or via IB by ctrl+drag it to your view controller and add as its `dataSource`
* Implement the required data source methods

``` objective-c
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

// this method is used for circular mode, not very useful for infinite mode
- (NSUInteger)numberOfInfiniteGrids {
    return 10;
}

- (CGSize)infiniteGridSize {    
    return CGSizeMake(150.0, 150.0);
}
```

* Scroll the heck out of it!

For more clarity, please review the code in the sample project `Infinite`.

##To Do 
* Horizontal scrolling
* Custom paging improvements
* Custom identifier

## Dependencies
 [iOS 6.0+] - Build with iOS 6 with ARC enabled

##License

IAInfiniteGridView is available under the MIT License.

## Credits

IAInfiniteGridView was created by [Ikhsan Assaat](https://github.com/ixnixnixn) 

Feel free to contact me,

- [@ixnixnixn] (http://twitter.com/ixnixnixn)
- ikhsan.assaat@gmail.com
- http://id.linkedin.com/in/ixnixnixn