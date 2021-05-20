library(tidyverse)

# modelo 1
data1 <- data.frame(acc.weight=replicate(2, as.numeric(sample(50:60, 10, rep=TRUE))))
data1$iteration <- 1:10
head(data1)

data1_ext <- data1 %>%
  rowwise() %>%
  mutate(lower=min(acc.weight.1, acc.weight.2)) %>%
  mutate(upper=max(acc.weight.1, acc.weight.2)) %>%
  mutate(avg=mean(c(acc.weight.1, acc.weight.2)))

ggplot(data1_ext) +
  geom_line(aes(x=iteration, y=avg)) +
  geom_ribbon(aes(ymin=lower, ymax=upper, x=iteration, fill = "band"), alpha = 0.3)

# modelo 2
data2 <- data.frame(acc.weight=replicate(2, as.numeric(sample(50:60, 10, rep=TRUE))))
data2$iteration <- 1:10
head(data2)

data2_ext <- data2 %>%
  rowwise() %>%
  mutate(lower=min(acc.weight.1, acc.weight.2)) %>%
  mutate(upper=max(acc.weight.1, acc.weight.2)) %>%
  mutate(avg=mean(c(acc.weight.1, acc.weight.2)))

ggplot(data2_ext) +
  geom_line(aes(x=iteration, y=avg)) +
  geom_ribbon(aes(ymin=lower, ymax=upper, x=iteration, fill = "band"), alpha = 0.3)

# visualizar juntos
data_ext <- rbind(
  mutate(data1_ext, model="model1"),
  mutate(data2_ext, model="model2")
)

ggplot(data_ext) +
  geom_line(aes(x=iteration, y=avg, color=model)) +
  geom_ribbon(aes(ymin=lower, ymax=upper, x=iteration, fill = model), alpha = 0.3) +
  ylim(45, 65)

# otros
# http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/

# visualizar boxplot de modelo 3
data3 <- data.frame(acc=replicate(10, as.numeric(sample(50:60, 1, rep=TRUE))),
                    weight=as.factor(replicate(10, as.numeric(sample(1:3, 1, rep=TRUE)))))
head(data3)

ggplot(data3, aes(x=weight, y=acc)) + 
  geom_boxplot()