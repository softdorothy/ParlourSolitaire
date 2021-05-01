// =====================================================================================================================
//  ParlourSolitaireViewController.m
// =====================================================================================================================


#import <AssertMacros.h>
#import "ParlourSolitaireViewController.h"
#import "PSStackView.h"


#define DISPLAY_TABLEAU_BORDERS			0
#define DARK_FOUNDATION_BORDER			0
#define DISALLOW_TOUCHES_IF_ANIMATION	0
#define DISALLOW_DRAGTO_IF_ANIMATION	1

// Portrait layout constants.
#define kPLayoutHOffset					28.0								// Left margin for entire layout.
#define kPLayoutVOffset					120.0								// Top margin for entire layout.
#define kPCardWide						89.0
#define kPCardTall						125.0
#define kPFoundationHOffset				kPLayoutHOffset + 312.0				// Left margin for foundations.
#define kPTableauHGap					16.0								// Gap between columns in tableau.
#define kPTableauVOffset				kPLayoutVOffset + kPCardTall + 16.0	// Top margin for tableau.
#define kPTableauTall					552.0								// Height of most tableau columns.
#define kPTableauTallShorter			472.0								// Height of tableau columns near waste and stock.
#define kPStockHOffset					kPLayoutHOffset + 458.0				// Left margin for stock.
#define kPStockVOffset					kPLayoutVOffset + 726.0				// Top margin for stock.

#define kPNewButtonX					12
#define kPNewButtonY					774
#define kPUndoButtonX					0
#define kPUndoButtonY					834
#define kPInfoButtonX					12
#define kPInfoButtonY					904

// Landscape layout constants.
#define kLLayoutHOffset					150.0
#define kLLayoutVOffset					16.0
#define kLCardWide						89.0
#define kLCardTall						125.0
#define kLFoundationHOffset				kLLayoutHOffset + 312.0
#define kLTableauHGap					16.0
#define kLTableauVOffset				kLLayoutVOffset + kLCardTall + 16.0
#define kLTableauTall					552.0
#define kLTableauTallShorter			424.0								// Height of tableau columns near waste and stock.
#define kLStockHOffset					kLLayoutHOffset + 458.0				// Left margin for stock.
#define kLStockVOffset					kLLayoutVOffset + 588.0				// Top margin for stock.

#define kLNewButtonX					12
#define kLNewButtonY					518
#define kLUndoButtonX					0
#define kLUndoButtonY					578
#define kLInfoButtonX					12
#define kLInfoButtonY					648

#define kDealAnimationDuration			0.25
#define kDealAnimationDelay				0.23
#define kDealWasteAnimationDuration		0.25
#define kDealWasteAnimationDelay		0.20
#define kFlipAnimationDuration			0.20
#define kFlipAnimationDelay				0.20
#define kPutawayAnimationDuration		0.30
#define kPutawayAnimationDelay			0.30
#define kPostFlipAnimationDelay			0.20
#define kPostDealToWasteAnimationDelay	0.20
#define kTaskIntervalAfterReturnWaste	0.20
#define kTaskIntervalAfterDealToWaste	0.50
#define kTaskIntervalAfterDoubleTap		0.50

#define kButtonWide						128.0
#define kButtonTall						50.0

#define kHighlighterVOffset				448

#define kResetTableAlertTag				1
#define kUndoAllAlertTag				2
#define kCardsToDealAlertTag			3

#define kMaxLeaderboardScores			10


enum
{
	kAutoPutawayModeSmart = 0, 
	kAutoPutawayModeAll = 1
};

enum
{
	kLeaderboardMostPlayedMode = 0, 
	kLeaderboardMostWonMode = 1
};


@implementation ParlourSolitaireViewController
// ====================================================================================== ParlourSolitaireViewController
// ------------------------------------------------------------------------------------------ adjustLayoutForOrientation

- (void) adjustLayoutForOrientation: (UIInterfaceOrientation) orientation
{
	CGRect	mainBounds;
	CGRect	buttonFrame;
	CGRect	frame;
	
	mainBounds = [[UIScreen mainScreen] bounds];
	
	if (UIInterfaceOrientationIsPortrait (orientation))
	{
		int		i;
		
		// Adjust stock & waste.
		_stockView.frame = CGRectMake (kPStockHOffset, kPStockVOffset, kPCardWide, kPCardTall);
		_wasteView.frame = CGRectMake (kPStockHOffset + kPCardWide + kPTableauHGap, kPStockVOffset, kPCardWide, kPCardTall);
		
		// Adjust foundations.
		for (i = 0; i < 4; i++)
		{
			_foundationViews[i].frame = CGRectMake (kPFoundationHOffset + (i * (kPTableauHGap + kPCardWide)), 
					kPLayoutVOffset, kPCardWide, kPCardTall);
		}
		
		// Create tableau.
		for (i = 0; i < 7; i++)
		{
			if ((i == 2) || (i == 3))
			{
				_tableauViews[i].frame = CGRectMake (kPLayoutHOffset + (i * (kPTableauHGap + kPCardWide)), kPTableauVOffset, 
						kPCardWide, kPTableauTall);
			}
			else
			{
				_tableauViews[i].frame = CGRectMake (kPLayoutHOffset + (i * (kPTableauHGap + kPCardWide)), kPTableauVOffset, 
						kPCardWide, kPTableauTallShorter);
			}
		}
		
		buttonFrame = _newButton.frame;
		buttonFrame.origin = CGPointMake (kPNewButtonX, kPNewButtonY);
		_newButton.frame = buttonFrame;
		[_newButton setImage: [UIImage imageNamed: @"NewSelectedP"] forState: UIControlStateHighlighted];
		
		buttonFrame = _undoButton.frame;
		buttonFrame.origin = CGPointMake (kPUndoButtonX, kPUndoButtonY);
		_undoButton.frame = buttonFrame;
		[_undoButton setImage: [UIImage imageNamed: @"UndoSelectedP"] forState: UIControlStateHighlighted];
		
		buttonFrame = _infoButton.frame;
		buttonFrame.origin = CGPointMake (kPInfoButtonX, kPInfoButtonY);
		_infoButton.frame = buttonFrame;
		[_infoButton setImage: [UIImage imageNamed: @"InfoSelectedP"] forState: UIControlStateHighlighted];
		
		_darkView.frame = mainBounds;
		
		if (_infoView)
		{
			CGRect	frame;
			
			frame = _infoView.frame;
			if (_infoViewIsOpen)
				frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height - frame.size.height);
			else
				frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height);
			_infoView.frame = frame;
		}
	}
	else
	{
		int		i;
		
		// Layout for landscape orientation.
		// Adjust stock & waste.
		_stockView.frame = CGRectMake (kLStockHOffset, kLStockVOffset, kLCardWide, kLCardTall);
		_wasteView.frame = CGRectMake (kLStockHOffset + kLCardWide + kLTableauHGap, kLStockVOffset, kLCardWide, kLCardTall);
		
		// Adjust foundations.
		for (i = 0; i < 4; i++)
			_foundationViews[i].frame = CGRectMake (kLFoundationHOffset + (i * (kLTableauHGap + kLCardWide)), kLLayoutVOffset, kLCardWide, kLCardTall);
		
		// Adjust tableau.
		for (i = 0; i < 7; i++)
		{
			if (i > 3)
			{
				_tableauViews[i].frame = CGRectMake (kLLayoutHOffset + (i * (kLTableauHGap + kLCardWide)), kLTableauVOffset, 
						kLCardWide, kLTableauTallShorter);
			}
			else
			{
				_tableauViews[i].frame = CGRectMake (kLLayoutHOffset + (i * (kLTableauHGap + kLCardWide)), kLTableauVOffset, 
						kLCardWide, kLTableauTall);
			}
		}
		
		buttonFrame = _newButton.frame;
		buttonFrame.origin = CGPointMake (kLNewButtonX, kLNewButtonY);
		_newButton.frame = buttonFrame;
		[_newButton setImage: [UIImage imageNamed: @"NewSelectedL"] forState: UIControlStateHighlighted];
		
		buttonFrame = _undoButton.frame;
		buttonFrame.origin = CGPointMake (kLUndoButtonX, kLUndoButtonY);
		_undoButton.frame = buttonFrame;
		[_undoButton setImage: [UIImage imageNamed: @"UndoSelectedL"] forState: UIControlStateHighlighted];
		
		buttonFrame = _infoButton.frame;
		buttonFrame.origin = CGPointMake (kLInfoButtonX, kLInfoButtonY);
		_infoButton.frame = buttonFrame;
		[_infoButton setImage: [UIImage imageNamed: @"InfoSelectedL"] forState: UIControlStateHighlighted];
		
		_darkView.frame = CGRectMake (0.0, 0.0, mainBounds.size.height, mainBounds.size.width);
		
		if (_infoView)
		{
			CGRect	frame;
			
			frame = _infoView.frame;
			if (_infoViewIsOpen)
				frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width - frame.size.height);
			else
				frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width);
			_infoView.frame = frame;
		}
	}
	
	// Center 'Deal' image view in stock view.
	frame = _dealImageView.frame;
	frame.origin.x = CGRectGetMinX (_stockView.frame) + round ((CGRectGetWidth (_stockView.frame) - CGRectGetWidth (frame)) / 2.0);
	frame.origin.y = CGRectGetMinY (_stockView.frame) + round ((CGRectGetHeight (_stockView.frame) - CGRectGetHeight (frame)) / 2.0);
	_dealImageView.frame = frame;
}

#pragma mark ------ sound routines
// --------------------------------------------------------------------------------------------------- playCardDrawSound

- (void) playCardDrawSound
{
	int		index, initialIndex;
	
	// Skip out if sounds are turned off.
	if (_playSounds == NO)
		return;
	
	index = CERandomInt (kNumCardDrawSounds);
	initialIndex = index;
	while ([_cardDrawPlayers[index] isPlaying])
	{
		index = index + 1;
		if (index >= kNumCardDrawSounds)
			index = 0;
		
		// Bail if we already went around once.
		if (index == initialIndex)
			return;
	}
	
	[_cardDrawPlayers[index] play];
}

// ------------------------------------------------------------------------------------------------- playCardPlacedSound

- (void) playCardPlacedSound
{
	int		index, initialIndex;
	
	// Skip out if sounds are turned off.
	if (_playSounds == NO)
		return;
	
	index = CERandomInt (kNumCardPlaceSounds);
	initialIndex = index;
	while ([_cardPlacePlayers[index] isPlaying])
	{
		index = index + 1;
		if (index >= kNumCardPlaceSounds)
			index = 0;
		
		// Bail if we already went around once.
		if (index == initialIndex)
			return;
	}
	
	[_cardPlacePlayers[index] play];
}

#pragma mark ------ card routines
// --------------------------------------------------------------------------------------------- noteAtleastOneCardMoved

- (void) noteAtleastOneCardMoved
{
	NSInteger	gamesPlayed = 0;
	
	// Store score.
	[_localPlayer retrieveLocalScore: &gamesPlayed forCategory: _gamesPlayedCategory];
	[_localPlayer postLocalScore: gamesPlayed + 1 forCategory: _gamesPlayedCategory];
	[_localPlayer postLeaderboardScore: gamesPlayed + 1 forCategory: _gamesPlayedCategory];
	
	// Count this game only once.
	_playedAtleastOneCard = YES;
}

// ------------------------------------------------------------------------------------------------------- worryBackCard

- (void) worryBackCard: (CECard *) card
{
	[_worriedCards addObject: [NSNumber numberWithInt: card.index]];
}

// -------------------------------------------------------------------------------------------------- wasCardWorriedBack

- (BOOL) wasCardWorriedBack: (CECard *) card
{
	BOOL	worried = NO;
	
	for (NSNumber *number in _worriedCards)
	{
		if ([number intValue] == card.index)
		{
			worried = YES;
			break;
		}
	}
	
	return worried;
}

// ---------------------------------------------------------------------------------------- foundationToPutAwayCardSmart

