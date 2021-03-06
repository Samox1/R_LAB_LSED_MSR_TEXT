### LSED - Zadanie 4 - LAB nr 5-6
# Autor: Szymon Baczy�ski 270626

rm(list=ls())
library(MASS)
library(rpart)
library(rpart.plot)

CM.large <- function(org.class, pred.class) {
  CM <- table(org.class, pred.class)
  # Skuteczno�� klasyfikatora
  ACC <- sum(diag(CM)) / sum(CM)
  TP1 <- CM[1,1]
  TP2 <- CM[2,2]
  TP3 <- CM[3,3]
  gsums <- sum(diag(CM))
  sums <- apply(CM, 1, sum)
  return(c(ACC = round(ACC,4), TP1 = TP1, TP2 = TP2, TP3 = TP3, GSUM = gsums, ALL = sum(CM), row.names = NULL))
}

### --- Punkt 1 - Wczyta� dane --- ###
cat("\n"); print("--- Punkt nr 1 zadania ---"); 

ifelse(!file.exists("wine.dat"), write.table(wina <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data", sep=","), file="wine.dat", sep=","), wina <- read.table("wine.dat", sep=","))
print("Wczytano dane i utworzono plik 'wine.dat' (je�li taki nie istnia�)")

### --- Punkt 2 - Nazwa� kolumny --- ###
cat("\n"); print("--- Punkt nr 2 zadania ---"); 
colnames(wina) <- c("class","Alcohol","Malic acid","Ash","Alcalinity of ash","Magnesium","Total phenols","Flavanoids","Nonflavanoid phenols","Proanthocyanins","Color intensity","Hue","OD280/OD315 of diluted wines", "Proline")
print("Nazwano kolumny wed�ug pliku pomocniczego")

### --- Punkt 3 - Stworzy� pe�ne drzewo --- ###
cat("\n"); print("--- Punkt nr 3 zadania ---")
wina$class <- factor(wina$class)
tree <- rpart(class ~ ., wina, minsplit = 0, cp = 0)
print("Stworzono drzewo")

### --- Punkt 4 - Narysowa� pe�ne drzewo --- ###
cat("\n"); print("--- Punkt nr 4 zadania ---")
# Rysowanie drzewa
rpart.plot(tree, type = 1, extra = 1)
print("Narysowano drzewo")

### --- Punkt 5 - Spr. skuteczno�� pe�nego drzewa przez PP i CV --- ###
cat("\n"); print("--- Punkt nr 5 zadania ---")

print("Skuteczno�ci pe�nego drzewa ")
cat(c("Skuteczno�� PP: ", ACC.PP <- CM.large(wina$class, predict(tree, wina, type = "class"))[1]))

# --- Kroswalidacja --- #

cross <- wina[sample(nrow(wina)),]
cross$class <- factor(cross$class)

k <- 5        #kroswalidacja, podzielenie ilo�ci wierszy przez k 
k_rows <- nrow(cross) / k
k_rows <- as.integer(round(k_rows))

cross.class <- rpart(class ~ ., cross[-(1:k_rows),], minsplit = 0, cp = 0)     #Cz�� K1 - od -> 1:k_rows
cross.CM <- CM.large(cross[1:k_rows,]$class, predict(cross.class, cross[1:k_rows,], type="class"))

for(x in 1:(k-2))
{
  cross.class <- rpart(class ~ ., cross[-((x*k_rows+1):(x*k_rows+k_rows)),],minsplit = 0, cp = 0)
  cross.CM <- rbind(cross.CM, CM.large(cross[((x*k_rows+1):(x*k_rows+k_rows)),]$class, predict(cross.class, cross[((x*k_rows+1):(x*k_rows+k_rows)),], type="class")))
}

cross.class <- rpart(class ~ ., cross[-(((k-1)*k_rows+1):(nrow(cross))),],minsplit = 0, cp = 0)    #Cz�� K5 - od -> (4*k_rows+1):(nrow(cross))
cross.CM <- rbind(cross.CM, CM.large(cross[(((k-1)*k_rows+1):(nrow(cross))),]$class, predict(cross.class, cross[((k-1)*k_rows+1):(nrow(cross)),], type="class")))

ifelse(k==5,(rownames(cross.CM) <- c("LDA K1", "LDA K2", "LDA K3", "LDA K4", "LDA K5")), rownames(cross.CM) <- c(1:k))

#cat("\n"); cat("\n"); print("Uczenie na kroswalidacji")
#print(cross.CM)

kroswalid_acc = sum(cross.CM[,"GSUM"])/sum(cross.CM[,"ALL"])
cat("\n"); cat(c("Skuteczno�� CV: ",kroswalid_acc))


### --- Punkt 6 - za pomoc� tabeli cp wybra� drzewo optymalne, narysowa� je i por�wnac wyniki jego skuteczno�ci z pe�nym drzewem --- ###
cat("\n"); cat("\n"); print("--- Punkt nr 6 zadania ---")

# best.cp <- function(tree){
#   mincp <- as.numeric(gsub("[a-zA-Z ]", "",rownames(tree$cptable)[which.min(tree$cptable[,"xerror"])]))
#   xerr.max <- tree$cptable[mincp,"xerror"] + tree$cptable[mincp,"xstd"]
#   cp.row <- as.numeric(gsub("[a-zA-Z ]", "",rownames(tree$cptable)[which.max(tree$cptable[,"xerror"] < xerr.max)]))
#   cp <- tree$cptable[cp.row,"CP"]
#   return(cp)
# }

best.cp <- function(tree){
  mincp <- which.min(tree$cptable[,4])
  cp.row <- which.max(tree$cptable[,4] < tree$cptable[mincp,4] + tree$cptable[mincp,5])
  return(tree$cptable[cp.row,1])
}

print("Wybranie Drzewa Optymalnego (best CP)")
best.tree <- best.cp(tree)
cat(c("Best CP: ",best.tree)); cat("\n");cat("\n")
tree1 <- prune(tree, cp=best.tree)

rpart.plot(tree1, type = 1, extra = 1)
print("Narysowanie drzewa optymalnego")
print("Por�wnanie skuteczno�ci:")
cat(c("Skuteczno�� PP: ",ACC.PP)); cat("\n")
cat(c("Skuteczno�� CV: ",kroswalid_acc)); cat("\n")
cat(c("Skuteczno�� Drzewa Optymalnego: ",(CM.large(wina$class,predict(tree1, wina, type = "class"))["ACC"]))); cat("\n")


### --- Punkt 7 - stworzy� drzewo dla pierwszych: dw�ch, trzech, czterach, itd. zmiennych - za ka�dym razem wyznaczy� drzewo optymalne --- ###
cat("\n"); print("--- Punkt nr 7 zadania ---")

max_col = length(wina)
tree_all <- lapply(3:max_col, function(i) rpart(class ~., wina[,1:i], minsplit = 0, cp = 0))
cp_all <- lapply(1:length(tree_all), function(i) best.cp(tree_all[[i]]))
tree_all_opt <- lapply(1:length(tree_all), function(i) prune(tree_all[[i]], cp=cp_all[[i]]))
print("Wyznaczenie optymalnych drzew dla pierwszych: 2,3,4...12 zmiennych")


### --- Punkt 8 - wykre�li� skuteczno�� drzewa w funkcji liczby u�ytych zmiennych, a tak�e r�nice rozmiaru drzewa pe�nego i optymalnego --- ###
cat("\n"); print("--- Punkt nr 8 zadania ---")

ACC_all <- lapply(1:length(tree_all_opt),function(i) CM.large(wina$class,predict(tree_all_opt[[i]], wina, type = "class"))["ACC"])
plot(2:(length(tree_all_opt)+1), ACC_all, type="b", xlab = sprintf("Ilo�� u�ytych zmiennych: 2 ~ %0.f", (length(tree_all_opt))+1), ylab = "Skuteczno�� Optymalnych Drzew",pch=19, col="blue")
axis(side=1, at=c(2:(length(tree_all_opt)+1)))
title("Skuteczno�� Optymalnych Drzew")
print("Wyliczono skuteczno�ci optymalnych drzew")

N_diff <- sapply(1:length(tree_all),function(i) max(tree_all[[i]]$cptable[,"nsplit"]) - max(tree_all_opt[[i]]$cptable[,"nsplit"]))
plot(2:(length(tree_all_opt)+1), N_diff, type="b", xlab = sprintf("Ilo�� u�ytych zmiennych: 2 ~ %0.f", (length(tree_all_opt))+1), ylab = "R�nica drzewa pe�nego i optymalnego",ylim=c(0,max(N_diff)), cex=3)
axis(side=1, at=c(2:(length(tree_all_opt)+1)))
axis(side=2, at=seq(0, max(N_diff), by=5))
text(2:(length(N_diff)+1),N_diff,label=N_diff, col = "blue", cex=0.8)
title("R�nica drzewa pe�nego i optymalnego")
print("Wyliczono r�nice rozmiaru drzewa pe�nego i optymalnego")

