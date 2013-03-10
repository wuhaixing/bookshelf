debug.info 'load views'

class BooksApp.MenuView extends Backbone.Marionette.View
  el: "#menu"
  
  events: 
    'click #menu .js-menu-books': 'showLibraryApp'
    'click #menu .js-menu-close': 'closeApp'
  
  
  showLibraryApp: (e) ->
    e.preventDefault()
    BooksApp.LibraryApp.defaultSearch()

  closeApp: (e) ->
    e.preventDefault()
    BooksApp.Closer.close()
    null

class BooksApp.ModalRegion extends Backbone.Marionette.Region
  debug.info 'load ModalRegion'
  
  el: "#modal"
  constructor: ->
    debug.info 'create modal'
    _.bindAll(@);
    Backbone.Marionette.Region.prototype.constructor.apply(@, arguments)
    @on("show", @showModal, @)
 
  getEl: (selector) ->
    $el = $(selector)
    $el.on("hidden", @close)
    $el

  showModal: (view) ->
    debug.info 'showModal'
    view.on("close", @hideModal, @)
    @.$el.modal 'show' 

  hideModal: ->
    debug.info 'hide modal'
    @.$el.modal 'hide' 


class BooksApp.BookView extends Backbone.Marionette.ItemView
    template: "#book-template"
  
    events: 
      'click': 'showBookDetail'
    
    showBookDetail: ->
      detailView = new BooksApp.BookDetailView(
        model: @model
      )

      BooksApp.modal.show(detailView)

class BooksApp.BookDetailView extends Backbone.Marionette.ItemView
    template: "#book-detail-template"
    className: "modal bookDetail"

class BooksApp.BookListView extends Backbone.Marionette.CompositeView
    template: "#book-list-template"
    id: "bookList"
    itemView: BooksApp.BookView
  
    initialize: ->

      _.bindAll(@, "showMessage", "loadMoreBooks")

      BooksApp.vent.on("search:error", ->
        @showMessage("Error, please retry later :s") 
      )
      BooksApp.vent.on("search:noSearchTerm", ->
        @showMessage("Hummmm, can do better :)") 
      )
      BooksApp.vent.on("search:noResults", ->
        @showMessage("No books found")
      )
    
    events: 
      'scroll': 'loadMoreBooks'
    
    
    appendHtml: (collectionView, itemView) ->
      collectionView.$(".books").append(itemView.el)
    
  
    showMessage: (message) ->
      @.$('.books').html('<h1 class="notFound">' + message + '</h1>')
    
    
    loadMoreBooks: ->
      totalHeight = @.$('> div').height()
      scrollTop = @.$el.scrollTop() + @.$el.height()
      margin = 200;
          
      if scrollTop + margin >= totalHeight 
        BooksApp.vent.trigger("search:more")

class BooksApp.SearchView extends Backbone.Marionette.View
    el: "#searchBar",
    
    initialize : ->
      self = this
      $spinner = self.$('#spinner')

      BooksApp.vent.on("search:start", ->
         $spinner.fadeIn()
      )
      BooksApp.vent.on("search:stop", ->
         $spinner.fadeOut()
      )

      BooksApp.vent.on("search:term", (term) ->
        self.$('#searchTerm').val(term)
      )
    
    events:
      'change #searchTerm': 'search'
        
    search: (e) ->
      searchTerm = @.$('#searchTerm').val().trim()
      if searchTerm.length > 0 
        BooksApp.vent.trigger("search:term", searchTerm)
      else 
        BooksApp.vent.trigger("search:noSearchTerm")


class BooksApp.LibraryLayout extends Backbone.Marionette.Layout

  template: "#library-layout"

  regions: 
      search: "#searchBar"
      books: "#bookContainer"