- (CEStackView *) foundationToPutAwayCardSmart: (CECard *) card
{
	int			i;
	CERank		lowestRedFoundationRank;
	CERank		lowestBlackFoundationRank;
	CEStackView	*stackToPutAwayTo = nil;
	
	// Initially, assume no rank is greatest.
	lowestRedFoundationRank = kCERankKing;
	lowestBlackFoundationRank = kCERankKing;
	
	// Walk foundations finding the lowest black ranking card and lowest red ranking card on the foundation.
	for (i = 0; i < 4; i++)
	{
		CECard	*foundationCard;
		
		// Top card of foundation.
		foundationCard = [[_foundationViews[i] stack] topCard];
		
		// Compare.
		if (foundationCard == nil)
		{
			// If no card on foundation, this becomes (zero) the lowest card of the given color.
			if ((i == kCESuitDiamonds) || (i == kCESuitHearts))
				lowestRedFoundationRank = 0;
			else
				lowestBlackFoundationRank = 0;
		}
		else
		{
			if ((((i == kCESuitDiamonds) || (i == kCESuitHearts))) && (foundationCard.rank < lowestRedFoundationRank))
				lowestRedFoundationRank = foundationCard.rank;
			else if ((((i == kCESuitClubs) || (i == kCESuitSpades))) && (foundationCard.rank < lowestBlackFoundationRank))
				lowestBlackFoundationRank = foundationCard.rank;
		}
	}
	
	// Walk the foundations looking for a match.
	for (i = 0; i < 4; i++)
	{
		CECard	*foundationCard;
		
		// Top card of foundation.
		foundationCard = [[_foundationViews[i] stack] topCard];
		
		if (foundationCard == nil)
		{
			// Foundation is empty (no top card). Only an ace may be placed.
			if ((card.suit == i) && (card.rank == kCERankAce))
				stackToPutAwayTo = _foundationViews[i];
		}
		else if ((card.suit == foundationCard.suit) && (card.rank == (foundationCard.rank + 1)))
		{
			// First pass: card must ranked one greater than the top card of the foundation correspoding to card's suit.
			// Second pass: two's are always put up (Microsoft way).
			if (card.rank <= kCERankTwo)
			{
				stackToPutAwayTo = _foundationViews[i];
				break;
			}
			
			// Third pass: put up if both opposite color foundations are built up to within one of the card's rank.
			// Also: Microsoft way.
			if ((CESuitIsRed (card.suit)) && (card.rank <= (lowestBlackFoundationRank + 1)))
				stackToPutAwayTo = _foundationViews[i];
			else if ((CESuitIsBlack (card.suit)) && (card.rank <= (lowestRedFoundationRank + 1)))
				stackToPutAwayTo = _foundationViews[i];
			
			// Fourth pass: there is one case we will also allow, if card ranks is within 2 greater than both the 
			// opposite color's foundation ranks AND within 3 of it's same-color-opposite-suit foundation card.
			// NETCell way.
			if (stackToPutAwayTo == nil)
			{
				if ((card.suit == kCESuitDiamonds) && (card.rank <= (lowestBlackFoundationRank + 2)))
				{
					CECard	*oppositeFoundationCard;
					
					// Top card of 'opposite' foundation (same color, other suit).
					oppositeFoundationCard = [[_foundationViews[kCESuitHearts] stack] topCard];
					if (card.rank <= (oppositeFoundationCard.rank + 3))
						stackToPutAwayTo = _foundationViews[i];
				}
				else if ((card.suit == kCESuitClubs) && (card.rank <= (lowestRedFoundationRank + 2)))
				{
					CECard	*oppositeFoundationCard;
					
					// Top card of 'opposite' foundation (same color, other suit).
					oppositeFoundationCard = [[_foundationViews[kCESuitSpades] stack] topCard];
					if (card.rank <= (oppositeFoundationCard.rank + 3))
						stackToPutAwayTo = _foundationViews[i];
				}
				else if ((card.suit == kCESuitHearts) && (card.rank <= (lowestBlackFoundationRank + 2)))
				{
					CECard	*oppositeFoundationCard;
					
					// Top card of 'opposite' foundation (same color, other suit).
					oppositeFoundationCard = [[_foundationViews[kCESuitDiamonds] stack] topCard];
					if (card.rank <= (oppositeFoundationCard.rank + 3))
						stackToPutAwayTo = _foundationViews[i];
				}
				else if ((card.suit == kCESuitSpades) && (card.rank <= (lowestRedFoundationRank + 2)))
				{
					CECard	*oppositeFoundationCard;
					
					// Top card of 'opposite' foundation (same color, other suit).
					oppositeFoundationCard = [[_foundationViews[kCESuitClubs] stack] topCard];
					if (card.rank <= (oppositeFoundationCard.rank + 3))
						stackToPutAwayTo = _foundationViews[i];
				}
			}
		}
	}
	
	return stackToPutAwayTo;
}

// ------------------------------------------------------------------------------------------ foundationToPutAwayCardAll

- (CEStackView *) foundationToPutAwayCardAll: (CECard *) card
{
	int			i;
	CEStackView	*stackToPutAwayTo = nil;
	
	// Walk the foundations looking for a match.
	for (i = 0; i < 4; i++)
	{
		CECard	*foundationCard;
		
		// Top card of foundation.
		foundationCard = [_foundationViews[i].stack topCard];
		
		if (foundationCard == nil)
		{
			// Foundation is empty (no top card). Only an ace may be placed.
			if ((card.suit == i) && (card.rank == kCERankAce))
				stackToPutAwayTo = _foundationViews[i];
		}
		else if ((card.suit == foundationCard.suit) && (card.rank == (foundationCard.rank + 1)))
		{
			// "AllPlay" means put away any card that it is leagal to put away.
			stackToPutAwayTo = _foundationViews[i];
			break;
		}
	}
	
	return stackToPutAwayTo;
}

// -------------------------------------------------------------------------------------------------- startingCardMoving

- (void) startingCardMoving
{
	if (_beginningCardMoves == NO)
	{
		_beginningCardMoves = YES;
		[[CETableView sharedCardUndoManager] beginUndoGrouping];
	}
}

// ---------------------------------------------------------------------------------------- determineIfCardsCanBePutAway

- (void) determineIfCardsCanBePutAway
{
	BOOL	didFindCard = NO;
	
  	do
	{
		int			i;
		BOOL		flipped = NO;
		
		// If waste is empty, try to deal from stock.
		if (([_wasteView.stack topCard] == nil) && (_stockView.stack.numberOfCards > 0))
		{
			[self startingCardMoving];
			[_stockDealer dealCardsFromStackView: _stockView toStackView: _wasteView count: _cardsToDeal];
			
			goto done;
		}
		
		// Look for face down card in tableaus.
		for (i = 0; i < 7; i++)
		{
			CECard	*topCard;
			
			topCard = [_tableauViews[i].stack topCard];
			if ((topCard) && ([topCard isFaceUp] == NO))
			{
				// Flip the card face up.
				flipped = YES;
				[self startingCardMoving];
				[_tableauViews[i] flipCard: topCard faceUp: YES duration: kFlipAnimationDuration];
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kFlipAnimationDelay]];
			}
		}
		
		if (_autoPutaway)
		{
			CEStackView	*destFoundation;
			
			if (flipped)				
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kPostFlipAnimationDelay]];
			
			// Indicate no card found at this point.
			didFindCard = NO;
			
			// Walk the tableaus, examining the top cards of eack stack.
			for (i = 0; i < 7; i++)
			{
				// If the card was worried back, the player doesn't want us messing with the card.
				if ([self wasCardWorriedBack: [_tableauViews[i].stack topCard]])
					continue;
				
				// Determine if top card of tableau has a foundation it should be put-away to.
				if (_autoPutawayMode == kAutoPutawayModeSmart)
					destFoundation = [self foundationToPutAwayCardSmart: [_tableauViews[i].stack topCard]];
				else
					destFoundation = [self foundationToPutAwayCardAll: [_tableauViews[i].stack topCard]];
				if (destFoundation != nil)
				{
					[self startingCardMoving];
					[_tableauViews[i] dealTopCardToStackView: destFoundation faceUp: YES duration: kPutawayAnimationDuration];
					[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kPutawayAnimationDelay]];
					didFindCard = YES;
				}
			}
			
			// Examine the waste pile to determine if the top card can be put away.
			// If the auto-putaway mode is 'smart' and we're dealing 3 cards, we will not put a card away from the 
			// Waste since it will mess up the 'phase' of the stock-waste piles.
			if ((_autoPutawayMode == kAutoPutawayModeAll) || (_cardsToDeal == 1))
			{
				if (_autoPutawayMode == kAutoPutawayModeSmart)
					destFoundation = [self foundationToPutAwayCardSmart: [_wasteView.stack topCard]];
				else
					destFoundation = [self foundationToPutAwayCardAll: [_wasteView.stack topCard]];
				if (destFoundation != nil)
				{
					[self startingCardMoving];
					[_wasteView dealTopCardToStackView: destFoundation faceUp: YES duration: kPutawayAnimationDuration];
					[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kPutawayAnimationDelay]];
					didFindCard = YES;
				}
			}
		}
	}
	while (didFindCard == YES);
	
	// Mark end of undo grouping.
	if (_beginningCardMoves)
	{
		_beginningCardMoves = NO;
		[[CETableView sharedCardUndoManager] endUndoGrouping];
	}
	
done:
	
	return;
}

// -------------------------------------------------------------------------------------------------- allCardsArePutAway

- (BOOL) allCardsArePutAway
{
	return (([[_foundationViews[0] stack] numberOfCards] == 13) && ([[_foundationViews[1] stack] numberOfCards] == 13) && 
			([[_foundationViews[2] stack] numberOfCards] == 13) && ([[_foundationViews[2] stack] numberOfCards] == 13));
}

// ------------------------------------------------------------------------------------------------- countOfCardsOnTable

- (NSInteger) countOfCardsOnTable
{
	NSInteger	i;
	NSInteger	count = 0;
	
	count = count + _stockView.stack.numberOfCards;
	count = count + _wasteView.stack.numberOfCards;
	
	for (i = 0; i < 4; i++)
		count = count + _foundationViews[i].stack.numberOfCards;

	for (i = 0; i < 7; i++)
		count = count + _tableauViews[i].stack.numberOfCards;
	
	return count;
}

// ------------------------------------------------------------------------------------------------------ checkGameState

- (void) checkGameState
{
	// NOP.
	if (_gameWon)
		return;
	
	if ([self allCardsArePutAway])
	{
		NSInteger		gamesWon = 0;
		NSInteger		gamesPlayed = 0;
		
		// Get score.
		[_localPlayer retrieveLocalScore: &gamesWon forCategory: _gamesWonCategory];
		gamesWon += 1;
		
		// Hack! It is possible for someone to 'log in' with Game Center mid-game, win the game, and have recorded more 
		// times having won than having played (since the 'played' was logged earlier when they weren't logged in).
		[_localPlayer retrieveLocalScore: &gamesPlayed forCategory: _gamesPlayedCategory];
		if (gamesWon > gamesPlayed)
		{
			gamesPlayed = gamesWon;
			[_localPlayer postLocalScore: gamesPlayed forCategory: _gamesPlayedCategory];
			[_localPlayer postLeaderboardScore: gamesPlayed forCategory: _gamesPlayedCategory];
		}
		
		// Store score.
		[_localPlayer postLocalScore: gamesWon forCategory: _gamesWonCategory];
		[_localPlayer postLeaderboardScore: gamesWon forCategory: _gamesWonCategory];
		
		// Display number of games won.
		_gameWon = YES;
		
		// Bring up game-over view.
		[self performSelector: @selector (openGameOverView:) withObject: nil afterDelay: 0.5];
	}
}

// ------------------------------------------------------------------------------------------------------- storeSeedUsed

- (void) storeSeedUsed: (NSUInteger) seed
{
	NSUserDefaults	*defaults;
	
	// Get standard defaults.
	defaults = [NSUserDefaults standardUserDefaults];
	
	// Store new number of games played.
	[defaults setObject: [NSNumber numberWithUnsignedInteger: seed] forKey: @"Seed"];
	[defaults synchronize];
}

// -------------------------------------------------------------------------------------------------------- seedUsedLast

- (NSUInteger) seedUsedLast
{
	NSUserDefaults	*defaults;
	NSNumber		*seedValue;
	NSUInteger		seed = NSNotFound;
	
	// Get standard defaults.
	defaults = [NSUserDefaults standardUserDefaults];
	
	// Get seed.
	seedValue = [defaults objectForKey: @"Seed"];
	if (seedValue)
		seed = [seedValue unsignedIntegerValue];
	
	return seed;
}


// ---------------------------------------------------------------------------------------------------------- resetTable

