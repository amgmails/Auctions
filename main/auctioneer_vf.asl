{include("auctioneer_v5.asl")}

!start.

+!start <- 
?english(E);
?dutch(D);
?tttd(TTTD);
?tttdThreshold(TTTDTS);
?reservePrice(RP);
?priceIncrement(PI);
?dutchInitCoef(DIC);
?winner(WINNER);
?auction(AUCTIONTYPE);
?rounds(ROUND);
?winningBid(MAXBID);
!startAuction.
