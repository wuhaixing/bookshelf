debug.info 'load app'

@BooksApp = new Backbone.Marionette.Application

BooksApp.vent.on("routing:started", ->
  Backbone.history.start() unless Backbone.History.started
)

BooksApp.vent.on("search:term", (searchTerm) ->
  Backbone.history.navigate("search/" + searchTerm)
 )

BooksApp.vent.on("layout:rendered", ->
  menu = new BooksApp.MenuView
  BooksApp.menu.attachView(menu)
  new BooksApp.SearchView 
)  

BooksApp.addInitializer ->

  BooksApp.addRegions
    content: "#content"
    menu: "#menu"
    modal: BooksApp.ModalRegion

  new BooksApp.Closer.Router(
    controller: BooksApp.Closer
  )
    
  new BooksApp.LibraryRouting.Router(
    controller: new BooksApp.LibraryApp
  )
  

  BooksApp.vent.trigger("routing:started")


    