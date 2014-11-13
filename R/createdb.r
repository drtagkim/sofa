#' Create a database.
#'
#' @export
#' @param dbname Database name
#' @param endpoint One of localhost, cloudant, or iriscouch. For local work
#'    use the default localhost. For cloudant or iriscouch you will need accounts
#'    with those database services.
#' @param port The port to use. Only applicable if using endpoint="localhost".
#' @param username Your cloudant or iriscouch username
#' @param pwd Your cloudant or iriscouch password
#' @param delifexists If TRUE, delete any database of the same name before creating it.
#'    This is useful for testing. Default is FALSE.
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \donttest{
#' createdb(dbname='leothelion')
#' listdbs() # see if its there now
#'
#' ## or setting username and password in cushion() call
#' cushion(cloudant_name='name', cloudant_pwd='pwd')
#' createdb(dbname="mustache", "cloudant")
#'
#' ## iriscouch
#' cushion(iriscouch_name='name', iriscouch_pwd='pwd')
#' createdb(dbname="mustache", "iriscouch")
#'
#' # different login credentials than normal, just pass in to function call
#' createdb(dbname='shit', "cloudant", username='<user>', pwd='<pwd>')
#' }

createdb <- function(dbname, endpoint="localhost", port=5984, username=NULL,
  pwd=NULL, delifexists=FALSE, ...)
{
  if(delifexists)
    sofa_deletedb(dbname)

  endpoint <- match.arg(endpoint,choices=c("localhost","cloudant","iriscouch"))

  if(endpoint=="localhost"){
    sofa_PUT(sprintf("http://127.0.0.1:%s/%s", port, dbname), ...)
  } else
    if(endpoint=="cloudant"){
      if(is.null(username) | is.null(pwd)){ auth <- get_pwd(username,pwd,"cloudant") } else { auth <- c(username, pwd) }
      url <- sprintf('https://%s:%s@%s.cloudant.com/%s', auth[[1]], auth[[2]], auth[[1]], dbname)
      sofa_PUT(url, content_type_json(), ...)
    } else
    {
      if(is.null(username) | is.null(pwd)){ auth <- get_pwd(username,pwd,"iriscouch") } else { auth <- c(username, pwd) }
      url <- sprintf('https://%s.iriscouch.com/%s', auth[[1]], dbname)
      sofa_PUT(url, content_type_json(), ...)
    }
}