#### Previous Day's Cost Basis File ####
CB.Prev <- read.table("~/CLC Cost Basis Reports/AD171108CBL.txt", header = FALSE, sep = ',')
CBPrev <- aggregate( cbind(V9) ~ V3 + V6 , data = CB.Prev , FUN = sum )

#### Trade Date's Cost Basis File ####
CB.trade <- read.table("~/CLC Cost Basis Reports/AD171109CBL.txt", header = FALSE, sep = ',')
CBtrade <- aggregate(cbind(V9) ~ V3 + V6 , data = CB.trade , FUN = sum )

#### Trade Date's Transaction File ####
colno <- max(count.fields("~/CLC Cost Basis Reports/AD171109TRN.txt", sep = ',')) 

Trades <- read.table("~/CLC Cost Basis Reports/AD171109TRN.txt", header = FALSE, fill = TRUE, sep = ',',
                     col.names = paste0("V", seq_len(colno)))

combined <- merge(CBPrev, CBtrade, by = c("V3", "V6"), all = TRUE)
combined[is.na(combined)] <- 0
#names(combined) <- c("Account", "Symbol", "PrevDay", "TradeDate")

combined$Basis <- combined$V9.x - combined$V9.y

CLCRaw <- merge(Trades, combined, by = c("V3", "V6"), all = TRUE)

#CLCReport <- cbind(CLCRaw[,c(4,1:2,5,9,10,18,22)])
CLCReport <- cbind(CLCRaw[,c(1,4,5,2,18,9,22,10)])
CLCReport$GL <- CLCReport$V10 - CLCReport$Basis

#names(CLCReport) <- c("TradeDate", "Account#", "Symbol", "TransType", "Qty", "TransAmt", "Description", "CostBasis", "G/L")
names(CLCReport) <- c("Account#", "TradeDate", "TransType", "Symbol", "Description", "Qty","Cost", "TransAmt", "G/L")

#BuyReport <- subset(CLCReport[,c(1:6,8)], TransType == "BUY")
# BuyReport <- CLCReport[,c(1:6,8)][ which(CLCReport$TransType == "BUY" & CLCReport$Symbol != "ZFD90"
#                                         & CLCReport$Symbol != "MMDA12"),]

#SellReport <-subset(CLCReport, TransType == "SELL")
SellReport <- CLCReport[ which(c(CLCReport$TransType == "SELL" | CLCReport$TransType == "MAT") & c(CLCReport$Symbol != "ZFD90"
                               & CLCReport$Symbol != "MMDA12")),]

#### Create CSV files using the TRADE DATE in the file Name ####
write.csv(SellReport, file = "F:/Client Folders/CLC Trust/CLCCostBasis/Output/AD171109CBL-Sell.csv")
#write.csv(BuyReport, file = "F:/Client Folders/CLC Trust/CLCCostBasis/Output/AD170929CBL-Buy.csv")
