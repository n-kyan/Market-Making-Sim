$$
\newcommand{\I}{I_t}
\newcommand{\Ik}{\bar{I}_t}
\newcommand{\Iku}{\mathcal{I}}
$$

# What is Market Making

Rather than making directional bets, a market maker will place limit orders to both buy and sell some asset. Its bid (buy offer) will sit below their perceived fair value of the asset and its ask (sell offer) will sit above it. If both sides of your orders are filled then the market maker earns the different between the two.

There are a variety of things that make this business difficult to execute profitably. Fundamentally, others traders are unpredictable on an individual level and therefore the market maker's order may not be filled in an ideal way. For example, they might be filled on their bids several times in a row resulting in accumulation of assets that hold directional risk. The manifestation of this risk is termed adverse selection. This is when the fair value of the asset moves against the position of a market makers portfolio. 



## Adverse Selection

When does a market makers quote get filled? Although there is a random chance that it gets filled, this chance significantly increases as the price aproaches the quote. Therefore, it is most likely for a quote to be filled when the price is moving toward and through it. This is the core issue of market making, where your quotes lay around a stale view of fair value and the market moves before the market maker adjusts quotes. The position a market maker acquires is a bad bet in expectation if the expected future price move is for the price to continue to move away from the fair value the market maker quoted around. This happens primarily when the market maker's counterparty has an informational edge over the market maker about where the price will be in the future.



Ok so its not thast prices never execute at the fair value when there are bid ask spread but that there is only a certain chance that it is. Both must be true since in this sim i am placing limit orders creating a bid ask spread and the market is only trading with me when the true value is equal to my limits. This is making me think though: I think that you may have given me the wrong idea. I dont think that the true fair value of something follows a random walk, why would it? i think its more that the market price basically follows a random walk the centers around the ture fair value due to things like microstructure noise. So its not that the value is a random walk but that the random walk in the price is used to approximate real noise from real things. This feels more correct to me, but its not how you have been framing it.

# What is this project?

This is a a simulated toy world where everything is under control. It is a sandbox that am building (for fun) and to learn about the engineering problem that is market making. It will allow me to experiement with various market making strategies and test out fun approaches to see how they compare to each other. Since this environment will be generated analytically, I am hypothesizing that there will be a way to calculate the exact maximum profit that can be earned given the current simulation configuration. This will allow me to grade all of my approaches on a quantitative scale.

## A Reproducible Environment

An important core characteristic of this simulation is that there will be events that are inherently random in nature on aggregate. For example, though the decision of a single trader are not random, this simulation seeks to approximate aggregated trader behavior by assuming that trades, in general, arrive randomly. Furthermore, the future price will also be random. In order to fairly compare strategy A to strategy B, the testing must be conducted with the same sequence of random events. This is crucial because it removes the possibility that one startegy performed better simply due to chance. The experiments must be controlled and structured in a way that isolated the market making strategy as the only variable.

## The Language Conundrum

There are two languages that I have considered for this project, Python and Julia. Python is arguably the most ubiquitous programming language in the world and is famously used as the main laguage used for research in quantitative finance. The downside is that is twofold. It seems less fun than using a new language like Julia, and it is also orders of magnitude slower than Julia. This simulatioon is a loop: time moves forward by one step, a handful of calculations occur and the cycle repeats. Julia also natively supports my goal of easily swapping out strategies to interact with a generic market via its multiple dispatch.

Python is slow for this particular project because as an interpreted dynamically typed language, it has computational overhead for every instruction it executes. To run a Python file, the code is compiled into an intermediary form called bytecode, then an interpreter executes it one instruction at a time. For each instruction the interpreter needs to check what type each variable is, the correct implementation of any operations, extract the number from the heap allocated object that contains the number and its type, do the arithmetic, then allocate a new object on the heap to store the result.

This is sidestepped by libraries like NumPy by making one Python level call which goes through all of the overhead steps, then calls compiled C code to actually perform all of the arithmetic on the unwrapped numbers, reducing per-element over heard to per-array overhead. This aproach won't work for the simulation because the C code has no memory, it just applies the same operation to every element of an array. This C code can't consume the output of the previous iteratino as its own input mid loop. The simulation requires the output of the previous step as input for the following step which would require Python's per-instruction overhead. Julia is a compiled language so the same code written in Julia simply does not have to go through the interpreter overhead since the code is fully compiled to executeable machine code before running, similar to if the program was just written in C to begin with. 

## Minimalism

Throughout my extensive programming experience (sarcasm), I have fallen victim many times to scope creep and premature complexity. In my experience this affliction is expotentially worse with the use of LLMs for programming, unless you know exactly what you want and exactly how to build it. A core motivation for this project is for in depth learning, implying that I am unable to fulfill the previosuly outlined criteria.

