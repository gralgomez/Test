# // Following instructions (06/2017)
# http://spark.rstudio.com/

#install.packages("devtools")

# // Installing Spark
#install.packages("sparklyr")
#spark_install(version = "1.6.2")
#devtools::install_github("rstudio/sparklyr")
library(sparklyr)

# // Connect to Spark (local instance)
s_cluster <- spark_connect(master = "local")

# // Usind dyplr
# // Examples: 
library(dplyr)

iris_tbl <- copy_to(s_cluster, iris)
flights_tbl <- copy_to(s_cluster, nycflights13::flights, "flights")
batting_tbl <- copy_to(s_cluster, Lahman::Batting, "batting")

# // List all tables from source
src_tbls(s_cluster)

# // Filter by departure delay
flights_tbl %>% filter(dep_delay == 2)

delay <- flights_tbl %>% 
  group_by(tailnum) %>%
  summarise(count = n(), dist = mean(distance), delay = mean(arr_delay)) %>%
  filter(count > 20, dist < 2000, !is.na(delay)) %>%
  collect


# // Displaying results (ggplot2)
library(ggplot2)
# // dev.off()
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  geom_smooth() +
  scale_size_area()