- (void) resetTable: (BOOL) newDeck
{
	int			i, j;
	CEStack		*deck;
	int			count;
	
	// A game has begun but no card yet has been touched.
	if (newDeck == YES)
		_playedAtleastOneCard = NO;
	_gameWon = NO;
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey: @"CardsToDeal"] != nil)
		_cardsToDeal = [[NSUserDefaults standardUserDefaults] integerForKey: @"CardsToDeal"];
	else
		_cardsToDeal = 3;
	if ((_cardsToDeal != 1) && (_cardsToDeal != 3))
		_cardsToDeal = 3;
	_cardsToDealDesired = _cardsToDeal;
	if (_cardsToDeal == 3)
	{
		_gamesPlayedCategory = @"com.softdorothy.parloursolitaire.games_played_3";
		_gamesWonCategory = @"com.softdorothy.parloursolitaire.games_won_3";
	}
	else
	{
		_gamesPlayedCategory = @"com.softdorothy.parloursolitaire.games_played_1";
		_gamesWonCategory = @"com.softdorothy.parloursolitaire.games_won_1";
	}
	
	// Remove all cards.
	[[_stockView stack] removeAllCards];
	[[_wasteView stack] removeAllCards];
	for (i = 0; i < 4; i++)
		[[_foundationViews[i] stack] removeAllCards];
	for (i = 0; i < 7; i++)
		[[_tableauViews[i] stack] removeAllCards];
	
	// Clear Undo actions.
	// A bad thing happens if we are in the middle of an undo group (dealing cards to waste) when this is called.
	if (_stockDealer.dealing)
		[_stockDealer quickComplete];
	if (_beginningCardMoves)
		_beginningCardMoves = NO;
	[[CETableView sharedCardUndoManager] removeAllActions];
	
	// No more worried cards.
	[_worriedCards removeAllObjects];
	
	// Create deck of cards, shuffle.
	deck = [CEStack deckOfCards];
	if (newDeck == YES)
	{
		NSUInteger	seed;
		
		// Shuffle.
		seed = time (nil);
		[deck shuffleWithSeed: seed];
		[self storeSeedUsed: seed];
	}
	else
	{
		NSUInteger	seed;
		
		// Use the same shuffle used originally.
		seed = [self seedUsedLast];
		if (seed == NSNotFound)
		{
			[deck shuffleWithSeed: time (nil)];
		}
		else
		{
			[deck shuffleWithSeed: seed];
			[self storeSeedUsed: seed];
		}
	}
	
	// Initial card layout.
	for (i = 0; i < 7; i++)
	{
		for (j = i; j < 7; j++)
		{
			CECard	*topCard;
			
			// Add top card to tableau, remove from deck.
			topCard = [deck topCard];
			topCard.faceUp = (j == i);
			[topCard randomizeTransform];
			[[_tableauViews[j] stack] addCard: topCard];
			[deck removeCard: topCard];
		}
	}
	
	count = deck.numberOfCards;
	for (i = 0; i < count; i++)
	{
		CECard	*topCard;
		
		// Add top card to stock, remove from deck.
		topCard = [deck topCard];
		topCard.faceUp = NO;
		[topCard randomizeTransform];
		[[_stockView stack] addCard: topCard];
		[deck removeCard: topCard];
	}
	
	// Fire off timer to check for cards that can be put up in the foundation.
	if (_splashDismissed)
	{
		_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self 
				selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
	}
}

#pragma mark ------ actions
// ---------------------------------------------------------------------------------------------------------------- undo

- (void) new: (id) sender
{
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	if ((_playedAtleastOneCard == NO) || ([self allCardsArePutAway]))
	{
		if (_playSounds)
			[_shufflePlayer play];
		
		// If the game is over, no need for alert.
		[self resetTable: YES];
	}
	else
	{
		UIAlertView	*alert;
		
		// A game is in progress, allow the user to cancel the new game.
		alert = [[UIAlertView alloc] initWithTitle: NSLocalizedStringFromTable (@"New Game", @"Localizable", nil) 
				message: NSLocalizedStringFromTable (@"If you start a new game this game will count as a loss.", @"Localizable", nil) 
				delegate: self cancelButtonTitle: NSLocalizedStringFromTable (@"Cancel", @"Localizable", nil) 
				otherButtonTitles: NSLocalizedStringFromTable (@"New Game", @"Localizable", nil), nil];
		alert.tag = kResetTableAlertTag;
		[alert show];
		[alert release];
	}
}

// ---------------------------------------------------------------------------------------------------------------- undo

- (void) undo: (id) sender
{
	// Ignore if player has help Undo button.
	if (_undoAllAlertOpen)
		return;
	
	// Kill Undo-held timer.
	if (_undoHeldTimer)
		[_undoHeldTimer invalidate];
	_undoHeldTimer = nil;
	
	// We don't want to call undo in the middle of an undo group (cards being dealt to waste).
	if (_stockDealer.dealing)
		[_stockDealer quickComplete];
	if (_beginningCardMoves)
	{
		_beginningCardMoves = NO;
		[[CETableView sharedCardUndoManager] endUndoGrouping];
	}
	
	if ([[CETableView sharedCardUndoManager] canUndo])
	{
		if (_playSounds)
			[_undoSoundPlayer play];
		
		// Undo.
		[[CETableView sharedCardUndoManager] undo];
	}
	else
	{
		if (_playSounds)
			[_clickCloseSoundPlayer play];
	}
}

// ------------------------------------------------------------------------------------------------------------- undoAll

#define UNDO_TITLE			NSLocalizedString (@"Undo All Actions", @"")
#define UNDO_MESSAGE		NSLocalizedString (@"You can Undo all actions in this game.", @"")
#define UNDO_CANCEL_BUTTON	NSLocalizedString (@"Cancel", @"")
#define UNDO_ALL_BUTTON		NSLocalizedString (@"Undo All", @"")

- (void) undoAll: (id) sender
{
	if (([[CETableView sharedCardUndoManager] canUndo]) && ([self seedUsedLast] != NSNotFound))
	{
		UIAlertView	*alert;
		
		if (_playSounds)
			[_clickOpenSoundPlayer play];
		
		_undoAllAlertOpen = YES;
		
		// Allow the player to decide if they want to Undo to the beginning of the game.
		alert = [[UIAlertView alloc] initWithTitle: UNDO_TITLE message: UNDO_MESSAGE delegate: self 
				cancelButtonTitle: UNDO_CANCEL_BUTTON otherButtonTitles: UNDO_ALL_BUTTON, nil];
		alert.tag = kUndoAllAlertTag;
		[alert show];
		[alert release];
	}
}

// ------------------------------------------------------------------------------------------------------- undoHeldTimer

- (void) undoHeldTimer: (NSTimer *) timer
{
	// Clean up timer.
	[timer invalidate];
	_undoHeldTimer = nil;
	
	[self undoAll: nil];
}

// ------------------------------------------------------------------------------------------------------------ undoDown

- (void) undoDown: (id) sender
{
	_undoHeldTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self 
			selector: @selector (undoHeldTimer:) userInfo: nil repeats: NO];
}

// ----------------------------------------------------------------------------------------------------- undoDragOutside

- (void) undoDragOutside: (id) sender
{
	// Dragging outside Undo button will kill Undo-held timer.
	if (_undoHeldTimer)
		[_undoHeldTimer invalidate];
	_undoHeldTimer = nil;
}

// ----------------------------------------------------------------------------------------- updateGlobalScoresInterface

- (void) updateGlobalScoresInterface
{
	NSMutableString	*allNames;
	NSMutableString	*allPlayed;
	NSMutableString	*allWon;
	NSMutableString	*allPercent;
	NSUInteger		count;
	unichar			carriageReturn = 0x000D;
	CGRect			frame;
	NSInteger		played = 0;
	NSInteger		won = 0;
	BOOL			appendedColon = NO;
	
	// Leaderboard alias's.
	allNames = [NSMutableString stringWithCapacity: 80];
	count = 0;
	if ((_leaderboardAliases) && ([_leaderboardAliases count] > 0))
	{
		for (NSString *name in _leaderboardAliases)
		{
			[allNames appendString: name];
			[allNames appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
			count = count + 1;
		}
		
		// Append player if they are not in the list.
		if (_playerLeaderboardIndex == NSNotFound)
		{
			if (count >= 10)
			{
				appendedColon = YES;
				[allNames appendString: @"     :"];
				[allNames appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
				count = count + 1;
			}
			if (_localPlayer.alias)
				[allNames appendString: _localPlayer.alias];
			else
				[allNames appendString: @"You"];
			count = count + 1;
		}
	}
	else
	{
		if (_localPlayer.alias)
			[allNames appendString: _localPlayer.alias];
		else
			[allNames appendString: @"You"];
		count = count + 1;
	}
	
	_globalScoreNameLabel.numberOfLines = count;
	frame = _globalScoreNameLabel.frame;
	frame.size.height = count * 20;
	_globalScoreNameLabel.frame = frame;
	_globalScoreNameLabel.text = allNames;
	
	// Leaderboard games played.
	allPlayed = [NSMutableString stringWithCapacity: 80];
	count = 0;
	if ([_leaderboardGamesPlayed count] > 0)
	{
		for (NSString *number in _leaderboardGamesPlayed)
		{
			[allPlayed appendString: number];
			[allPlayed appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
			count = count + 1;
		}
		
		// Append player's games played if they are not in the list.
		if (_playerLeaderboardIndex == NSNotFound)
		{
			if (appendedColon)
			{
				[allPlayed appendString: @":"];
				[allPlayed appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
				count = count + 1;
			}
			
			[_localPlayer retrieveLocalScore: &played forCategory: _gamesPlayedCategory];
			[allPlayed appendString: [NSString stringWithFormat: @"%d", played]];
			count = count + 1;
		}
	}
	else
	{
		[_localPlayer retrieveLocalScore: &played forCategory: _gamesPlayedCategory];
		[allPlayed appendString: [NSString stringWithFormat: @"%d", played]];
		count = count + 1;
	}
	
	_globalScorePlayedLabel.numberOfLines = count;
	frame = _globalScorePlayedLabel.frame;
	frame.size.height = count * 20;
	_globalScorePlayedLabel.frame = frame;
	_globalScorePlayedLabel.text = allPlayed;
	
	// Leaderboard games won.
	allWon = [NSMutableString stringWithCapacity: 80];
	count = 0;
	if ([_leaderboardGamesWon count] > 0)
	{
		for (NSString *number in _leaderboardGamesWon)
		{
			[allWon appendString: number];
			[allWon appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
			count = count + 1;
		}
		
		// Append player's games won if they are not in the list.
		if (_playerLeaderboardIndex == NSNotFound)
		{
			if (appendedColon)
			{
				[allWon appendString: @":"];
				[allWon appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
				count = count + 1;
			}
			
			[_localPlayer retrieveLocalScore: &won forCategory: _gamesWonCategory];
			[allWon appendString: [NSString stringWithFormat: @"%d", won]];
			count = count + 1;
		}
	}
	else
	{
		[_localPlayer retrieveLocalScore: &won forCategory: _gamesWonCategory];
		[allWon appendString: [NSString stringWithFormat: @"%d", won]];
		count = count + 1;
	}
	
	_globalScoreWonLabel.numberOfLines = count;
	frame = _globalScoreWonLabel.frame;
	frame.size.height = count * 20;
	_globalScoreWonLabel.frame = frame;
	_globalScoreWonLabel.text = allWon;
	
	// Leaderboard percentage games won.
	allPercent = [NSMutableString stringWithCapacity: 80];
	count = 0;
	if (([_leaderboardGamesPlayed count] > 0) && ([_leaderboardGamesWon count] > 0) && 
			([_leaderboardGamesPlayed count] == [_leaderboardGamesWon count]))
	{
		for (NSString *playedNumber in _leaderboardGamesPlayed)
		{
			NSInteger	gamesPlayed, gamesWon;
			
			gamesPlayed = [playedNumber integerValue];
			gamesWon = [[_leaderboardGamesWon objectAtIndex: count] integerValue];
			
			if (gamesPlayed == 0)
			{
				[allPercent appendString: [NSString stringWithString: @"-"]];
				[allPercent appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];				
			}
			else
			{
				[allPercent appendString: [NSString stringWithFormat: @"%d%%", (gamesWon * 100) / gamesPlayed]];
				[allPercent appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];				
			}
			
			count = count + 1;
		}
		
		// Append player's percentage games won if they are not in the list.
		if (_playerLeaderboardIndex == NSNotFound)
		{
			if (appendedColon)
			{
				[allPercent appendString: @":"];
				[allPercent appendString: [NSString stringWithCharacters: &carriageReturn length: 1]];
				count = count + 1;
			}
			if (played == 0)
				[allPercent appendString: @"-"];
			else
				[allPercent appendString: [NSString stringWithFormat: @"%d%%", (won * 100) / played]];
			count = count + 1;
		}
	}
	else
	{
		if (played == 0)
			[allPercent appendString: @"-"];
		else
			[allPercent appendString: [NSString stringWithFormat: @"%d%%", (won * 100) / played]];
		count = count + 1;
	}
	
	_globalScorePercentLabel.numberOfLines = count;
	frame = _globalScorePercentLabel.frame;
	frame.size.height = count * 20;
	_globalScorePercentLabel.frame = frame;
	_globalScorePercentLabel.text = allPercent;
	
	// Hide/show leaderboard scope UI.
	if (_localPlayer.usingGameCenter)
	{
		_displayScopeLabel.hidden = NO;
		_friendScopeButton.hidden = NO;
		_allScopeButton.hidden = NO;
		_scopeSelectedImage.hidden = NO;
	}
	else
	{
		_displayScopeLabel.hidden = YES;
		_friendScopeButton.hidden = YES;
		_allScopeButton.hidden = YES;
		_scopeSelectedImage.hidden = YES;
	}
	
	// Leaderboard local player highlight.
	frame = _highlightView.frame;
	if (_leaderboardAliases)
	{
		if (_playerLeaderboardIndex == NSNotFound)
		{
			if (appendedColon)
				frame.origin.y = kHighlighterVOffset + (11 * 20);
			else
				frame.origin.y = kHighlighterVOffset + ([_leaderboardAliases count] * 20);
		}
		else
		{
			frame.origin.y = kHighlighterVOffset + (_playerLeaderboardIndex * 20);
		}
	}
	else
	{
		frame.origin.y = kHighlighterVOffset;
	}
	_highlightView.frame = frame;
}

// ---------------------------------------------------------------------------------------------------------------- info

- (void) info: (id) sender
{
	CGRect		mainBounds;
	BOOL		portrait;
	CGRect		frame;
	
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	_infoViewIsOpen = YES;
	_wasAutoPutaway = _autoPutaway;
	_wasAutoPutawayMode = _autoPutawayMode;
	_warnedAboutCardsToDeal = NO;
	
	// Refresh the global scores.
	if ((_localPlayer.usingGameCenter) && (_localPlayer.authenticated))
	{
		[_localPlayer retrieveLeaderboardScores: kMaxLeaderboardScores forCategory: _gamesWonCategory 
				friendsOnly: _leaderboardFriendsOnly];
	}
	else
	{
		// Update the UI.
		[self updateGlobalScoresInterface];
	}
	
	// Get main bounds and orientation.
	mainBounds = [[UIScreen mainScreen] bounds];
	portrait = UIInterfaceOrientationIsPortrait ([UIApplication sharedApplication].statusBarOrientation);
	
	// Create dark view to obscure card table. Initially it has a clear background.
	// Add as subview to card table.
	if (_infoView == nil)
	{
		// Create view to contain the paper tablet. Initially position it below the bottom edge of display.
		// Add as subview to dark view.
		_infoView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"PaperTablet"]];
		_infoView.userInteractionEnabled = YES;
		frame = _infoView.frame;
		if (portrait)
			frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height);
		else
			frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width);
		_infoView.frame = frame;
		[_darkView addSubview: _infoView];
	}
	
	// Initially begin with "about view" being displayed.
	_aboutView.alpha = 1.0;
	[_infoView addSubview: _aboutView];
	_currentInfoView = _aboutView;
	
	// Capture touch events.
	_darkView.userInteractionEnabled = YES;
	
	// Animate-in the view sliding in while the dark view becomes darker.
	[UIView beginAnimations: @"SlideInInfoView" context: nil];
	[UIView setAnimationDuration: 0.5];
	_darkView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.75];
	frame = _infoView.frame;
	if (portrait)
		frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height - frame.size.height);
	else
		frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width - frame.size.height);
	_infoView.frame = frame;
	[UIView commitAnimations];
}

