# README 1.16.0

### What is this repository for? ###
The project provides an example of how the Arium API can be used to create reusable scripts
for loss allocation. The project contains functions that can be used to make requests to the API.
In particular, the functions allow the user to run loss allocation on a portfolio.


### Basic setup on Windows ###
### 1. Install R (scripts were tested against  version 4.3+). ###
### 2. Get source from git. ###
### 3. Install R Studio or Intellij-IDEA, follow IDE instructions to install dependencies. ###
### 4. Create configuration for api. ### 

#### 4.1 Prepare content of api.json from Administration -> API section ####

![My Image](/images/01.png)

#### 4.2 Click on the API section: #### 

![API](/images/02.png)


#### 4.3 Copy content of api json settings and paste content it into 'api.json' file ####   

![API](/images/03.png)


### 5. Example script ### 

```R
source("authenticate.R")

library(jsonlite)
library(rjson)

settings <- fromJSON(file = "api.json")

workspace <- "workspace2"

#put your $ENVIRONMENT name, prefix in your domain:
# https://$ENVIRONMENT.casualtyanalytics.co.uk/

environment <- "arium-test"

bearer <- okta_authenticate(environment, workspace, settings)

url <- paste0("/", workspace, "/lossallocation/assets?latest=true")
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
``` 

During run from console or from RStudio, program may ask to authenticate vs OKTA either directly in the browser, or by showing command like:
```shell
Please point your browser to the following url:
https://xyz.verisk.com/oauth2/ausxxxxxxxxxxxx/v1/authorize?client_id...
```
In case if browser window does not open automatically, just copy and paste WHOLE mentioned url in your browser in order to authenticate. 
