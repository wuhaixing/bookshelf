class BooksApp.LibraryApp 

  Books : new BooksApp.Books
  
  layout : new BooksApp.LibraryLayout

  showBooks : (books) ->
      bookListView = new BooksApp.BookListView(
        collection: books
      )

      @layout.books.show(bookListView)

      self = @

      BooksApp.vent.on("layout:rendered", ->
        searchView = new BooksApp.SearchView
        self.layout.search.attachView(searchView)
      )

  initializeLayout : ->
    @layout.on("show", ->
      BooksApp.vent.trigger "layout:rendered"
    )

    BooksApp.content.show(@layout)
  
  search : (term) ->
    @initializeLayout()
    @showBooks(@Books)
    
    BooksApp.vent.trigger("search:term", term)
  
  defaultSearch : ->
    @search(BooksApp.Books.previousSearch or "CoffeeScript")

class BooksApp.LibraryRouting 

class BooksApp.LibraryRouting.Router extends Backbone.Marionette.AppRouter
    appRoutes: 
      "": "defaultSearch"
      "search/:searchTerm": "search"