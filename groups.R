library(tidyverse)
library(httr)
library(rvest)

baseurl <- "https://api.openalex.org/"
endpoint <- "works"
q <- "group_by=institutions.country_code"
query <- paste0(baseurl, endpoint, "?", q)

res <- content(GET(url = query))

counts <- map_dfr(res$group_by,`[`, c("key", "count")) %>% 
  rename(code = key)

countries <- read_html("https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2") %>% 
  html_element(xpath = "//table[3]") %>% 
  html_table() %>% 
  mutate(Code = tolower(Code)) %>% 
  rename(name = `Country name (using title case)`,
         code = Code) %>% 
  select(code, name)

counts_by_country <- inner_join(counts, countries) %>% 
  arrange(desc(count))

(head(counts_by_country, n = 10))
