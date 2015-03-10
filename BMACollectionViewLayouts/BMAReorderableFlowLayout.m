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

#import "BMAReorderableFlowLayout.h"

@interface BMAReorderableFlowLayout ()
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UICollectionViewCell *draggedView;
@property (nonatomic, assign) UIOffset dragAnchorOffset;
@property (nonatomic, assign) CGPoint initialDragPosition;
@end

@implementation BMAReorderableFlowLayout

- (void)prepareLayout {
    NSParameterAssert(self.collectionView);
    [self setupGestureRecognizers];
}

- (id<BMAReorderableDelegateFlowLayout>)delegate {
    return (id<BMAReorderableDelegateFlowLayout>)self.collectionView.delegate;
}

#pragma mark - Selected item layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self modifyLayoutAttributes:attributes];
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [self modifyLayoutAttributes:attribute];
    }
    
    return attributes;
}

- (void)modifyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    if ([self.selectedIndexPath isEqual:attributes.indexPath]) {
        attributes.hidden = YES;
    }
}

#pragma mark - Dragging cells

- (void)setupGestureRecognizers {
    if (!self.longPressRecognizer) {
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self.collectionView addGestureRecognizer:self.longPressRecognizer];
    }
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.initialDragPosition = [recognizer locationInView:self.collectionView];
            [self startDraggingAtPosition:self.initialDragPosition];
            break;
        case UIGestureRecognizerStateChanged:
            [self draggedAtPosition:[recognizer locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateEnded:
            [self finishDraggingAtPosition:[recognizer locationInView:self.collectionView]];
            break;
        case UIGestureRecognizerStateCancelled:
            [self finishDraggingAtPosition:self.initialDragPosition];
            break;
        default:
            break;
    }
}

- (void)startDraggingAtPosition:(CGPoint)position {
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:position];
    if (!indexPath || ![self canDragAtIndePath:indexPath]) {
        return;
    }

    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (![cell conformsToProtocol:@protocol(NSCopying)]) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"You need to support NSCopying on your cells if you want to use this layout. This is due to a copy of the cell being moved around so you can configure it with different state when dragging."
                               userInfo:nil] raise];
        return;
    }

    self.selectedIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:willBeginDraggingItemAtIndexPath:)]) {
        [self.delegate collectionView:self.collectionView layout:self willBeginDraggingItemAtIndexPath:self.selectedIndexPath];
    }
    
    self.draggedView = [cell copy];
    [self.collectionView addSubview:self.draggedView];
    self.draggedView.center = cell.center;
    
    self.dragAnchorOffset = UIOffsetMake(self.draggedView.center.x - position.x, self.draggedView.center.y - position.y);
    
    BMAReorderingAnimationBlock dragStartAnimation = [self dragStartedAnimation];
    
    [UIView animateWithDuration:[self animationDuration] animations:^{
        dragStartAnimation(self.draggedView);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:didBeginDraggingItemAtIndexPath:)]) {
            [self.delegate collectionView:self.collectionView layout:self didBeginDraggingItemAtIndexPath:self.selectedIndexPath];
        }
    }];
    
    [self invalidateLayout];
}

- (void)draggedAtPosition:(CGPoint)position {
    if (!self.draggedView) {
        return;
    }
    
    self.draggedView.center = CGPointMake(position.x + self.dragAnchorOffset.horizontal, position.y + self.dragAnchorOffset.vertical);
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.draggedView.center];
    if (!indexPath || [self.selectedIndexPath isEqual:indexPath]) {
        return;
    }
    
    NSIndexPath *previous = self.selectedIndexPath;
    NSIndexPath *nextIndexPath = indexPath;
    
    if (![self canMoveItemFrom:previous to:nextIndexPath]) {
        return;
    }
    
    self.selectedIndexPath = indexPath;
    
    [self.collectionView moveItemAtIndexPath:previous toIndexPath:nextIndexPath];
    
    if ([self.delegate respondsToSelector:@selector(collectionView:didMoveItemFromIndexPath:toIndexPath:)]) {
        [self.delegate collectionView:self.collectionView didMoveItemFromIndexPath:previous toIndexPath:nextIndexPath];
    }
}

- (void)finishDraggingAtPosition:(CGPoint)position {
    if (!self.draggedView) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:willEndDraggingItemAtIndexPath:)]) {
        [self.delegate collectionView:self.collectionView layout:self willEndDraggingItemAtIndexPath:self.selectedIndexPath];
    }
    
    BMAReorderingAnimationBlock dragFinishedAnimation = [self dragFinishedAnimation];
    CGPoint targetCenter = [self layoutAttributesForItemAtIndexPath:self.selectedIndexPath].center;
    [UIView animateWithDuration:[self animationDuration] animations:^{
        self.draggedView.center = targetCenter;
        dragFinishedAnimation(self.draggedView);
    }completion:^(BOOL finished) {
        [self.draggedView removeFromSuperview];
        self.draggedView = nil;
        self.selectedIndexPath = nil;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:didEndDraggingItemAtIndexPath:)]) {
            [self.delegate collectionView:self.collectionView layout:self didEndDraggingItemAtIndexPath:self.selectedIndexPath];
        }
        
        [self invalidateLayout];
    }];
}

#pragma mark - Utils

- (BOOL)canMoveItemFrom:(NSIndexPath *)from to:(NSIndexPath *)to {
    if (![self.delegate respondsToSelector:@selector(collectionView:canMoveItemFromIndexPath:toIndexPath:)]) {
        return NO;
    }
    
    return [self.delegate collectionView:self.collectionView canMoveItemFromIndexPath:from toIndexPath:to];
}

- (BOOL)canDragAtIndePath:(NSIndexPath *)indexPath {
    if (![self.delegate respondsToSelector:@selector(collectionView:canDragItemAtIndexPath:)]) {
        return NO;
    }
    
    return [self.delegate collectionView:self.collectionView canDragItemAtIndexPath:indexPath];
}

- (BMAReorderingAnimationBlock)dragStartedAnimation {
    if (![self.delegate respondsToSelector:@selector(animationForDragBeganInCollectionView:layout:)]) {
        return [self defaultDragStartedAnimation];
    }
    
    return [self.delegate animationForDragBeganInCollectionView:self.collectionView layout:self];
}

- (BMAReorderingAnimationBlock)dragFinishedAnimation {
    if (![self.delegate respondsToSelector:@selector(animationForDragEndedInCollectionView:layout:)]) {
        return [self defaultDragEndedAnimation];
    }
    
    return [self.delegate animationForDragEndedInCollectionView:self.collectionView layout:self];
}

- (BMAReorderingAnimationBlock)defaultDragStartedAnimation {
    return ^(UICollectionViewCell *draggedView){
        draggedView.alpha = 1;
        draggedView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    };
}

- (BMAReorderingAnimationBlock)defaultDragEndedAnimation {
    return ^(UICollectionViewCell *draggedView){
        draggedView.alpha = 1;
        draggedView.transform = CGAffineTransformIdentity;
    };
}

- (CGFloat)animationDuration {
    return 0.25f;
}

@end
