source("authenticate.R")

library(jsonlite)
library(rjson)
library(readr)

settings <- fromJSON(file = "api.json")

workspace <- "workspace2"

#put your $ENVIRONMENT name, prefix in your domain:
# https://$ENVIRONMENT.casualtyanalytics.co.uk/

environment <- "arium-test"

bearer <- okta_authenticate(environment, workspace, settings)

# 1. Initialize upload of calculation request
#    this section of code prepares calculation id and upload space on s3.
init_url <- paste0("/", workspace, "/calculations/la/")
init_response <- PUT(
  url = paste0(settings$base_uri, init_url),
  body = "",
  add_headers(Authorization = bearer)
)
# init_result contains url, that will be used in next step.
init_result <- fromJSON(content(init_response, "text"))

# 2. Upload calculation request.
#    Also here request can be modified if needed.
upload_request_url <- init_result$url
upload_request_json <- read_file("data/calculation.json")
upload_url <- upload_request_url
upload_response <- PUT(
  url = upload_url,
  body = upload_request_json
)

# 3. Execute polling in loop and wait for calculation result.
#    We use here 'location', that was pprepared for us in step 1 inside init_result
#    We should execute polling as long as response 'state' is neither 'ready' nor 'failed'
caculation_state <- "processing"
while (caculation_state != 'ready' && caculation_state != 'failed') {
  # we add small sleeping deplay for better process visibility
  Sys.sleep(5)
  polling_url <- paste0("/", workspace, "/calculations/la/")
  polling_response <- GET(
    url = paste0(settings$base_uri, "/", init_result$location),
    add_headers(Authorization = bearer)
  )
  # inside polling_result we get 'state' that may be one of:
  # 'uploading'/'processing'/'ready'/'failed'
  polling_result <- fromJSON(content(polling_response, "text"))
  caculation_state <- polling_result$state
  print(paste0("Calculation status: ",caculation_state))
}

report_download_url <- polling_result$url
print(paste0("Report pre-signed download URL: ",report_download_url))

# 4. Download calculation report.

download.file(report_download_url, destfile = 'result.csv', mode = "wb")