// ----------------------------------------------------------------------------------------------------------- aboutInfo

- (void) aboutInfo: (id) sender
{
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Switch to display the "about view".
	_aboutView.alpha = 0.0;
	[_infoView addSubview: _aboutView];
	
	// Animate-out the view sliding out while the dark view becomes clear again.
	[UIView beginAnimations: @"FadeOutInfoSubview" context: _aboutView];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
	_aboutView.alpha = 1.0;
	_currentInfoView.alpha = 0.0;
	[UIView commitAnimations];
}

// --------------------------------------------------------------------------------------------- updateSettingsInterface

- (void) updateSettingsInterface
{
	CGRect	frame;
	
	// Number of cards to deal.
	frame = _cardsToDealSelectedImage.frame;
	if (_cardsToDealDesired == 3)
	{
		frame.origin.x = CGRectGetMinX (_dealThreeButton.frame) + round ((CGRectGetWidth (_dealThreeButton.frame) - CGRectGetWidth (frame)) / 2);
	}
	else
	{
		frame.origin.x = CGRectGetMinX (_dealOneButton.frame) + round ((CGRectGetWidth (_dealOneButton.frame) - CGRectGetWidth (frame)) / 2);
	}
	_cardsToDealSelectedImage.frame = frame;
	
	if (_cardsToDealDesired == 3)
	{
		[_dealThreeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_dealThreeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
		[_dealOneButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_dealOneButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
	}
	else
	{
		[_dealThreeButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_dealThreeButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
		[_dealOneButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_dealOneButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
	}
	
	// Auto-putaway.
	if (_autoPutaway)
	{
		[_autoPutawayButton setImage: [UIImage imageNamed: @"CheckYes"] forState: UIControlStateNormal];
		_smartPutawayModeLabel.alpha = 1.0;
		_putawaySelectedImage.alpha = 1.0;
		_smartPutawayButton.alpha = 1.0;
		_allPutawayButton.alpha = 1.0;
	}
	else
	{
		[_autoPutawayButton setImage: [UIImage imageNamed: @"CheckNo"] forState: UIControlStateNormal];
		_smartPutawayModeLabel.alpha = 0.33;
		_putawaySelectedImage.alpha = 0.0;
		_smartPutawayButton.alpha = 0.33;
		_allPutawayButton.alpha = 0.33;
	}
	
	// Auto-putaway mode.
	frame = _putawaySelectedImage.frame;
	if (_autoPutawayMode == kAutoPutawayModeSmart)
	{
		frame.origin.x = CGRectGetMinX (_smartPutawayButton.frame) + round ((CGRectGetWidth (_smartPutawayButton.frame) - CGRectGetWidth (frame)) / 2);
	}
	else
	{
		frame.origin.x = CGRectGetMinX (_allPutawayButton.frame) + round ((CGRectGetWidth (_allPutawayButton.frame) - CGRectGetWidth (frame)) / 2);
	}
	_putawaySelectedImage.frame = frame;
	
	if (_autoPutawayMode == kAutoPutawayModeSmart)
	{
		[_smartPutawayButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_smartPutawayButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
		[_allPutawayButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_allPutawayButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
	}
	else
	{
		[_smartPutawayButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_smartPutawayButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
		[_allPutawayButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_allPutawayButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
	}
	
	// Play sounds.
	if (_playSounds)
		[_playSoundsButton setImage: [UIImage imageNamed: @"CheckYes"] forState: UIControlStateNormal];
	else
		[_playSoundsButton setImage: [UIImage imageNamed: @"CheckNo"] forState: UIControlStateNormal];
	
	// Leaderboard label.
	_leaderboard1Label.hidden = (_cardsToDeal == 3);
	_leaderboard3Label.hidden = (_cardsToDeal != 3);
	
	// Leaderboard scope.
	frame = _scopeSelectedImage.frame;
	if (_leaderboardFriendsOnly)
		frame.origin.x = CGRectGetMinX (_friendScopeButton.frame) + round ((CGRectGetWidth (_friendScopeButton.frame) - CGRectGetWidth (frame)) / 2.0);
	else
		frame.origin.x = CGRectGetMinX (_allScopeButton.frame) + round ((CGRectGetWidth (_allScopeButton.frame) - CGRectGetWidth (frame)) / 2.0);
	_scopeSelectedImage.frame = frame;
	
	if (_leaderboardFriendsOnly)
	{
		[_friendScopeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_friendScopeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
		[_allScopeButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_allScopeButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
	}
	else
	{
		[_friendScopeButton setTitleColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.5 alpha: 0.8] forState: UIControlStateNormal];
		[_friendScopeButton setTitleColor: [UIColor colorWithRed: 0.72 green: 0.03 blue: 0.09 alpha: 1.0] forState: UIControlStateHighlighted];
		[_allScopeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0]  forState: UIControlStateNormal];
		[_allScopeButton setTitleColor: [UIColor colorWithWhite: 0.2 alpha: 1.0] forState: UIControlStateHighlighted];
	}
}

// -------------------------------------------------------------------------------------- updateLocalStatisticsInterface

- (void) updateLocalStatisticsInterface
{
	NSInteger	gamesPlayed;
	NSInteger	gamesWon;
	
	// Get number of games played and won.
	[_localPlayer retrieveLocalScore: &gamesPlayed forCategory: _gamesPlayedCategory];
	_gamesPlayedLabel.text = [NSString stringWithFormat: @"%d", gamesPlayed];
	
	[_localPlayer retrieveLocalScore: &gamesWon forCategory: _gamesWonCategory];
	_gamesWonLabel.text = [NSString stringWithFormat: @"%d", gamesWon];
	
	if (gamesPlayed != 0)
		_gamesWonPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (gamesWon * 100) / gamesPlayed];
	else
		_gamesWonPercentageLabel.text = @"-";
}

// -------------------------------------------------------------------------------------------------------- settingsInfo

- (void) settingsInfo: (id) sender
{
	NSUserDefaults	*defaults;
	NSNumber		*number;
	NSInteger		gamesPlayed = 0;
	NSInteger		gamesWon = 0;
	
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Switch to display the "settings view".
	_settingsView.alpha = 0.0;
	[_infoView addSubview: _settingsView];

	// Update user-interface to reflect user preferences.
	[self updateSettingsInterface];
	
	// Get standard defaults.
	defaults = [NSUserDefaults standardUserDefaults];
	number = [defaults objectForKey: @"GamesPlayed"];
	if (number)
		gamesPlayed = [number integerValue];
	number = [defaults objectForKey: @"GamesWon"];
	if (number)
		gamesWon = [number integerValue];
	
	// Reflect game statistics.
	_gamesPlayedLabel.text = [NSString stringWithFormat: @"%d", gamesPlayed];
	_gamesWonLabel.text = [NSString stringWithFormat: @"%d", gamesWon];
	if (gamesPlayed == 0)
		_gamesWonPercentageLabel.text = @"-";
	else
		_gamesWonPercentageLabel.text = [NSString stringWithFormat: @"%d%%", (gamesWon * 100) / gamesPlayed];
	
	// Animate-out the view sliding out while the dark view becomes clear again.
	[UIView beginAnimations: @"FadeOutInfoSubview" context: _settingsView];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
	_settingsView.alpha = 1.0;
	_currentInfoView.alpha = 0.0;
	[UIView commitAnimations];
}

// ----------------------------------------------------------------------------------------------------------- rulesInfo

- (void) rulesInfo: (id) sender
{
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Switch to display the "rules view".
	_rulesView.alpha = 0.0;
	[_infoView addSubview: _rulesView];
	
	// Animate-out the view sliding out while the dark view becomes clear again.
	[UIView beginAnimations: @"FadeOutInfoSubview" context: _rulesView];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
	_rulesView.alpha = 1.0;
	_currentInfoView.alpha = 0.0;
	[UIView commitAnimations];
}

// ----------------------------------------------------------------------------------------------------------- closeInfo

- (void) closeInfo: (id) sender
{
	CGRect		mainBounds;
	BOOL		portrait;
	CGRect		frame;
	
	if (_playSounds)
		[_clickCloseSoundPlayer play];
	
	mainBounds = [[UIScreen mainScreen] bounds];
	portrait = UIInterfaceOrientationIsPortrait ([UIApplication sharedApplication].statusBarOrientation);
	
	// Animate-out the view sliding out while the dark view becomes clear again.
	[UIView beginAnimations: @"SlideOutInfoView" context: nil];
	[UIView setAnimationDuration: 0.5];
	[UIView setAnimationDelegate: self];
	[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
	_darkView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.0];
	frame = _infoView.frame;
	if (portrait)
		frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height);
	else
		frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width);
	_infoView.frame = frame;
	[UIView commitAnimations];
	
	// If this is the first time we are dismissing the info view after launching the app.
	if (_splashDismissed == NO)
	{
		_splashDismissed = YES;
		
		// Fire off timer to check for cards that can be put up in the foundation.
		_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self 
				selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
	}
}

// ------------------------------------------------------------------------------------------ openLabSolitaireInAppStore

- (void) openLabSolitaireInAppStore: (id) sender
{
	[[UIApplication sharedApplication] openURL: 
			[NSURL URLWithString: @"itms-apps://itunes.apple.com/app/lab-solitaire/id457535509?mt=8"]];
}

// ------------------------------------------------------------------------------------------------ openGliderInAppStore

- (void) openGliderInAppStore: (id) sender
{
	[[UIApplication sharedApplication] openURL: 
			[NSURL URLWithString: @"itms-apps://itunes.apple.com/app/glider-classic/id463484447?mt=8"]];
}

// ---------------------------------------------------------------------------------------------- setNumberOfCardsToDeal

- (void) setNumberOfCardsToDeal: (id) sender
{
	// Get the numnber of cards to deal.
	_cardsToDealDesired = [(UIButton *) sender tag];
	
	// Store number in prefs.
	[[NSUserDefaults standardUserDefaults] setInteger: _cardsToDealDesired	forKey: @"CardsToDeal"];
	
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Update UI.
	[self updateSettingsInterface];
	
	// Put up alert telling them that changes will not take effect immediately.
	if ((_cardsToDealDesired != _cardsToDeal) && (_warnedAboutCardsToDeal == NO))
	{
		UIAlertView	*alert;
		
		_warnedAboutCardsToDeal = YES;
		
		// A game is in progress, we will not change the number of cards to deal until the next game.
		alert = [[UIAlertView alloc] initWithTitle: NSLocalizedStringFromTable (@"Cards To Deal", @"Localizable", nil) 
				message: NSLocalizedStringFromTable (@"The number of cards to deal will not take effect until the next game.", @"Localizable", nil) 
				delegate: self cancelButtonTitle: nil 
				otherButtonTitles: NSLocalizedStringFromTable (@"OK", @"Localizable", nil), nil];
		alert.tag = kCardsToDealAlertTag;
		[alert show];
		[alert release];
	}
}

// --------------------------------------------------------------------------------------------------- toggleAutoPutaway

- (void) toggleAutoPutaway: (id) sender
{
	NSUserDefaults	*defaults;
	
	// Toggle preference.
	_autoPutaway = !_autoPutaway;
	
	// Store auto-putaway preference.
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [NSNumber numberWithBool: _autoPutaway] forKey: @"AutoPutaway"];
	[defaults synchronize];
	
	if (_autoPutaway)
	{
		[sender setImage: [UIImage imageNamed: @"CheckYes"] forState: UIControlStateNormal];
		if (_playSounds)
			[_clickOpenSoundPlayer play];
	}
	else
	{
		[sender setImage: [UIImage imageNamed: @"CheckNo"] forState: UIControlStateNormal];
		if (_playSounds)
			[_clickCloseSoundPlayer play];
	}
	
	// Update UI.
	[self updateSettingsInterface];
}

// ----------------------------------------------------------------------------------------------- selectAutoPutawayMode

- (IBAction) selectAutoPutawayMode: (id) sender
{
	NSUserDefaults	*defaults;
	
	// NOP.
	if (_autoPutawayMode == [sender tag])
		return;
	
	// Assign new auto-putaway mode.
	_autoPutawayMode = [sender tag];
	
	// Store auto-putaway preference.
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [NSNumber numberWithInteger: _autoPutawayMode] forKey: @"AutoPutawayMode"];
	[defaults synchronize];
	
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Update UI.
	[self updateSettingsInterface];
}

// --------------------------------------------------------------------------------------------------------- toggleSound

- (void) toggleSound: (id) sender
{
	NSUserDefaults	*defaults;
	
	// Toggle preference.
	_playSounds = !_playSounds;
	
	// Store play-sounds preference.
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [NSNumber numberWithBool: _playSounds] forKey: @"PlaySounds"];
	[defaults synchronize];
	
	if (_playSounds)
	{
		[_clickOpenSoundPlayer play];
		[sender setImage: [UIImage imageNamed: @"CheckYes"] forState: UIControlStateNormal];
	}
	else
	{
		[sender setImage: [UIImage imageNamed: @"CheckNo"] forState: UIControlStateNormal];
	}
}

// ---------------------------------------------------------------------------------------------- selectLeaderboardScope

- (IBAction) selectLeaderboardScope: (id) sender
{
	NSUserDefaults	*defaults;
	
	if ([sender tag] == 0)
	{
		// NOP.
		if (_leaderboardFriendsOnly == YES)
			return;
		
		_leaderboardFriendsOnly = YES;
	}
	else
	{
		// NOP.
		if (_leaderboardFriendsOnly == NO)
			return;
		
		_leaderboardFriendsOnly = NO;
	}
	
	// Store auto-putaway preference.
	defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject: [NSNumber numberWithBool: _leaderboardFriendsOnly] forKey: @"LeaderboardScope"];
	[defaults synchronize];
	
	if (_playSounds)
		[_clickOpenSoundPlayer play];
	
	// Update UI.
	[self updateSettingsInterface];
	[_localPlayer retrieveLeaderboardScores: kMaxLeaderboardScores forCategory: _gamesWonCategory 
			friendsOnly: _leaderboardFriendsOnly];
}

// ---------------------------------------------------------------------------------------------------- openGameOverView

- (void) openGameOverView: (id) sender
{
	if (_infoViewIsOpen)
	{
		// Player won sound.
		if (_playSounds)
			[_winSoundPlayer play];
		
		// Switch to display the "game over view".
		_gameOverView.alpha = 0.0;
		[_infoView addSubview: _gameOverView];
		
		// Update statistics.
		[self updateLocalStatisticsInterface];
		
		// Animate-out the view sliding out while the dark view becomes clear again.
		[UIView beginAnimations: @"FadeOutInfoSubview" context: _gameOverView];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
		_gameOverView.alpha = 1.0;
		_currentInfoView.alpha = 0.0;
		[UIView commitAnimations];
	}
	else
	{
		CGRect		mainBounds;
		BOOL		portrait;
		CGRect		frame;
		
		_infoViewIsOpen = YES;
		
		// Get main bounds and orientation.
		mainBounds = [[UIScreen mainScreen] bounds];
		portrait = UIInterfaceOrientationIsPortrait ([UIApplication sharedApplication].statusBarOrientation);
		
		// Create dark view to obscure card table. Initially it has a clear background.
		// Add as subview to card table.
		if (_infoView == nil)
		{
			// Create view to contain the paper tablet. Initially position it below the bottom edge of display.
			// Add as subview to dark view.
			_infoView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"PaperTablet"]];
			_infoView.userInteractionEnabled = YES;
			frame = _infoView.frame;
			if (portrait)
				frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height);
			else
				frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width);
			_infoView.frame = frame;
			[_darkView addSubview: _infoView];
		}
		
		// Add "Game Over" view.
		[_infoView addSubview: _gameOverView];
		_currentInfoView = _gameOverView;
		
		// Update statistics.
		[self updateLocalStatisticsInterface];
		
		// Capture touch events.
		_darkView.userInteractionEnabled = YES;
		
		// Animate-in the view sliding in while the dark view becomes darker.
		[UIView beginAnimations: @"SlideInInfoView" context: nil];
		[UIView setAnimationDuration: 0.5];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector (animationStopped:finished:context:)];
		_darkView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.75];
		frame = _infoView.frame;
		if (portrait)
			frame.origin = CGPointMake ((mainBounds.size.width - frame.size.width) / 2.0, mainBounds.size.height - frame.size.height);
		else
			frame.origin = CGPointMake ((mainBounds.size.height - frame.size.width) / 2.0, mainBounds.size.width - frame.size.height);
		_infoView.frame = frame;
		[UIView commitAnimations];
	}
}

