english(0).
dutch(0).
tttd(158).
tttdThreshold(47).
reservePrice(793).
priceIncrement(0.12).
dutchInitCoef(0.36).
winner(0).
auction(0).
rounds(0).
winningBid(793).

!startAuction.

+!startAuction
   :    auction(0) &
        tttd(TTTD) &
        tttdThreshold(TTTDTS) &
        TTTD>TTTDTS &
        english(0) &
        reservePrice(RP)

   <-   ?rounds(ROUND);
        !announceAuction(0);
	.print("calling for proposals starting at",RP);
        .broadcast(tell, currentBid(RP));
        +currentBid(RP);
        -english(0);
        +english(1);
        !update_rounds;
        !update_tttd;
	.wait(1000);
	!iterate.

+!startAuction
   :    tttd(TTTD) &
        tttdThreshold(TTTDTS) &
        TTTD<=TTTDTS &
        dutch(0) &
        english(0) &
        reservePrice(RP) &
        dutchInitCoef(DIC)

   <-   ?rounds(ROUND);
        -auction(0);
        +auction(1);
        !announceAuction(1);
	.print("calling for proposals starting at",RP*(1+DIC));
        .broadcast(tell, currentBid(RP*(1+DIC)));
        +currentBid(RP*(1+DIC));
        -dutch(0);
        +dutch(1);
        !update_rounds;
        !update_tttd;
	.wait(1000);
	!iterate.	
		

+!announceAuction(AUCTIONTYPE)
   :    rounds(ROUND)
   <-  if (AUCTIONTYPE == 0) {.print("round:",ROUND,". Start of english auction");}
        else {.print("round:",ROUND,". Start of dutch auction");}
		.broadcast(tell, auction(AUCTIONTYPE)).
		
+!update_tttd
   :    tttd(TTTD)
   <-  -tttd(TTTD);
        +tttd(TTTD-1).
		
+!update_rounds
   :    rounds(ROUND)
   <-  -rounds(ROUND);
        +rounds(ROUND+1).
		
+!endAuction
   :    true
   <-  ?winner(WINNER);
        ?winningBid(MAXBID);
        .broadcast(tell, winner(WINNER));
	if (WINNER==0){.print("There is no winner, no offer received.");}
	else {.print("The winner is",WINNER, "with a bid of", MAXBID);
	.print("requesting payment from", WINNER);
	.send(WINNER, tell, request(MAXBID));}.
   
  
+!launchEnglishProtocol(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS)
   <-   ?rounds(ROUND);
        .print("start of round n_",ROUND);
        .print(BIDSLENGTH,"proposal(s) was(were) received.");
	?currentBid(CURRENTBID);
        for ( .member(b(BIDVALUE,BIDDER),BIDS) ) {
            if (BIDVALUE > CURRENTBID) {.print(BIDDER,"bid of",BIDVALUE,"is accepted because it is more than current bid of", CURRENTBID);.send(BIDDER, tell, accepted(BIDVALUE));}
            else {.print(BIDDER,"bid of",BIDVALUE,"is rejected because it is not more than current bid of", CURRENTBID);.send(BIDDER, tell, rejected(BIDVALUE));}
        }
        .max(BIDS,b(BIDVALUE,BIDDER));
        ?winner(WINNER);
        -winner(WINNER);
        +winner(BIDDER);
	?winningBid(MAXBID);
        -winningBid(MAXBID);
        +winningBid(BIDVALUE);
        if (BIDVALUE>CURRENTBID) {NCB = BIDVALUE*(1+PI);}
        else {NCB = CURRENTBID*(1+PI);}
        .abolish(placeBid(_,_)[source(S)]);
        -currentBid(CURRENTBID);
        +currentBid(NCB);
        if (TTTD - 1 < TTTDTS) {
            .print("Start of dutch auction");
            .broadcast(tell, auction(1));
			-auction(0);
			+auction(1);
			?dutchInitCoef(DIC);
			NNCB = CURRENTBID*(1+DIC);
			.print("calling for proposals starting from",NNCB);
			.broadcast(tell, currentBid(NNCB));
			-currentBid(NCB);
			+currentBid(NNCB);
        }
        else {
		    .print("calling for proposals starting from", NCB);
		    .broadcast(tell, currentBid(NCB));
			}
        -rounds(ROUND);
        +rounds(ROUND+1);
        -tttd(TTTD);
        +tttd(TTTD-1);
	.wait(1000);
	!iterate.
		
		
