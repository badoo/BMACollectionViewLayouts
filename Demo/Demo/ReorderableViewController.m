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

#import "ReorderableViewController.h"
#import "BMAReorderableFlowLayout.h"
#import "CustomCollectionViewCell.h"
#import "UICollectionView+BMADecorators.h"

@implementation NSMutableArray (BMAReordering)

- (void)bma_moveItemAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex {
    if (index == toIndex) {
        return;
    }
    
    // When index<toIndex
    for (NSUInteger i = index; i < toIndex; ++i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:i+1];
    }
    
    // When toIndex>index
    for (NSUInteger i = index; i > toIndex; --i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:i-1];
    }
}

@end

@interface ReorderableViewController () <BMAReorderableDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end

@implementation ReorderableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.colors = [@[[UIColor redColor], [UIColor greenColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor blackColor], [UIColor blueColor]] mutableCopy];
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)self.colors.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = self.colors[(NSUInteger)indexPath.item];
    return cell;
}

#pragma mark - Reorderable layout

- (BOOL)collectionView:(UICollectionView *)collectionView canDragItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    UIView *overlay = [[UIView alloc] init];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.frame = collectionView.bounds;
    overlay.alpha = 0;
    [collectionView bma_setOverlayView:overlay];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BMAReorderingAnimationBlock)animationForDragBeganInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        [collectionView bma_overlayView].alpha = 0.5;
    };
}

- (BMAReorderingAnimationBlock)animationForDragEndedInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout {
    return ^(UICollectionViewCell *draggedView){
        draggedView.transform = CGAffineTransformIdentity;
        
        [collectionView bma_overlayView].alpha = 0;
    };
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.colors bma_moveItemAtIndex:(NSUInteger)indexPath.item toIndex:(NSUInteger)toIndexPath.item];
}

@end