// ----------------------------------------------------------------------------------- animationDidStop:finished:context

- (void) animationStopped: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context
{
	if ([animationID isEqualToString: @"SlideInInfoView"])
	{
		if (_currentInfoView == _gameOverView)
		{
			// Player won sound.
			if (_playSounds)
				[_winSoundPlayer play];
		}
	}
	else if ([animationID isEqualToString: @"SlideOutInfoView"])
	{
		_infoViewIsOpen = NO;
		
		// No longer capture touch events.
		_darkView.userInteractionEnabled = NO;
		
		if (_currentInfoView)
		{
			[_currentInfoView removeFromSuperview];
			_currentInfoView = nil;
		}
		
		// Fire off auto-putaway timer if the user enabled it.
		if ((_wasAutoPutaway == NO) || ((_wasAutoPutawayMode == kAutoPutawayModeSmart) && (_autoPutawayMode == kAutoPutawayModeAll)))
		{
			_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self 
					selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
		}
		
		// Start new game.
		if (_gameWon)
		{
			// Shuffle sound.
			if (_playSounds)
				[_shufflePlayer play];
			
			// Deal new hand.
			[self resetTable: YES];
		}
	}
	else if ([animationID isEqualToString: @"FadeOutInfoSubview"])
	{
		[_currentInfoView removeFromSuperview];
		_currentInfoView = context;
	}
}

// ----------------------------------------------------------------------------------------------- createCardTableLayout

