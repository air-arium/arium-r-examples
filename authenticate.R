okta_authenticate <- function(environment, workspace, settings) {

  if (!require("httr")) if (!require("httpuv")) {
    stop("Please install packages 'httr' and 'httuv'!")
  }

  okta <- oauth_endpoint(
    authorize = settings$authorization_url,
    access = settings$token_url
  )


  app <- oauth_app(environment, key = settings$client_id, secret = settings$client_secret)

  print("Application will try to authenticate in browser - please follow the instructions below.")
  token <- oauth2.0_token(okta, app,
                          scope = paste0("tenant/", workspace, " role/", "basic"),
                          cache = TRUE
  )

  print(paste0("Token expires in ", token$credentials$expires_in, " seconds."))

  return(paste(token$credentials$token_type, token$credentials$access_token, sep = " "))

}
