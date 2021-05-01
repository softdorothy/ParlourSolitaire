// =====================================================================================================================
//  ParlourSolitaireViewController.h
// =====================================================================================================================


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "CardEngine.h"
#import "LocalPlayer.h"


#define kNumCardDrawSounds		4
#define kNumCardPlaceSounds		4


@class PSStackView;


@interface ParlourSolitaireViewController : UIViewController <CEStackViewDelegate,CECardDealerDelegate, LocalPlayerDelegate>
{
	PSStackView				*_stockView;
	PSStackView				*_wasteView;
	PSStackView				*_foundationViews[4];	
	PSStackView				*_tableauViews[7];
	UIButton				*_newButton;
	UIButton				*_undoButton;
	UIButton				*_infoButton;
	UIInterfaceOrientation	_orientation;
	NSTimer					*_computerTaskTimer;
	NSTimer					*_undoHeldTimer;
	BOOL					_undoAllAlertOpen;
	CECardDealer			*_stockDealer;
	BOOL					_playedAtleastOneCard;
	BOOL					_gameWon;
	NSInteger				_cardsToDeal;
	NSInteger				_cardsToDealDesired;
	BOOL					_warnedAboutCardsToDeal;
	BOOL					_autoPutaway;
	NSInteger				_autoPutawayMode;
	BOOL					_playSounds;
	BOOL					_wasAutoPutaway;
	NSInteger				_wasAutoPutawayMode;
	BOOL					_infoViewIsOpen;
	BOOL					_splashDismissed;
	BOOL					_beginningCardMoves;
	NSMutableArray			*_worriedCards;
	
	LocalPlayer				*_localPlayer;
	NSMutableArray			*_leaderboardPlayerIDs;
	NSMutableArray			*_leaderboardGamesPlayed;
	NSMutableArray			*_leaderboardGamesWon;
	NSArray					*_leaderboardAliases;
	BOOL					_leaderboardFriendsOnly;
	NSUInteger				_playerLeaderboardIndex;
	NSString				*_gamesPlayedCategory;
	NSString				*_gamesWonCategory;
	
	AVAudioPlayer			*_shufflePlayer;							// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_cardDrawPlayers[kNumCardDrawSounds];		// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_cardPlacePlayers[kNumCardPlaceSounds];	// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_clickOpenSoundPlayer;						// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_clickCloseSoundPlayer;					// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_undoSoundPlayer;							// NOTE: NEED TO RELEASE
	AVAudioPlayer			*_winSoundPlayer;							// NOTE: NEED TO RELEASE
	UIImageView				*_dealImageView;
	UIView					*_currentInfoView;
	UIView					*_darkView;
	UIView					*_infoView;
	IBOutlet UIView			*_aboutView;
	IBOutlet UIView			*_settingsView;
	IBOutlet UIView			*_rulesView;
	IBOutlet UIView			*_gameOverView;
	UIView					*_overlayingView;
	IBOutlet UIButton		*_autoPutawayButton;
	IBOutlet UIButton		*_allPutawayButton;
	IBOutlet UIButton		*_smartPutawayButton;
	IBOutlet UILabel		*_smartPutawayModeLabel;
	IBOutlet UIImageView	*_putawaySelectedImage;
	IBOutlet UIButton		*_playSoundsButton;
	IBOutlet UILabel		*_gamesPlayedLabel;
	IBOutlet UILabel		*_gamesWonLabel;
	IBOutlet UILabel		*_gamesWonPercentageLabel;
	IBOutlet UIButton		*_dealThreeButton;
	IBOutlet UIButton		*_dealOneButton;
	IBOutlet UIImageView	*_cardsToDealSelectedImage;	
	IBOutlet UILabel		*_leaderboard1Label;
	IBOutlet UILabel		*_leaderboard3Label;
	IBOutlet UILabel		*_displayScopeLabel;
	IBOutlet UIButton		*_friendScopeButton;
	IBOutlet UIButton		*_allScopeButton;
	IBOutlet UIImageView	*_scopeSelectedImage;
	IBOutlet UILabel		*_globalScoreNameLabel;
	IBOutlet UILabel		*_globalScorePlayedLabel;
	IBOutlet UILabel		*_globalScoreWonLabel;
	IBOutlet UILabel		*_globalScorePercentLabel;
	IBOutlet UIImageView	*_highlightView;
}

- (void) createCardTableLayout;
- (void) restoreState;
- (void) openSplashAfterDelay;
- (void) saveState;

- (IBAction) info: (id) sender;
- (IBAction) aboutInfo: (id) sender;
- (IBAction) settingsInfo: (id) sender;
- (IBAction) rulesInfo: (id) sender;
- (IBAction) closeInfo: (id) sender;
- (IBAction) openLabSolitaireInAppStore: (id) sender;
- (IBAction) openGliderInAppStore: (id) sender;
- (IBAction) setNumberOfCardsToDeal: (id) sender;
- (IBAction) toggleAutoPutaway: (id) sender;
- (IBAction) selectAutoPutawayMode: (id) sender;
- (IBAction) toggleSound: (id) sender;
- (IBAction) selectLeaderboardScope: (id) sender;
- (IBAction) openGameOverView: (id) sender;

@end