- (void) createCardTableLayout
{
	NSUserDefaults	*defaults;
	NSNumber		*number;
	int				i;
	CGRect			mainBounds;
	CGRect			frame;
	NSURL			*audioURL;
	NSError			*error;
	
	// Store orientation.
	_orientation = self.interfaceOrientation;
	
	// Get standard defaults, what is the user preference for auto-putaway.
	defaults = [NSUserDefaults standardUserDefaults];
	number = [defaults objectForKey: @"AutoPutaway"];
	if (number)
		_autoPutaway = [number boolValue];
	else
		_autoPutaway = YES;
	
	// What is the user preference for auto-putaway mode?
	number = [defaults objectForKey: @"AutoPutawayMode"];
	if (number)
		_autoPutawayMode = [number integerValue];
	else
		_autoPutawayMode = kAutoPutawayModeAll;
	
	// What is the user preference for sound playback?
	defaults = [NSUserDefaults standardUserDefaults];
	number = [defaults objectForKey: @"PlaySounds"];
	if (number)
		_playSounds = [number boolValue];
	else
		_playSounds = YES;
	
	// What is the user preference for leaderboard scope?
	defaults = [NSUserDefaults standardUserDefaults];
	number = [defaults objectForKey: @"LeaderboardScope"];
	if (number)
		_leaderboardFriendsOnly = [number boolValue];
	else
		_leaderboardFriendsOnly = NO;
	
	// Assign portrait and landscape images.
	[(CETableView *) self.view setPortraitImagePath: @"TablePortrait"];
	[(CETableView *) self.view setLandscapeImagePath: @"TableLandscape"];
	
	// Create 'Deal' image view.
	_dealImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Deal.png"]];
	frame = _dealImageView.frame;
	frame.origin.x = kPStockHOffset + round ((kPCardWide - CGRectGetWidth (frame)) / 2.0);
	frame.origin.y = kPStockVOffset + round ((kPCardTall - CGRectGetHeight (frame)) / 2.0);
	_dealImageView.frame = frame;
	_dealImageView.alpha = 0.5;
	[(CETableView *) self.view addSubview: _dealImageView];
	[_dealImageView release];
	
	// Create stock.
	_stockView = [[PSStackView alloc] initWithFrame: 
			CGRectMake (kPStockHOffset, kPStockVOffset, kPCardWide, kPCardTall)];
	[_stockView setCardSize: kCardSizeExtraLarge];
	[_stockView setLayout: kCEStackViewLayoutStacked];
	[_stockView setBorderColor: [UIColor colorWithWhite: 0.0 alpha: 0.25]];
	[_stockView setFillColor: nil];
	[_stockView setTag: i];
	[_stockView setDelegate: self];
	[_stockView setIdentifier: @"Stock"];
	[_stockView setArchiveIdentifier: @"Stock"];
	_stockView.enableUndoGrouping = NO;
	[(CETableView *) self.view addSubview: _stockView];
	[_stockView release];
	
	// Create waste.
	_wasteView = [[PSStackView alloc] initWithFrame: 
			CGRectMake (kPStockHOffset + kPCardWide + kPTableauHGap, kPStockVOffset, kPCardWide, kPCardTall)];
	[_wasteView setCardSize: kCardSizeExtraLarge];
	[_wasteView setLayout: kCEStackViewLayoutStacked];
	[_wasteView setBorderColor: nil];
	[_wasteView setFillColor: nil];
	[_wasteView setTag: i];
	[_wasteView setDelegate: self];
	[_wasteView setIdentifier: @"Waste"];
	[_wasteView setArchiveIdentifier: @"Waste"];
	_wasteView.enableUndoGrouping = NO;
	[(CETableView *) self.view addSubview: _wasteView];
	[_wasteView release];
	
	// Create foundations.
	for (i = 0; i < 4; i++)
	{
		_foundationViews[i] = [[PSStackView alloc] initWithFrame: 
				CGRectMake (kPFoundationHOffset + (i * (kPTableauHGap + kPCardWide)), kPLayoutVOffset, kPCardWide, kPCardTall)];
		[_foundationViews[i] setCardSize: kCardSizeExtraLarge];
		[_foundationViews[i] setLayout: kCEStackViewLayoutStacked];
#if DARK_FOUNDATION_BORDER
//		[_foundationViews[i] setFillColor: [UIColor colorWithWhite: 1.0 alpha: 0.25]];
//		[_foundationViews[i] setBorderColor: nil];
		[_foundationViews[i] setFillColor: nil];
		[_foundationViews[i] setBorderColor: [UIColor colorWithWhite: 1.0 alpha: 0.40]];
		[_foundationViews[i] setLabelColor: [UIColor colorWithWhite: 0.0 alpha: 0.60]];
#else	// DARK_FOUNDATION_BORDER
		[_foundationViews[i] setFillColor: nil];
		[_foundationViews[i] setBorderColor: [UIColor colorWithWhite: 1.0 alpha: 0.33]];
		[_foundationViews[i] setLabelColor: [UIColor colorWithWhite: 1.0 alpha: 0.45]];
#endif	// DARK_FOUNDATION_BORDER
		[_foundationViews[i] setLabelFont: [UIFont fontWithName: @"Arial" size: 64.0]];
		[_foundationViews[i] setLabel: [CECard stringForSuit: i]];
		[_foundationViews[i] setTag: i];
		[_foundationViews[i] setDelegate: self];
		[_foundationViews[i] setIdentifier: @"Foundation"];
		[_foundationViews[i] setArchiveIdentifier: [NSString stringWithFormat: @"Foundation%d", i]];
		_foundationViews[i].enableUndoGrouping = NO;
		[(CETableView *) self.view addSubview: _foundationViews[i]];
		[_foundationViews[i] release];
	}
	
	// Create tableau.
	for (i = 0; i < 7; i++)
	{
		if ((i == 2) || (i == 3))
		{
			_tableauViews[i] = [[PSStackView alloc] initWithFrame: 
					CGRectMake (kPLayoutHOffset + (i * (kPTableauHGap + kPCardWide)), kPTableauVOffset, 
					kPCardWide, kPTableauTall)];
		}
		else
		{
			_tableauViews[i] = [[PSStackView alloc] initWithFrame: 
					CGRectMake (kPLayoutHOffset + (i * (kPTableauHGap + kPCardWide)), kPTableauVOffset, 
					kPCardWide, kPTableauTallShorter)];
		}
		[_tableauViews[i] setCardSize: kCardSizeExtraLarge];
		[_tableauViews[i] setLayout: kCEStackViewLayoutBiasedColumn];
#if DISPLAY_TABLEAU_BORDERS
		[_tableauViews[i] setBorderColor: [UIColor colorWithWhite: 0.0 alpha: 0.25]];
#else	// DISPLAY_TABLEAU_BORDERS
		[_tableauViews[i] setBorderColor: nil];
#endif	// DISPLAY_TABLEAU_BORDERS
		[_tableauViews[i] setHighlightColor: [UIColor colorWithWhite: 0.0 alpha: 0.4]];
		[_tableauViews[i] setFillColor: nil];
		[_tableauViews[i] setTag: i];
		[_tableauViews[i] setDelegate: self];
		[_tableauViews[i] setIdentifier: @"Tableau"];
		[_tableauViews[i] setArchiveIdentifier: [NSString stringWithFormat: @"Tableau%d", i]];
		_tableauViews[i].enableUndoGrouping = NO;
		[_tableauViews[i] setOrderly: NO];
		[(CETableView *) self.view addSubview: _tableauViews[i]];
		[_tableauViews[i] release];
	}
	
	// Layout the buttons.
	mainBounds = [[UIScreen mainScreen] bounds];
	
	// New button.
	_newButton = [[UIButton alloc] initWithFrame: CGRectMake (kPNewButtonX, kPNewButtonY, kButtonWide, kButtonTall)];
	[_newButton setImage: [UIImage imageNamed: @"NewSelectedP"] forState: UIControlStateHighlighted];
	[_newButton addTarget: self action: @selector (new:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: _newButton];
	
	// Undo button.
	_undoButton = [[UIButton alloc] initWithFrame: CGRectMake (kPUndoButtonX, kPUndoButtonY, kButtonWide, kButtonTall)];
	[_undoButton setImage: [UIImage imageNamed: @"UndoSelectedP"] forState: UIControlStateHighlighted];
	[_undoButton addTarget: self action: @selector (undo:) forControlEvents: UIControlEventTouchUpInside];
	[_undoButton addTarget: self action: @selector (undoDown:) forControlEvents: UIControlEventTouchDown];
	[_undoButton addTarget: self action: @selector (undoDragOutside:) forControlEvents: UIControlEventTouchDragOutside];
	[self.view addSubview: _undoButton];
	
	// Info button.
	_infoButton = [[UIButton alloc] initWithFrame: CGRectMake (kPInfoButtonX, kPInfoButtonY, kButtonWide, kButtonTall)];
	[_infoButton setImage: [UIImage imageNamed: @"InfoSelectedP"] forState: UIControlStateHighlighted];
	[_infoButton addTarget: self action: @selector (info:) forControlEvents: UIControlEventTouchUpInside];
	[self.view addSubview: _infoButton];
	
	// Create "dark view" and lay over the entire card table and cards. It is only used to fade out the card table 
	// when the "Info" view is put up. It ignores user interaction.
	_darkView = [[UIView alloc] initWithFrame: mainBounds];
	_darkView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.0];
	_darkView.userInteractionEnabled = NO;
	[self.view addSubview: _darkView];
	
	// Indicate the dark view as the overlaying view. This prevetns card animation from happening above of this view.
	_overlayingView = _darkView;
	
	// Create storage for worried cards.
	_worriedCards = [[NSMutableArray alloc] initWithCapacity: 3];
	
	// Load sounds.
	audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"Shuffle" ofType: @"wav"]];
	_shufflePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
	require (_shufflePlayer, skipAudio);
	[_shufflePlayer prepareToPlay];
	
	// Load "draw card" sounds.
	for (i = 0; i < kNumCardDrawSounds; i++)
	{
		audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"CardDraw%d", i] ofType: @"wav"]];
		_cardDrawPlayers[i] = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
		require (_cardDrawPlayers[i], skipAudio);
		[_cardDrawPlayers[i] prepareToPlay];
	}

	// Load "place card" sounds.
	for (i = 0; i < kNumCardPlaceSounds; i++)
	{
		audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: [NSString stringWithFormat: @"CardPlace%d", i] ofType: @"wav"]];
		_cardPlacePlayers[i] = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
		require (_cardPlacePlayers[i], skipAudio);
		[_cardPlacePlayers[i] prepareToPlay];
	}
	
	// Click sounds.
	audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"ClickOpen" ofType: @"wav"]];
	_clickOpenSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
	require (_clickOpenSoundPlayer, skipAudio);
	[_clickOpenSoundPlayer prepareToPlay];
	
	audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"ClickClose" ofType: @"wav"]];
	_clickCloseSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
	require (_clickCloseSoundPlayer, skipAudio);
	[_clickCloseSoundPlayer prepareToPlay];
	
	// Undo sound.
	audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"Blip" ofType: @"wav"]];
	_undoSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
	require (_undoSoundPlayer, skipAudio);
	[_undoSoundPlayer prepareToPlay];

	// Player won sound.
	audioURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"Babip" ofType: @"wav"]];
	_winSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: audioURL error: &error];
	require (_winSoundPlayer, skipAudio);
	[_winSoundPlayer prepareToPlay];
	
skipAudio:
	
	// Create local player object.
	_localPlayer = [[LocalPlayer alloc] init];
	_localPlayer.delegate = self;
	_leaderboardPlayerIDs = [[NSMutableArray alloc] initWithCapacity: 3];
	_leaderboardGamesPlayed = [[NSMutableArray alloc] initWithCapacity: 3];
	_leaderboardGamesWon = [[NSMutableArray alloc] initWithCapacity: 3];
	
	// Create a card dealer object.
	_stockDealer = [[CECardDealer alloc] init];
	_stockDealer.delegate = self;
	
	// Listen for these.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (willDragCardToStack:) 
			name: StackViewWillDragCardToStackNotification object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (cardDragged:) 
			name: StackViewDidDragCardToStackNotification object: nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (cardPickedUp:) 
			name: StackViewCardPickedUpNotification object: nil];
	
	_splashDismissed = NO;
}

// -------------------------------------------------------------------------------------------------------- restoreState

- (void) restoreState
{
	// Initial card layout.
	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"SavedGame"] == YES)
	{
		BOOL			success;
		NSUserDefaults	*defaults;
		
		success = [(CETableView *) self.view restoreStackStateWithIdentifier: @"ParlourSolitaire"];
		
		defaults = [NSUserDefaults standardUserDefaults];
		_playedAtleastOneCard = [defaults boolForKey: @"PlayedAtleastOneCard"];
		if ([defaults objectForKey: @"CardsToDeal"] != nil)
			_cardsToDeal = [defaults integerForKey: @"CardsToDeal"];
		else
			_cardsToDeal = 3;
		if ((_cardsToDeal != 1) && (_cardsToDeal != 3))
			_cardsToDeal = 3;
		_cardsToDealDesired = _cardsToDeal;
		if (_cardsToDeal == 3)
		{
			_gamesPlayedCategory = @"com.softdorothy.parloursolitaire.games_played_3";
			_gamesWonCategory = @"com.softdorothy.parloursolitaire.games_won_3";
		}
		else
		{
			_gamesPlayedCategory = @"com.softdorothy.parloursolitaire.games_played_1";
			_gamesWonCategory = @"com.softdorothy.parloursolitaire.games_won_1";
		}
		
		[_worriedCards removeAllObjects];
		[_worriedCards addObjectsFromArray: [defaults arrayForKey: @"WorriedCards"]];
		
		// Sanity check.
		if ((success == NO) || ([self countOfCardsOnTable] != 52))
			[self resetTable: YES];
	}
	else
	{
		[self resetTable: YES];
	}
}

// ------------------------------------------------------------------------------------------------ openSplashAfterDelay

- (void) openSplashAfterDelay
{
	[self performSelector: @selector (info:) withObject: nil afterDelay: 0.5];
}

// ----------------------------------------------------------------------------------------------------------- saveState

- (void) saveState
{
	// Determine if we have a game in progress.
	if (([[_foundationViews[0] stack] numberOfCards] < 13) || ([[_foundationViews[1] stack] numberOfCards] < 13) || 
			([[_foundationViews[2] stack] numberOfCards] < 13) || ([[_foundationViews[3] stack] numberOfCards] < 13))
	{
		[[NSUserDefaults standardUserDefaults] setBool: YES forKey: @"SavedGame"];
		[(CETableView *) self.view archiveStackStateWithIdentifier: @"ParlourSolitaire"];
		[[NSUserDefaults standardUserDefaults] setBool: _playedAtleastOneCard forKey: @"PlayedAtleastOneCard"];
		[[NSUserDefaults standardUserDefaults] setObject: _worriedCards forKey: @"WorriedCards"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"SavedGame"];
		[[NSUserDefaults standardUserDefaults] setBool: NO forKey: @"PlayedAtleastOneCard"];
	}
}

