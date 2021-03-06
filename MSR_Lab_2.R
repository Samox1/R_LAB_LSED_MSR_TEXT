# MSR - Laboratorium 2
# n - ilo�� liczb z rozk�adu normalnego
# m - �rednia
# s - odchylenie standardowe
# histogram -> empiryczna gesto�� prawd. w postaci punkt�W
# druga seria -> czerwona linia -> teoretyczna g�sto�� prawdopodobie�stwa

rm(list=ls())

n = 1000
m = 0
s = 0.5

x <- rnorm(n, m, s)
h <- hist(x, plot=F)
plot(h$mids, h$density, ylim=c(0,1), pch = 19, col = "black", xlab = "X", ylab = "Y", font = 2)

z <- seq(min(h$mids), max(h$mids), 0.05)
g <- dnorm(z,m,s)
points(z, g, type="l", col = "red", lwd = 1)
