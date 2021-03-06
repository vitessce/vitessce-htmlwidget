#' Class representing a local web server static route: path + directory.
#' @keywords internal
#' @rdname VitessceConfigServerStaticRoute
VitessceConfigServerStaticRoute <- R6::R6Class("VitessceConfigServerStaticRoute",
 public = list(
   #' @field path The path on which the web server should respond to requests using this callback.
   path = NULL,
   #' @field directory The directory containing files to serve.
   directory = NULL,
   #' @description
   #' Create a new server route wrapper object.
   #' @param path The route path.
   #' @param directory The directory to serve statically on this route.
   #' @return A new `VitessceConfigServerStaticRoute` object.
   initialize = function(path, directory) {
     self$path <- path
     self$directory <- directory
   }
 )
)

#' Class representing a local web server to serve dataset objects.
#' @keywords internal
#' @rdname VitessceConfigServer
VitessceConfigServer <- R6::R6Class("VitessceConfigServer",
  private = list(
    server = NULL,
    port = NULL
  ),
  public = list(
    #' @field num_obj The number of times the on_obj callback has been called.
    num_obj = NULL,
    #' @description
    #' Create a new server wrapper object.
    #' @param port The server port.
    #' @return A new `VitessceConfigServer` object.
    initialize = function(port) {
      cors <- function(res) {
        res$setHeader("Access-Control-Allow-Origin", "*")
        plumber::forward()
      }
      private$server <- plumber::pr()
      private$server <- plumber::pr_set_docs(private$server, FALSE)
      private$server <- plumber::pr_filter(private$server, "CORS", cors)
      private$port <- port
    },
    #' @description
    #' Set up the server routes.
    #' @param routes A list of `VitessceConfigServerStaticRoute` objects.
    create_routes = function(routes) {
      used_paths <- list()
      for(route in routes) {
        if(!(route$path %in% used_paths)) {
          # Reference: https://www.rplumber.io/articles/programmatic-usage.html#mount-static
          private$server <- plumber::pr_static(private$server, route$path, route$directory)
          used_paths <- append(used_paths, route$path)
        }
      }
    },
    #' @description
    #' Run the local server on the specified port.
    run = function() {
      plumber::pr_run(private$server, port = private$port)
    }
  )
)