#pragma mark ------ view controller methods
// ------------------------------------------------------------- willRotateToInterfaceOrientation:toInterfaceOrientation

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orientation duration: (NSTimeInterval) duration
{
	[self adjustLayoutForOrientation: orientation];
}

/*
- (void) willAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toOrientation duration: (NSTimeInterval) duration
{
}

- (void) didAnimateFirstHalfOfRotationToInterfaceOrientation: (UIInterfaceOrientation) toOrientation
{
}

- (void) willAnimateSecondHalfOfRotationFromInterfaceOrientation: (UIInterfaceOrientation) fromOrientation duration: (NSTimeInterval) duration
{
}
*/

// ------------------------------------------------------------------------------ shouldAutorotateToInterfaceOrientation

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation
{
	return YES;
}

// --------------------------------------------------------------------------------------------- didReceiveMemoryWarning

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

// ------------------------------------------------------------------------------------------------------- viewDidUnload

- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[_newButton release];
	[_undoButton release];
	[_infoButton release];
}

// ------------------------------------------------------------------------------------------------------------- dealloc

- (void) dealloc
{
	// No more observing.
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	// Clean up timers.
	if (_computerTaskTimer)
		[_computerTaskTimer invalidate];
	_computerTaskTimer = nil;
	if (_undoHeldTimer)
		[_undoHeldTimer invalidate];
	_undoHeldTimer = nil;
	
	// Super.
	[super dealloc];
}


#pragma mark ------ alert view delegate methods
//--------------------------------------------------------------------------------------- alertView:clickedButtonAtIndex

- (void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (alertView.tag == kResetTableAlertTag)
	{
		if (buttonIndex == 1)
		{
			if (_playSounds)
				[_shufflePlayer play];
			
			[self resetTable: YES];
		}
	}
	else if (alertView.tag == kUndoAllAlertTag)
	{
		_undoAllAlertOpen = NO;
		
		if (buttonIndex == 1)		// Undo all.
		{
			if (_playSounds)
				[_shufflePlayer play];
			
			[self resetTable: NO];
		}
	}
}

#pragma mark ------ card dealer delegate methods
// --------------------------------------------------------------------------------------------- cardDealerCompletedDeal

- (void) cardDealerCompletedDeal: (CECardDealer *) dealer
{
	_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self 
			selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
}

#pragma mark ------ stack view delegate methods
// --------------------------------------------------------------------------------------------- stackView:allowDragCard

- (BOOL) stackView: (CEStackView *) stackView allowDragCard: (CECard *) card
{
	NSUInteger	cardIndex;
	NSUInteger	cardCount;
	NSUInteger	numberOfCardsDragging;
	int			i;
	CECard		*cardTesting;
	BOOL		allowDrag = NO;
	
#if DISALLOW_TOUCHES_IF_ANIMATION
	// Skip out if any stack is animating. For example, when the game is wrapping up, a lot of cards are flying up to 
	// the foundation, you would not allow a card to be dragged at this time.
	if ([(CETableView *) self.view animationInProgress])
		return NO;
#endif	// DISALLOW_TOUCHES_IF_ANIMATION
	
	// Disallow dragging from the stock pile.
	if (stackView == _stockView)
		return NO;
	
	// If there are still cards being placed on the waste, do not allow a drag to be initiated from the waste.
	if ((stackView == _wasteView) && (_stockDealer.dealing))
		return NO;
	
	// We allow dragging back from the foundation ("worrying back" a card). We have to mark it as such though if 
	// auto-putaway is true (since, it will just get put up again).
	if ((_autoPutaway) && ([[stackView identifier] isEqualToString: @"Foundation"]))
	{
		[self worryBackCard: card];
		return YES;
	}
	
	// A card is being delivered to this stack (promised). Player must wait.
	if ([stackView isCardPromised])
		return NO;
	
	// The player will always be allowed to drag the top card of a stack.
	if (card == [[stackView stack] topCard])
	{
		allowDrag = YES;
		goto done;
	}
	
	// Get the index of the card attempting to be dragged and the number of cards in the stack.
	cardIndex = [[stackView stack] indexForCard: card];
	cardCount = [[stackView stack] numberOfCards];
	
	// We determine how many cards the player is attenpting to drag.
	numberOfCardsDragging = (cardCount - cardIndex);
	
	// Validate first that each card atop the one attempting to be dragged follows down in rank and alternates in color.
	for (i = cardIndex + 1; i < cardCount; i++)
	{
		cardTesting = [[stackView stack] cardAtIndex: i];
		
		// Can't drag if the color sequence of the stack do not alternate.
		if ([card cardIsOppositeColor: cardTesting] == NO)
			goto done;
		
		// The card rank must increase exactly by one.
		if ((cardTesting.rank + 1) != card.rank)
			goto done;
		
		// This will be the card to test for in the next pass through the loop.
		card = cardTesting;
	}
	
	allowDrag = YES;
	
done:
	
	return allowDrag;
}

// --------------------------------------------------------------------------------- stackView:allowDragCard:toStackView

- (BOOL) stackView: (CEStackView *) stackView allowDragCard: (CECard *) card toStackView: (CEStackView *) dest
{
	CECard	*topDestCard;
	BOOL	allow = NO;
	
	// We do not allow any card to be dragged to the 'stock' and 'waste' stacks.
	if ((dest == _stockView) || (dest == _wasteView))
		goto bail;
	
#if DISALLOW_DRAGTO_IF_ANIMATION
	if ([(CETableView *) self.view animationInProgress])
		goto bail;
#endif	// DISALLOW_DRAGTO_IF_ANIMATION
	
	// What is the top card on the stack view the pkayer is dragging to?
	topDestCard = [[dest stack] topCard];
	
	// Do we have a top card (if not, we're dragging to an empty stack)?
	if (topDestCard)
	{
		// If there is a card (the destination stack is not empty).
		// Handle the case when the destination stack is the foundation.
		if ([[dest identifier] isEqualToString: @"Foundation"])
		{
			// The card being dragged must be one rank higher than the top card on the foundation, and match its suit.
			if ((card.rank == (topDestCard.rank + 1)) && (card.suit == topDestCard.suit) && ([[stackView stack] topCard] == card))
			{
				allow = YES;
				goto bail;
			}
		}
		else
		{
			// If the stack is the tableau, the rank of the card being dragged must be one smaller and opposite in color.
			allow = (((card.rank + 1) == topDestCard.rank) && ([card cardIsOppositeColor: topDestCard] == YES));
			goto bail;
		}
	}
	else
	{
		// Empty stack. Allow an ace only on foundations, allow only a King on empty tableau columns.
		if ([[dest identifier] isEqualToString: @"Foundation"])
		{
			// Foundation - since no card on foundation, card dragged in must be an Ace.
			if ((card.rank == kCERankAce) && (dest == _foundationViews[card.suit]) && ([[stackView stack] topCard] == card))
			{
				allow = YES;
				goto bail;
			}
		}
		else if ([[dest identifier] isEqualToString: @"Tableau"])
		{
			// Tableau - since no card in tableau column, dragged card must be a King.
			if (card.rank == kCERankKing)
			{
				allow = YES;
				goto bail;
			}
		}
	}
	
bail:
	
	return allow;
}

// -------------------------------------------------------------------------------------------- stackView:cardWasTouched

- (void) stackView: (CEStackView *) view cardWasTouched: (CECard *) card
{
	NSTimeInterval	delay;
	BOOL			cardMoved = NO;
	
	// If the card is not on top of stack, tap is ignored.
	if ([view.stack topCard] != card)
		return;
	
	if (view == _stockView)
	{
		// Handle touches to stock.
		if (card == nil)
		{
			// Play sound of card being placed.
			// WE SHOULD PREFERABLY HAVE A SOUND OF RETURNING THE WASTE TO STOCK. THIS WILL DO FOR NOW.
			[self playCardPlacedSound];
			
			// No cards in Stock - move cards from Waste back to Stock.
			[self startingCardMoving];
			
			// Register Undo action for transferring Waste back to Stock (Undo will move Stock to Waste).
			[[CETableView sharedCardUndoManager] registerUndoWithTarget: _stockView.stack 
					selector: @selector (removeAllCards) object: nil];
			[[CETableView sharedCardUndoManager] registerUndoWithTarget: _wasteView.stack 
					selector: @selector (addAllCardsFromStackFaceUp:) object: _stockView.stack];
			
			// Move cards from Waste back to Stock.			
			[_stockView.stack addAllCardsFromStack: _wasteView.stack faceUp: NO];
			[_wasteView.stack removeAllCards];
			delay = kTaskIntervalAfterReturnWaste;
			
			// Fire off timer to check for cards that can be put up in the foundation.
			_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: delay 
					target: self selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
		}
		else if (_stockDealer.dealing == NO)
		{
			[self startingCardMoving];
			[_stockDealer dealCardsFromStackView: _stockView toStackView: _wasteView count: _cardsToDeal];
			
			// Not really but since we evaluate whether the game is over, I may need to present the game over alert.
			cardMoved = YES;
		}
	}
	
	// Indicate a card was moved.
	if ((cardMoved) && (_playedAtleastOneCard == NO))
		[self noteAtleastOneCardMoved];
}

// --------------------------------------------------------------------------------------- stackView:cardWasDoubleTapped

- (void) stackView: (CEStackView *) stackView cardWasDoubleTapped: (CECard *) card
{
	CEStackView	*foundationView;
	NSInteger	i;
	BOOL		cardMoved = NO;
	
	// Only double-tap on top card is allowed.
	if ([[stackView stack] topCard] != card)
		return;
	
	// Disallow double-tapping on the stock pile.
	if (stackView == _stockView)
		return;
	
	// Disallow double-tapping the foundation if auto-putaway is true (since, it will just get put up again).
	if ((_autoPutaway) && ([[stackView identifier] isEqualToString: @"Foundation"]))
		return;
	
#if DISALLOW_TOUCHES_IF_ANIMATION
	// Skip out if any stack is animating.
	if ([(CETableView *) self.view animationInProgress])
		return;
#endif	// DISALLOW_TOUCHES_IF_ANIMATION
	
	// If there are still cards being placed on the waste, do not allow for a double-tap on the waste.
	if ((stackView == _wasteView) && (_stockDealer.dealing))
		return;
	
	// Check first to see if card can be put up in the foundation.
	if (_autoPutawayMode == kAutoPutawayModeSmart)
		foundationView = [self foundationToPutAwayCardSmart: card];
	else
		foundationView = [self foundationToPutAwayCardAll: card];
	if (foundationView != nil)
	{
		[self startingCardMoving];
		[stackView dealTopCardToStackView: _foundationViews[card.suit] faceUp: YES duration: kDealAnimationDuration];
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kDealAnimationDelay]];
		cardMoved = YES;
		goto done;
	}
	
	// If the card double-tapped is in a tableau, assume the player wants the card to be put up in the foundation, not,
	// for example, just moved to another tableau column.
	if ([[stackView identifier] isEqualToString: @"Tableau"])
	{
		foundationView = [self foundationToPutAwayCardAll: card];
		if (foundationView != nil)
		{
			[self startingCardMoving];
			[stackView dealTopCardToStackView: _foundationViews[card.suit] faceUp: YES duration: kDealAnimationDuration];
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kDealAnimationDelay]];
			cardMoved = YES;
			goto done;
		}
	}
	
	// Check next for a match on an occupied tableau column.
	for (i = 0; i < 7; i++)
	{
		CECard	*topCard;
		
		// Get top card for tableau column. Skip if no cards in column
		topCard = [_tableauViews[i].stack topCard];
		if (topCard == nil)
		{
			// Empty column, only Kings may be placed in an empty column.
			if (card.rank == kCERankKing)
			{
				[self startingCardMoving];
				[stackView dealTopCardToStackView: _tableauViews[i] faceUp: YES duration: kDealAnimationDuration];
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kDealAnimationDelay]];
				cardMoved = YES;
				goto done;
			}
		}
		else
		{
			// Test if the top card is of the opposite color and if the rank is one larger than the card tapped on.
			if (((topCard.rank) == card.rank + 1) && ([card cardIsOppositeColor: topCard] == YES))
			{
				[self startingCardMoving];
				[stackView dealTopCardToStackView: _tableauViews[i] faceUp: YES duration: kDealAnimationDuration];
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kDealAnimationDelay]];
				cardMoved = YES;
				goto done;
			}
		}
	}
	
	// Check finally to see if card can be put up in the foundation using "all" mode. Since a double-tap is a very 
	// deliberate act by the player, override "smart" putaway option and go for the looser "all" mode if we make it here.
	if (_autoPutawayMode == kAutoPutawayModeSmart)
	{
		foundationView = [self foundationToPutAwayCardAll: card];
		if (foundationView != nil)
		{
			[self startingCardMoving];
			[stackView dealTopCardToStackView: _foundationViews[card.suit] faceUp: YES duration: kDealAnimationDuration];
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: kDealAnimationDelay]];
			cardMoved = YES;
			goto done;
		}
	}
	
