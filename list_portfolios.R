source("authenticate.R")

library(jsonlite)
library(rjson)

settings <- fromJSON(file = "api.json")

workspace <- "workspace2"

#put your $ENVIRONMENT name, prefix in your domain:
# https://$ENVIRONMENT.casualtyanalytics.co.uk/

environment <- "arium-test"

bearer <- okta_authenticate(environment, workspace, settings)

url <- paste0("/", workspace, "/portfolios/assets?latest=true")
response <- GET(
  url = paste0(settings$base_uri, url),
  add_headers(Authorization = bearer)
)

if (status_code(response) != 200) {
  print(paste("RESPONSE: ", content(response, "text")))
  stop(paste("FAILED: ", response, status_code(response)))
}

result <- fromJSON(content(response, "text"))
for (row in result$content) {
  print(paste0(row$id, " ", row$name))
}









