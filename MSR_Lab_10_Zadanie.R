#MSR - LAB 10 ZADANIE

# Zadanie punktowane: Wczytaj zbi�r danych Greene z biblioteki carData i zapoznaj si� z nim. 
# Potraktuj zmienn� "decision" jako odpowied�, a pozosta�e zmienne za wyj�tkiem kolumny "success" jako zmienne wyja�niaj�ce. 
# Podziel zbi�r na podzbi�r ucz�cy (75%) i treningowy (25%). Wykonaj regresj� logistyczn� a nast�pnie wykre�l krzyw� ROC. 
# Znajd� optymalny punkt podzia�u i wykonaj dla niego macierz pomy�ek oraz oblicz skuteczno�� klasyfikacji.

rm(list=ls())
library(carData)
library(ROCit)
library(caret)
library(MASS)

data <- carData::Greene

#set.seed(123) # Ustawiamy ziarno generatora liczb losowych

samples <- createDataPartition(data$decision, p = 0.75, list = FALSE)
data.train <- data[samples,]
data.test <- data[-samples,]
data.lm <- glm(decision ~ ., data=data.train[,1:6], family=binomial(link = "logit"))
data.predict <- predict(data.lm, newdata=data.test[,1:6],  type = "response")

# Calculate ROC and plot
rocit.obj <- rocit(score=data.predict,class=data.test$decision)
summary(rocit.obj)
plot(rocit.obj)

# Calculate Youden Point
best.yi.index <- which.max(rocit.obj$TPR-rocit.obj$FPR)
best.cutoff <- rocit.obj$Cutoff[best.yi.index]
best.tpr <- rocit.obj$TPR[best.yi.index]
best.fpr <- rocit.obj$FPR[best.yi.index]

cat("\n")
print(sprintf("Best Cutoff = %.2f (TPR = %.3f, FPR = %.3f)", best.cutoff, best.tpr, best.fpr))
cat("\n")

data.result <- ifelse(data.predict>best.cutoff, "yes", "no")
data.conf <- confusionMatrix(as.factor(data.result), data.test$decision, positive = "yes"); 
print(data.conf)