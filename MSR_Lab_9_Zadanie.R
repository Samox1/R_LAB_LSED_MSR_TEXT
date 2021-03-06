#MSR - LAB 9 ZADANIE

# Wczytaj zbi�r danych Salaries z biblioteki carData i zapoznaj si� z nim.
# Potraktuj zmienn� salary jako odpowied� a zmienne rank, discipline, sex 
# jako zmienne wyja�niaj�ce. Przy pomocy funkcji table sprawd� czy grupy 
# s� r�wnoliczne. Por�wnaj ze sob� wyniki tr�jczynnikowych analiz wariancji 
# wykonanych bez interakcji oraz z interakcjami. Zinterpretuj wyniki. 
# Zadanie wykonaj dwukrotnie, za pierwszym razem przy za�o�eniu balanced design, 
# a za drugim razem dla unbalanced design.


rm(list=ls())

library(car)

data("Salaries")

rownoliczne <- table(Salaries$rank, Salaries$discipline, Salaries$sex)
print(rownoliczne)
cat("\n")

print("-------------- AOV --------------")
bez_interkacji <- aov(salary ~ sex+rank+discipline, data=Salaries)
print(summary(bez_interkacji))
cat("\n")

z_interakcja <- aov(salary ~ sex*rank*discipline, data=Salaries)
print(summary(z_interakcja))
cat("\n")

print("-------------- Anova --------------")
Anova_bez <- Anova(bez_interkacji, type="III")
print(Anova_bez)
cat("\n")

Anova_z <- Anova(z_interakcja, type="III")
print(Anova_z)
cat("\n")


print("-------------- Wykresy --------------")

library(ggplot2)
theme_set(theme_bw())

male <- Salaries[Salaries$sex=="Male",]
female <- Salaries[Salaries$sex=="Female",]

gmale <- ggplot(male)
gmale + geom_boxplot(aes(x=rank, y=salary, color=discipline)) + labs(x="Rank", y="Salary", color="Discipline")+ggtitle("Male: Salary / Rank")

gfemale <- ggplot(female)
gfemale + geom_boxplot(aes(x=rank, y=salary, color=discipline)) + labs(x="Rank", y="Salary", color="Discipline")+ggtitle("Female: Salary / Rank")

