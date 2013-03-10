BooksApp.Closer = {}

class BooksApp.Closer.DefaultView extends Backbone.Marionette.ItemView
  template: "#close-template"
  className: "close"


class BooksApp.Closer.Router extends Backbone.Marionette.AppRouter
    appRoutes: 
      "close": "close"


BooksApp.Closer.close = ->
  closeView = new BooksApp.Closer.DefaultView
  BooksApp.content.show(closeView)
  Backbone.history.navigate("close")