done:
	
	// Indicate a card was moved.
	if ((cardMoved) && (_playedAtleastOneCard == NO))
		[self noteAtleastOneCardMoved];
	
	// Fire off the computer task timer.
	if (cardMoved)
	{
		// Fire off timer to check for cards that can be put up in the foundation.
		_computerTaskTimer = [NSTimer scheduledTimerWithTimeInterval: kTaskIntervalAfterDoubleTap 
				target: self selector: @selector (computerTaskTimer:) userInfo: nil repeats: NO];
	}
}

// ------------------------------------------------------------------------------------- idealCardSeparationForStackView

- (CGFloat) idealCardSeparationForStackView: (CEStackView *) view
{
	if ([view layout] == kCEStackViewLayoutColumn)
		return 42.0;
	else if ([view layout] == kCEStackViewLayoutBiasedColumn)
		return 42.0;
	else
		return -1.0;
}

// --------------------------------------------------------------------------------- idealCardBiasSeparationForStackView

- (CGFloat) idealCardBiasSeparationForStackView: (CEStackView *) view
{
	return 12.0;
}

// --------------------------------------------------------------------------------------------- stackViewOverlayingView

- (UIView *) stackViewOverlayingView: (CEStackView *) view
{
	return _overlayingView;
}

#pragma mark ------ notification methods
// ------------------------------------------------------------------------------------------------- willDragCardToStack

- (void) willDragCardToStack: (NSNotification *) notification
{
	[self startingCardMoving];
}

// --------------------------------------------------------------------------------------------------------- cardDragged

- (void) cardDragged: (NSNotification *) notification
{
	// Play sound of card being placed.
	[self playCardPlacedSound];
	
	if (_playedAtleastOneCard == NO)
		[self noteAtleastOneCardMoved];
	
	// Flip and put-away cards.
	[self determineIfCardsCanBePutAway];
	
	// See if the game is a wrap.
	[self checkGameState];
}

// -------------------------------------------------------------------------------------------------------- cardPickedUp

- (void) cardPickedUp: (NSNotification *) notification
{
	// Play sound of card being dragged.
	[self playCardDrawSound];
}

// ------------------------------------------------------------------------------------ stackView:beginAnimatingCardMove

- (void) stackView: (CEStackView *) view beginAnimatingCardMove: (CECard *) card
{
	// Play sound of card being dragged.
	[self playCardDrawSound];
}

// ------------------------------------------------------------------------------------ stackView:beginAnimatingCardFlip

- (void) stackView: (CEStackView *) view beginAnimatingCardFlip: (CECard *) card
{
	// Play sound of card being dragged.
	[self playCardDrawSound];
}

// --------------------------------------------------------------------------------- stackView:finishedAnimatingCardMove

- (void) stackView: (CEStackView *) view finishedAnimatingCardMove: (CECard *) card
{
	// Play sound of card being placed.
	[self playCardPlacedSound];
}

// --------------------------------------------------------------------------------- stackView:finishedAnimatingCardFlip

- (void) stackView: (CEStackView *) view finishedAnimatingCardFlip: (CECard *) card
{
	// Play sound of card being placed.
	[self playCardPlacedSound];
}

// --------------------------------------------------------------------------------------------------- computerTaskTimer

- (void) computerTaskTimer: (NSTimer *) timer
{
	// Clean up timer.
	[timer invalidate];
	_computerTaskTimer = nil;
	
	// See if any cards can be put away.
	[self determineIfCardsCanBePutAway];
	
	// See if the game is a wrap.
	[self checkGameState];
}

#pragma mark ------ LocalPlayer delegate methods
// -------------------------------------------------------------------------------------------- localPlayerAuthenticated

- (void) localPlayerAuthenticated: (LocalPlayer *) player
{
	[_localPlayer retrieveLeaderboardScores: kMaxLeaderboardScores forCategory: _gamesWonCategory 
			friendsOnly: _leaderboardFriendsOnly];
	
	// Fetch player's leaderboard score.
	[_localPlayer retrieveLeaderboardScoreForLocalPlayerForCategory: _gamesPlayedCategory];
	[_localPlayer retrieveLeaderboardScoreForLocalPlayerForCategory: _gamesWonCategory];
}

// --------------------------------------------------------------------------- localPlayer:failedAuthenticationWithError
// This can be called if the player disconnects from 
// GameCenter while we were in the background.

- (void) localPlayer: (LocalPlayer *) player failedAuthenticationWithError: (NSError *) error
{
	// Empty leaderboard arrays.
	[_leaderboardPlayerIDs removeAllObjects];
	[_leaderboardGamesPlayed removeAllObjects];
	[_leaderboardGamesWon removeAllObjects];
	[_leaderboardAliases release];
	_leaderboardAliases = nil;
	_playerLeaderboardIndex = NSNotFound;
	
	// Update the UI.
	[self updateGlobalScoresInterface];
}

// -------------------------------------------------------------------------------------------- copyPlayerIDs:toOurArray

- (void) copyPlayerIDs: (NSArray *) players toOurArray: (NSMutableArray *) ourPlayers
{
	// Copy the leaderboard data.
	[ourPlayers removeAllObjects];
	if (players)
		[ourPlayers addObjectsFromArray: players];
}

// ------------------------------------------------------------------------------------ copyLeaderboardScores:toOurArray

- (void) copyLeaderboardScores: (NSArray *) scores toOurArray: (NSMutableArray *) ourScores
{
	// Copy the leaderboard data.
	[ourScores removeAllObjects];
	if (scores)
		[ourScores addObjectsFromArray: scores];
}

// -------------------------------------------------------------- mergeLocalPlayerScoreWithLeaderboardScores:forCategory

- (NSUInteger) mergeLocalPlayerScoreWithLeaderboardScores: (NSMutableArray *) leaderboard forCategory: (NSString *) category
{
	NSInteger	index = 0;
	NSUInteger	playerIndex = NSNotFound;
	
	for (NSString *playerID in _leaderboardPlayerIDs)
	{
		if ([playerID isEqualToString: _localPlayer.playerID])
		{
			NSInteger	localScore;
			
			// Get local score.
			[_localPlayer retrieveLocalScore: &localScore forCategory: category];
			if ([leaderboard count] > index)
			{
				NSInteger	leaderboardValue;
				
				leaderboardValue = [[leaderboard objectAtIndex: index] integerValue];
				if (localScore > leaderboardValue)
					[leaderboard replaceObjectAtIndex: index withObject: [NSString stringWithFormat: @"%d", localScore]];
				else if (leaderboardValue > localScore)
					[_localPlayer postLocalScore: leaderboardValue forCategory: category];
			}
			else
			{
				[leaderboard addObject: [NSString stringWithFormat: @"%d", localScore]];
			}
			
			playerIndex = index;
			break;
		}
		
		index += 1;
	}
	
	return playerIndex;
}

// -------------------------------------------------------- localPlayer:retrievedLeaderboardScores:playerIDs:forCategory

- (void) localPlayer: (LocalPlayer *) player retrievedLeaderboardScores: (NSArray *) scores 
		playerIDs: (NSArray *) players forCategory: (NSString *) category
{
	if ([category isEqualToString: _gamesWonCategory])
	{
		// Copy the playerID data.
		[self copyPlayerIDs: players toOurArray: _leaderboardPlayerIDs];
		
		// Copy the leaderboard data.
		[self copyLeaderboardScores: scores toOurArray: _leaderboardGamesWon];
		
		// If our local score is greater than the leaderboard score, substitute our local score in the games-won array.
		_playerLeaderboardIndex = [self mergeLocalPlayerScoreWithLeaderboardScores: _leaderboardGamesWon forCategory: category];
		
		// Fetch the number of games won for the leaderboard players.
		[_localPlayer retrieveLeaderboardScoresForPlayerIDs: _leaderboardPlayerIDs forCategory: _gamesPlayedCategory];
	}
	else if ([category isEqualToString: _gamesPlayedCategory])
	{
		// Copy the leaderboard data.
		[self copyLeaderboardScores: scores toOurArray: _leaderboardGamesPlayed];
		
		// If our local score is greater than the leaderboard score, substitute our local score in the games-played array.
		if (_playerLeaderboardIndex != NSNotFound)
			[self mergeLocalPlayerScoreWithLeaderboardScores: _leaderboardGamesPlayed forCategory: category];
		
		// Fetch the names for the player ID's.
		if ((_leaderboardPlayerIDs) && ([_leaderboardPlayerIDs count] > 0))
		{
			[_localPlayer retrieveAliasesForPlayerIDs: _leaderboardPlayerIDs];
		}
		else
		{
			[_leaderboardAliases release];
			_leaderboardAliases = nil;
			[self updateGlobalScoresInterface];
		}
	}
}

// ----------------------------------------------------------------- retrievedLeaderboardScoreForLocalPlayer:forCategory

- (void) localPlayer: (LocalPlayer *) player retrievedLeaderboardScoreForLocalPlayer: (int64_t) score forCategory: (NSString *) category
{
	if ([category isEqualToString: _gamesWonCategory])
	{
		NSInteger	gamesWon;
		
		[_localPlayer retrieveLocalScore: &gamesWon forCategory: _gamesWonCategory];
		if (score > gamesWon)
			[_localPlayer postLocalScore: score forCategory: _gamesWonCategory];
	}
	else if ([category isEqualToString: _gamesPlayedCategory])
	{
		NSInteger	gamesPlayed;
		
		[_localPlayer retrieveLocalScore: &gamesPlayed forCategory: _gamesPlayedCategory];
		if (score > gamesPlayed)
			[_localPlayer postLocalScore: score forCategory: _gamesPlayedCategory];
	}
}

// ---------------------------------------------------------------------------- localPlayer:retrievedAliasesForPlayerIDs

- (void) localPlayer: (LocalPlayer *) player retrievedAliasesForPlayerIDs: (NSArray *) aliases
{
	// Toss previous alias array.
	[_leaderboardAliases release];
	_leaderboardAliases = nil;
	if (aliases)
		_leaderboardAliases = [aliases copy];
	
	// Update the UI.
	[self updateGlobalScoresInterface];
}

// -------------------------------------------------------------------- localPlayer:failedRetrieveScoreForCategory:error

- (void) localPlayer: (LocalPlayer *) player failedRetrieveScoreForCategory: (NSString *) category error: (NSError *) error
{
	printf ("localPlayer:failedRetrieveScoreForCategory:error: %s\n", [[error description] cStringUsingEncoding: NSUTF8StringEncoding]);
}

// ------------------------------------------------------------------------ localPlayer:failedPostScoreForCategory:error

- (void) localPlayer: (LocalPlayer *) player failedPostScoreForCategory: (NSString *) category error: (NSError *) error
{
	printf ("localPlayer:failedPostScoreForCategory:error: %s\n", [[error description] cStringUsingEncoding: NSUTF8StringEncoding]);
}

// ----------------------------------------------------------------------- localPlayer:failedRetrieveAliasesForPlayerIDs

- (void) localPlayer: (LocalPlayer *) player failedRetrieveAliasesForPlayerIDs: (NSError *) error
{
	printf ("localPlayer:failedRetrieveAliasesForPlayerIDs: %s\n", [[error description] cStringUsingEncoding: NSUTF8StringEncoding]);
}

@end
