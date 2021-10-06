library(rvest)
library(RSelenium)
library(wdman)

mainPage <- read_html("https://www.quanthockey.com/nhl/seasons/2020-21-nhl-players-stats.html")
table <- mainPage %>% html_element("#AjaxRefresh") %>% html_table()

table

selServ <- selenium(verbose = FALSE)


driver.get("https://www.lambdatest.com/")
driver.findElement(By.linkText("Login")).click(); #using Selenium click button method