+!launchDutchProtocol_1(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS)
   <-  ?rounds(ROUND);
        .print("start of round n_",ROUND);
        .print("0 proposal was received.");
	?currentBid(CURRENTBID);
        for ( .member(b(BIDVALUE,BIDDER),BIDS) ) {
            if (BIDVALUE >= CURRENTBID) {.print(BIDDER,"bid of",BIDVALUE,"is accepted because it is more than current bid of", CURRENTBID);.send(BIDDER, tell, accepted(BIDVALUE));}
            else {.print(BIDDER,"bid of",BIDVALUE,"is rejected because it is not more than current bid of", CURRENTBID);.send(BIDDER, tell, rejected(BIDVALUE));}
        }	
        ?reservePrice(RP);
	if ( CURRENTBID*(1-PI) <= RP){NCB = RP;}
	else {NCB = CURRENTBID*(1-PI);}
        .abolish(placeBid(_,_)[source(S)]);
        -currentBid(CURRENTBID);
        +currentBid(NCB);
	.print("calling for proposals starting from", NCB);
        .broadcast(tell, currentBid(NCB));
        -rounds(ROUND);
        +rounds(ROUND+1);
        -tttd(TTTD);
        +tttd(TTTD-1);
	.wait(1000);
	!iterate.


+!launchDutchProtocol_2(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS)
   <-  ?rounds(ROUND);
        .print("start of round n_",ROUND);
        .print(BIDSLENGTH,"proposals were received.");
	?currentBid(CURRENTBID);
        for ( .member(b(BIDVALUE,BIDDER),BIDS) ) {
            if (BIDVALUE >= CURRENTBID) {.print(BIDDER,"bid of",BIDVALUE,"is accepted because it is more than current bid of", CURRENTBID);.send(BIDDER, tell, accepted(BIDVALUE));}
            else {.print(BIDDER,"bid of",BIDVALUE,"is rejected because it is not more than current bid of", CURRENTBID);.send(BIDDER, tell, rejected(BIDVALUE));}
        }	
	NCB = CURRENTBID*(1+1/PI);
        .abolish(placeBid(_,_)[source(S)]);
        -currentBid(CURRENTBID);
        +currentBid(NCB);
//	-priceIncrement(PI);
//	+priceIncrement(PI/BIDSLENGTH);
	.print("calling for proposals starting from", NCB);
        .broadcast(tell, currentBid(NCB));
        -rounds(ROUND);
        +rounds(ROUND+1);
        -tttd(TTTD);
        +tttd(TTTD-1);
	.wait(1000);
	!iterate.


+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(0,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH ==0 &// no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 0 &
        tttd(TTTD) &
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD>=TTTDTS
   <-   !endAuction.


+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(0,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH >=1 & // no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 0 &
        tttd(TTTD) &
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD>=TTTDTS
   <-   ?auction(AUCTIONTYPE);
	!launchEnglishProtocol(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS).

+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(1,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH ==0 & // no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 1 &
        tttd(TTTD) &
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD<TTTDTS &
	currentBid(CURRENTBID) &
	reservePrice(RP) &
	CURRENTBID <= RP
   <-   !endAuction.


+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(1,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH ==0 &// no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 1 &
        tttd(TTTD) &
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD<TTTDTS &
	currentBid(CURRENTBID) &
	reservePrice(RP) &
	CURRENTBID > RP
   <-   ?auction(AUCTIONTYPE);
	!launchDutchProtocol_1(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS).

+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(1,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH ==1 & // no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 1 &
        tttd(TTTD) &	
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD<TTTDTS &
	currentBid(CURRENTBID) &
	reservePrice(RP) &
	CURRENTBID > RP &
	.max(BIDS,b(BIDVALUES,BIDDERS)) &
	BIDVALUES >= RP
   <-   ?winner(WINNER);
        -winner(WINNER);
        +winner(BIDDERS);
	?winningBid(MAXBID);
        -winningBid(MAXBID);
        +winningBid(BIDVALUES);
	!endAuction.

+!iterate
   :    .findall(b(BIDVALUE,BIDDER),placeBid(1,BIDVALUE)[source(BIDDER)],BIDS) &
        .length(BIDS,BIDSLENGTH) & BIDSLENGTH >1 &// no proposal was received
	auction(AUCTIONTYPE) &
        AUCTIONTYPE == 1 &
        tttd(TTTD) &
        priceIncrement(PI) &
        tttdThreshold(TTTDTS) &
        TTTD<TTTDTS &
	currentBid(CURRENTBID) &
	reservePrice(RP) &
	CURRENTBID > RP &
	.max(BIDS,b(BIDVALUES,BIDDERS)) &
	BIDVALUES >= RP
   <-   ?auction(AUCTIONTYPE);
	!launchDutchProtocol_2(AUCTIONTYPE, BIDSLENGTH, BIDS, PI, TTTD, TTTDTS).
