//
//  CHLayout.m
//  Chronos
//
//  Created by Leonhard Lichtschlag on 29/Nov/12.
//  Copyright (c) 2012 Leonhard Lichtschlag. All rights reserved.
//

#import "CHLayout.h"

// ===============================================================================================================
@implementation CHLayout
// ===============================================================================================================

// ---------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark in and out animations
// ---------------------------------------------------------------------------------------------------------------

- (UICollectionViewLayoutAttributes *) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	// fly in from the right
	UICollectionViewLayoutAttributes *currentLayout = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
	CGPoint currentCenter = currentLayout.center;
	currentLayout.center = CGPointMake(self.collectionViewContentSize.width, currentCenter.y);

	return currentLayout;
}


- (UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
	// fly out to the lower left
	UICollectionViewLayoutAttributes *newLayout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
	newLayout.center = CGPointMake(0.0, self.collectionViewContentSize.height);
	
	return newLayout;
}


- (void) prepareLayout
{
	[super prepareLayout];
		
	self.itemSize = CGSizeMake(14.0, 14.0);
	self.minimumInteritemSpacing = 1.0;
}



@end
