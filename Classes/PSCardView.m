// =====================================================================================================================
//  PSCardView.h
// =====================================================================================================================


#import "PSCardView.h"


#define DRAW_CARD_TINT		0


@implementation PSCardView
// ========================================================================================================== PSCardView
// ------------------------------------------------------------------------------------------------------------ cardSize

+ (CGSize) cardSize: (CECardSize) size
{
	return CGSizeMake (89, 125);
}

// --------------------------------------------------------------------------------------------- playingCardCornerRadius

+ (CGFloat) playingCardCornerRadius: (CECardSize) size
{
	return 6;
}

// ---------------------------------------------------------------------------------------------------------- drawShadow

- (void) drawShadow
{
	UIImage		*shadowImage;
	
	// Fetch the card shadow image.
	shadowImage = [UIImage imageNamed: @"CardShadow"];
	
	// Draw.
	[shadowImage drawAtPoint: CGPointMake (6.0, 6.0) blendMode: kCGBlendModeNormal alpha: 0.40];
}

// -------------------------------------------------------------------------------------------------------- drawCardFace

- (void) drawCardFace
{
	UIImage		*cardImage = nil;
	
	// Fetch the card image.
	if (self.card.suit == kCESuitSpades)
		cardImage = [UIImage imageNamed: [NSString stringWithFormat: @"%dS", self.card.rank]];
	if (self.card.suit == kCESuitHearts)
		cardImage = [UIImage imageNamed: [NSString stringWithFormat: @"%dH", self.card.rank]];
	if (self.card.suit == kCESuitClubs)
		cardImage = [UIImage imageNamed: [NSString stringWithFormat: @"%dC", self.card.rank]];
	if (self.card.suit == kCESuitDiamonds)
		cardImage = [UIImage imageNamed: [NSString stringWithFormat: @"%dD", self.card.rank]];
	
	// Draw.
	[cardImage drawAtPoint: CGPointMake (0.0, 0.0)];
	
#if DRAW_CARD_TINT
	CGRect	bounds = [self bounds];
	bounds.origin.x += 1.0;
	bounds.origin.y += 1.0;
	bounds.size.width -= 1.0;
	bounds.size.height -= 1.0;
	[[UIColor colorWithRed: 0.90 green: 0.75 blue: 0.0 alpha: 0.08] set];
	CEFillRoundedRect (UIGraphicsGetCurrentContext (), bounds, [CECardView playingCardCornerRadius: _cardSize]);
#endif	// DRAW_CARD_TINT
	
	// Highlight.
	if ((self.highlight) && (self.highlightColor))
	{
		[self.highlightColor set];
		CEFillRoundedRect (UIGraphicsGetCurrentContext (), [self bounds], [PSCardView playingCardCornerRadius: _cardSize]);
	}
}

// -------------------------------------------------------------------------------------------------------- drawCardBack

- (void) drawCardBack
{
	UIImage		*cardImage = nil;
	
	// Fetch the card image.
	if (self.card.reversed)
		cardImage = [UIImage imageNamed: @"BackReversed"];
	else
		cardImage = [UIImage imageNamed: @"Back"];
	
	// Draw.
	[cardImage drawAtPoint: CGPointMake (0.0, 0.0)];
	
#if DRAW_CARD_TINT
	CGRect	bounds = [self bounds];
	bounds.origin.x += 1.0;
	bounds.origin.y += 1.0;
	bounds.size.width -= 1.0;
	bounds.size.height -= 1.0;
	[[UIColor colorWithRed: 0.90 green: 0.75 blue: 0.0 alpha: 0.08] set];
	CEFillRoundedRect (UIGraphicsGetCurrentContext (), bounds, [PSCardView playingCardCornerRadius: _cardSize]);
#endif	// DRAW_CARD_TINT
	
	// Highlight.
	if ((self.highlight) && (self.highlightColor))
	{
		[self.highlightColor set];
		CEFillRoundedRect (UIGraphicsGetCurrentContext (), [self bounds], [PSCardView playingCardCornerRadius: _cardSize]);
	}
}

@end