To keep my project simple and easy to understand, I will aim to only build the most simple version that satifies my current criteria before adding any additional complexity even if that means sacrificing some realism and even performance to do so. This also means that I will be writing every line of code myself, not because it is the fast way to complete this project but because the goal of this project is not purely completion, but in-depth understanding and continuous improvement. With these goals, it is paramount that my code is written simply and with clarity.

## The True Price of an Asset

The true price of an asset, in my mind, is the quatification of the value that an asset provides at a given instant in time in units of a currency. The core issue I have with this defiintion is that the value of an asset can be different to different market participants. For example, a hedge fund might want to buy put options to hedge its portfolio. Other participants in the market may not have the same exposures that they want to hedge so the put options are simply less valuable to them. Upon reflection this also has a flaw. Even though particpants without the portfolio to hedge wouldn't be using the puts to mitiage risk, they would benefit equally from these put options if they were to be purchased. After all, the put options function the same for anyone who buys them. The hedge fund might want them for hedging but mechanically, the puts are puchased to offset losses beyond a certain point. The returns that would offset these losses are of the ame value to someone without losses to offset. So perhaps my inital definition is more correct and then value of a fungible asset is independent of who the buyers and sellers actually are.

That is all to say that there exists a true price at any given instant for any asset. The actual market price of this asset is not necessarily the same due to various frictions that exist in real markets. In the simplest sense the market price of an asset is the last traded price. This of course is not indicative of which direction the price will move in going forward and is not necessarily the same price that another participant can buy or sell the asset for. Furthermore, this last traded price can be serverely dislocated from the true price due to shared, incorrect beliefs about the asset which cause the market as a whole to exchange the asset for incorrect prices. Even in the situation that the market has a correct view of the true price of the asset, the market price is still only an approximation of it. There will always be noise in the market price.

This is important for my simulation because I want to acknowledge that I should include this noisiness in the market price. I should simlutate the true price and the tradable price as distinct things but in the spirit of minimalism I will defer this to a queue of future improvements. Currently, there is nothing to cause the market price and the true value to deviate because I won't have implemented any of the frictions that cause this deviation. The first and simplest will be discrete tick size which just means that the market can only represent prices rounded to the nearest cent while the fair value is continuous.

## Value and Efficient Markets

In my opinion there are three forms of value for an asset:

1. **True Value:** The value that results from the perfect incorporation of all knowable and unknowable information about the asset.
2. **Fair Value:** The value that results from the perfect incorporation of all knowable information and perfection probabilities about unknowable information.
3. **Market Price:** An approximation of Fair Value that emerges from the transactions of individuals who all have their own approximations of fair value using the informatino they have available to them and their best gues on the probabilities of unknowable information.

$\I \subset \Ik \subset \Iku$

Where $\I$ is the information available to traders, $\Ik$ is all knowable information, and $\Iku$ is all knowable and unknowable information.

## Designing the Trader

I have decided to model individual traders rather than the market as a whole. This allows me to build up from the first principles I concluded in my "Why Traders Trade" section below. It also enables me to include as many traders as I want and control the behavior of a trader, enabling different types of market participants down the line. Below is the wokring definitions of an individual trader.

# Version 0.1.0

This version is purposefully simple even though this creates some conceptual shortcomings. The goal of this version is not to be intellectually honest or full of features, but rather to set up the foundational infrastructure and do build an end to end complete simulation loop.

## Traders

There will only be one trader in this simulation. They will have a demand for the asset that is a Float64. This demand will evolve over time and for this version will follow a random walk that is bounded at 0 and 1. When demand is equal to a bound, then the random walk becomes a 50% chance of staying there and a 50% of decreasing. They will have a corresponding demand for cash that is simply 1 - their demand for the asset. They will start with a certain amount of wealth. This wealth is distributed across the allocation options in accordance with their relative demand. If they have $100 and a demand for the asset of 0.6, they will hold $60 worth of the asset.

Trader will have a strategy attribute that can be fulfilled by any time of strategy that follows the discrete time steps and produces orders. The starting default strategy will be for the trader to immediately adjust their position to match their demand. With this this strategy, the trader will only trade under the condition that their demand for the asset changes. They will seek to rebalance their portfolio to match their current demand by trading. A trader will send market orders to the exchange to immediately rebalance at any price and in this version will always execute against my limit orders since I am the only other market participant.

 In future versions that support many traders, a trader with this strategy may be compelled to trade even if demand hasn't changed because it will be possible for the the market price for the asset to change from the trades of others, requiring a rebalance to adjust for the new values.

## Assets and Demand

There will only be one risky asset and the trader's demand for this asset will evolve over time following a random walk. Demand will be a fraction of the traders wealth to easily support different wealth levels and in the future, multiple assets and leverage.

## The Market Maker

