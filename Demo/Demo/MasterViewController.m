/*
 The MIT License (MIT)
 
 Copyright (c) 2014-present Badoo Trading Limited.
 
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
 */

#import "MasterViewController.h"
#import "ReorderableViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *name = self.demos[(NSUInteger)indexPath.row];
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *next = [self controllerAtIndexPath:indexPath];
    
    if (next) {
        [self.navigationController pushViewController:next animated:YES];
    }
}

#pragma mark - 'Data'

- (NSArray *)demos {
    return [[self demosToControllers] allKeys];
}

- (UIViewController *)controllerAtIndexPath:(NSIndexPath *)path {
    NSString *key = [self demos][(NSUInteger)path.row];
    Class controllerClass = self.demosToControllers[key];
    
    if (!controllerClass) {
        return nil;
    }
    
    return [[controllerClass alloc] initWithNibName:nil bundle:nil];
}

- (NSDictionary *)demosToControllers {
    return @{@"Reorderable flow layout" : [ReorderableViewController class]};
}


@end
