+auction(N)[source(S)]
   :    true
   <-  if (N == 0) {
            -auction(1);
			+auction(0);
			.print("auction type: english");
        }
		else {
		    -auction(0);
			+auction(1);
			.print("auction type: dutch");
		}.

+currentBid(CURRENTBID)[source(S)]
   :    true
   <-  ?reservePrice(RP);
        ?priceIncrement(PI);
	?auction(AUCTIONTYPE);
	if (AUCTIONTYPE==0) {
	    if (CURRENTBID <=  RP){
	        if ( CURRENTBID*(1+PI) <= RP) {NCB = CURRENTBID*(1+PI);}
		    else {NCB = (CURRENTBID + RP)/2;	}
		    .print("bidding", NCB, "to english auction");
		    .send(S, tell, placeBid(AUCTIONTYPE, NCB));
	    }
	}
	else {
	    ?reservePrice(RP);
	    if (CURRENTBID <=  RP){NCB = CURRENTBID;
		.print("bidding", NCB, "to dutch auction");
		?auction(AUCTIONTYPE);
		.send(S, tell, placeBid(AUCTIONTYPE, NCB))};
	}.