I should be able to write various market making strategies that are easily swappable and testable. I am anticipating that a "strategy" is just something that output a bid and and ask for the asset at each time stamp after running some logic. I will also need to keep track of my investory and pnl. I am thinking now that I as the market maker should actually just be a subset of the general trader case with the additional specification of a more particular strategy. I think maybe its good to just build in a "strategy" attribute to all traders with the starting default being to immediately match shifted demand. 

## Accounting

The investory and pnl of all market participants will be tracked over time. It may be useful for trader decision making down the line and post simulation analysis.

## The Exchange

The exchange will be build to be generic from day 1. Its only job is to be a place for traders to submit orders and to match overlapping orders. In this version since the only market participants are the market maker and one trader, the exchange will take the market makers limit orders, hold them on the book and then when the trader execute a buy order, it will trade with the market maker at its ask price. When the trader submits a sell order, it will trade with the market maker at its bid price. This of course is inherently flawed since the market maker could just set arbitrarily wide quotes and the trader will always transact with then. I acknowledge this flaw, but this version is meant to set up the simulation basics not to be a intellectually defensible version. Regardless, this is not an issue with the exchange itself, but rather tha the single trader is given too simple of a strategy. 

The exchange is also responsible for constructing the market price which is simply the price at which the last transaction took place.

### Order of Operations

A critical design decision is the order in which orders are processed. If the market maker's quote are processed after the trader then the trader will have no one to trade against. In future versions, if two traders both want to trade, there needs to be a way to determine who gets proceessed first. The solution I am going to implement at this time is to have all participants make their decision based on the state of the world at the start of a timestep rather than it being dependent on the order of decisions within the timestep. To illustrate what this would look like, in this version, at time $t$ the trader will actually end up trading against the quotes from $t-1$ and the market maker will post new quotes at $t$ based on the events from $t-1$. These will be the quotes that the trader trades against in $t+1$. The only other requisite for this to work is that either the market maker needs to place some starting quotes at the beginning of the loop, or the trader just can't trade during the first timestep. Either works but I am choosing the former for this version.

## Future Features

**Multiple Traders:** Allow for there to be $n$ traders in the simulation instead of just one.

**Trader-Trader Interaction:** Allow for the possibility that traders can trade with eachother rather than just with me, the market maker.

**Exchange Robustness:** Add support for more robust trade matching and perhaps different order types from the traders. Will also need to add support for process many orders that are asking for the same thing. For example, if two traders both submit a market buy order, who gets first dibs. The solution that I will implement to begin with is to randomize the order based on some controlled RNG that I generate before the sim loop begins.

**Information:** Complete the model of the three levels of information with the static unknowable true value, the random walking fair value that converges to the true value, and the market price that noisily and "slowly" tracks the fair value. As new information becomes knowable, traders should start incorporating it into their demand for the asset. For the multi-asset implementation, I assume this would need a separate information model to couple with the market.

**Multiple Risky assets: **Rather than just having a single market where traders can buy or sell an asset, have many assets that all trade on their own markets. This means that traders will need to have relative demand for many assets, not just the binary balance of the asset and cash. The proposed approch for this is to use a softmax on unbounded underlying preferences scores that follow independent paths, to normalize them to the relevant demand scale.

**Lending and Leverage:** Rather than limiting traders to the capital that they have in wealth, allow them to use leverage by taking on debt from a separate debt market. This also opens up the opportunity for traders to allocate captal to lending to other traders. By borrowing, traders will be able to have more buying power than they have welath, but will have to pay an interest rate on the borrowed capital. The lenders will earn the interest rate on their lent capital. I think this will be super interesting and will necessitate looking into how interests rates will be determined and all the other mechanisms involved with credit. 

**Derivatives:** Add support for derivative markets like futures and options.

**Hot Swap Configs:** As initial configuration possibilities of the market grows, it will be valuable to make a system to easily swap in different setups without having to rewrite everything by hand every time.

# Other Market Concepts

## Bid-Ask Bounce and Volatiltiy Overestimation (AI - redo)

Imagine the true value is sitting still at $100.00. You're quoting $99.99 bid / $100.01 ask. A random buyer comes in and buys from you at $100.01 (a trade prints at $100.01). A moment later a random seller sells to you at $99.99 (a trade prints at $99.99). Nothing about the *true value* moved between those two trades — but if you only looked at "the price," it looks like it dropped 2 cents and then... well, there's no next tick to show it went back up, so if you were just eyeballing trade prices, you'd conclude there's more volatility than there really is.

This is a well known real effect (Roll, 1984) — naively measuring volatility from trade prices *overestimates* true volatility, purely because of this bouncing. It's a great sanity check for your simulator later: if you build it right, you should be able to observe this same bias yourself.

## Microstructure Noise

