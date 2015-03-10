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

@import UIKit;

/*!
 @abstract Flow layout allowing for reordering of cells in collection.
 
 @discussion
 The behaviour can be customised by responding to the additional delegate methods for this layout

 For this layout to work, you need to support NSCopying protocol in your cells. This is due to
 the cell being copied when selected. Thus if you don't support NSCopying, the code will crash with an
 appropiate error message.
 */
@interface BMAReorderableFlowLayout : UICollectionViewFlowLayout

@end

typedef void (^BMAReorderingAnimationBlock)(UICollectionViewCell *draggedCell);

@protocol BMAReorderableDelegateFlowLayout <UICollectionViewDelegateFlowLayout>
@optional
/// Return YES if the item can be dragged. Default assumed NO.
- (BOOL)collectionView:(UICollectionView *)collectionView canDragItemAtIndexPath:(NSIndexPath *)indexPath;

/// Return YES if the item can be moved from the position to the position. Default assumed NO.
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

/// Reported if item can be moved, after animation happened
- (void)collectionView:(UICollectionView *)collectionView didMoveItemFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

/// Notifies that a cell has been selected and will begin dragging it
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

/// Notifies that a cell has been selected and did begin dragging it. Called after animations before dragging
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

/// Notifies that a cell previously being dragged will end dragging
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

/// Notifies that a cell previously dragged has been dropped to it's destination. Called after all animations.
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath;

/// Gives possibility to customise the animation of the cell when it's selected for dragging
- (BMAReorderingAnimationBlock)animationForDragBeganInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout;

/// Gives possibility to customise the animation of the cell when it's dropped after dragging
- (BMAReorderingAnimationBlock)animationForDragEndedInCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout;

@end
