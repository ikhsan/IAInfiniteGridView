#IAInfiniteGridView

![image](http://dl.dropbox.com/u/10627916/IAInfiniteGridView-1.png)
![image](http://dl.dropbox.com/u/10627916/IAInfiniteGridView-2.png)


##Infinite grid view with UITableView-esque data source methods

If you want to have an infinite scroll view with our own grids, just drag IAInfiniteGridView, set and implement its data source, and your good to go!

##Features
* Circular mode
* Custom set paging enabled
* Familiar data source method to implement
* Using reuse queue for better performance
* Also, delegate method to accept did select grid

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
 [iOS 5.0+] - Build with iOS 5 with ARC enabled

##License

IAInfiniteGridView is available under the MIT License.

Copyright (c) 2013 Ikhsan Assaat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Credits

IAInfiniteGridView was created by [Ikhsan Assaat](https://github.com/ixnixnixn) 

Feel free to contact me,

- [@ixnixnixn] (http://twitter.com/ixnixnixn)
- ikhsan.assaat@gmail.com
- http://id.linkedin.com/in/ixnixnixn