Strucutral persistant noise due to the nature of markets as means of price discovery.

### Discrete Tick Sizes

Trades only occur at discrete price level like cents while the true fair value of an assest changes continuously and is a real number. The trade value therefore is a discretization of the true fair value which adds additional noise to the market price as an approximation of the true value. 

### Bid-Ask Spread

If a trader wants to trade immediately, their only counterparty is resting limit orders. There orders rest at a value that is slightly different that the true fair value, so any trade that is executed must execute at a price that is not the market price.

## The Nested Martingale:

A martingale is a mathematically fair game where the future outcomes cannot be predicted from past outcomes. The expected value of the next step in time is equal to the current step. In accordance with my definitions of asset values. The market price is a conditional expectation of fair value given acessible information, the fair value is a conditional expectation of the true value given all currently knowable information. With an expected return of 0 from the asset, the long run average of these conditional expectations and time passes is zero, meaning they are both martingale and that market price is a nested margingale. 
$$
\begin{aligned}
\text{True Value } (TV) &= \text{Absolute Asset Reality in } \Iku \\
\text{Fair Value } (FV) &= E[\,TV \mid \Ik\,] \\
\text{Market Price } (P_t) &= E[\,FV \mid \I\,] = E[\,E[\,TV \mid \Ik\,] \mid \I\,]
\end{aligned}
$$

## Why a Random Walk?

One key thing I have been struggling to wrap my head around is exactly if and why fair value and market price should follow a random walk. The market price case is easier to conclude sincedue to things like bid-ask bounce and other microstructure noise, it is natural for the market price to bounce up and down regardless of fair value or the market's efficiency. Fair value is a tougher question, I initially thought that fair value should always converge to true value as new information become knowable because new information reduces uncertainty, but I was missing a key piece of this. Although new information must reduce uncertinty about the future, it doesn't necessarily do so in the direction toward true value. As an example:

Imagine a pharmaceutical company whos is going through trials to get their drug approved. If the drug is approved, the value of the company is $100, if the drug is denied the value is $0. In order to pass, the drug must pass 2/3 trials. The true value of the company is 0 dollars because the drug will be denied. Nevertheless, since the outcome is unknowable, the current fair value is $50 with the market price being somewhere around $49-$51. This is because given $\Ik$, the perfect probability of this trial's sucess is 50%. The next day, two outcomes are possibel, either the first trial passes or it fails. Either way, when this information becomes knowable it will change the odds of overall sucess. 

If the first trial passes, then the new probability of overall approval is 75% since there are two opportunities to pass at least one more trial. In this case, the fair value correctly becomes $75, diverging from the true value of $0, with the market price converging to $75 with some additional noise and latency due to market frictions

If the first trial fails, the new probability of overall approval is 25% since there are two opportunities to pass two trials. In this case the fair value correctly becomes $25, converging to the true value of $0, with the market price converging to $25 dollars with some additional noise and latency due to market frictions.

As seen above, it is actually perfectly reasonable for the fair value to diverge from the true value with the revelation of new information. This example perfectly exhibits a random walk since there is a 50/50 chance of the fair value to either go up or down by $25.

In both scenarios image, that by the end of the third trial on 1/3 trials were passed. The drug is denied and despite the probabilities of success and the associated fair value, the fair value collapses to the true value of  $0.

In conclusion, it is reasonable to model the fair value as a random walk, but this random walk does need to converge to the true value.



## Why do Traders trade?

Another question that I have is what compells traders to transact in markets and for some traders to take one side and for some traders to take the other. The explanation that I have come up with is that it all has to do with demand for the asset and demand for cash. There is a set of traders who demand the asset for various reasons (speculation, hedging, anticipated appreciation) and there is a set of traders who want cash. The dynamic demand for these two assets is what allows the market to exist. With a demand that is in flux, it makes sense how a trader might one day demand the asset and another demand cash. This can be complicated further when you allow the trades to be non-binary numbers. Now the trader might have a metaphorical 100 demand points with 60 of them demanding the asset and 40 demanding cash. In the binary trading only situation, this trader would buy the asset, and would sell once its demand for cash exceeded its demand for the asset. With non-binary trading, the trader may buy 60 units of the asset and hold 40 units of cash and dynamically adjust their position as their demands shift. We might model this by saying that an individual traders demand for the asset follows a random walk and their demand for cash is 100 - demand for the asset.

Lets abstract this to the market as a whole. We might say that if $I$ stays constant, despite the randomness of indivudual traders, aggregate demand is constant and price will never change. If $I$ is not constant, then aggregate demand for the asset will change over time. When the demand for the asset increases relative to the demand for cash, the price will increase. If the opposite is true, the price will decrease.  If the average aggregate demand for cash and the asset are equal over some time, then the price of that asset will have followed a perfectly random walk over than timespan.