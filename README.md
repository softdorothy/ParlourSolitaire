# ParlourSolitaire
An iOS iPad solitaire game from 2011.

I wrote this classic solitaire game (*patience*) for fun using a card engine I created. I wanted the game to look pretty and realistic to depart from the rather garish computer solitaire games we grew up playing. There were other things that I disliked in other soliatire games, like a timer, that I sought to avoid. I also dislike solitaire games that immediately tell you when you **have no moves** rather than let the user make that determination.

Of the variations of solitary card games, Patience (this one) is admittedly probably my least favorite. Probably because I lose so often.

![Screenshot](https://github.com/softdorothy/ParlourSolitaire/blob/main/Screenshots/Screenshot1.png)

## The Look

As you can see, skeuomorphism (unapologetically) reigned.

It was fun to come up with a *theme* for the soliatire game (as I would come up with different themes for other solitaire variations). Once I had decided on a young woman's parlour around 100 years ago, trips to antique stores would see me return with a small teacup, costume jewelry, etc.

A piece of cherry playwood I finished, covered over with a vintage tablecloth and various bits of antique store paraphenalia arranged around... I suspended a digital SLR above and photographed the backdrop for the game.

A blank piece of paperstock in the lower left served as the background for  (limited) user controls.

As you can see, the card back and fronts were chosen too to fit *the period*. To make the cards look more at home on the background I had to white-adjust the artwork a touch and add a bit of *grime* so they would not appear too perfect. Also, as you can see in code in the card engine, I wanted the cards staggered just a touch when placed so that they appeared more as though a human had placed the cards rather than an algorithm.

## Card Engine

The card engine I used in both this solitaire games and others I based around the idea of "stacks" of cards.

The simplest representation: the initial deck of cards is a *stack*, or collection, of all 52 cards. If there is a discard pile, it too is a stack of cards, initially empty.

If you look at `CEStack.h` you'll get an idea of how you can move cards from one stack to another, shuffle a stack, etc. *Dealing* cards with these models would be a matter of pulling cards off the shuffled "deck" stack and adding them to "player hands" stacks.

For models like `CEStack` there are corresponding views like `CEStackView` that define the visual properties of the stack of cards, handle touch events, etc. As an example, `CEStackView.layout` indicates whether a stack of cards is visually spread out in a vertical column or stacked one atop another, etc. The `CEStackView` also gives the stack of cards a location on the screen, and has a `CEStackViewDelegate` where game logic can be implemented (e.g. `- (BOOL)[CEStackView allowDragCard]`).

You can start to then look at a game like Patience and break it down into: four foundation stacks across the top, seven vertical stacks for the tableau, a deal stack and discard stack. That layout, plus a thin bit of logic in a delegate to allow or disallow a user from dragging a card from one stack to another is really all there is to define this specific variation of solitaire.