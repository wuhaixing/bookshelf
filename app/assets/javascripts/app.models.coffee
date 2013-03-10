debug.info 'load model'

class BooksApp.Book extends Backbone.Model

class BooksApp.Books extends Backbone.Collection
  model: BooksApp.Book

  initialize: ->
    self = this
    _.bindAll(@,"search","moreBooks")
    BooksApp.vent.on("search:term",(term) -> 
              self.search(term)
    )
    BooksApp.vent.on("search:more", ->
              self.moreBooks()
    )
    
    @maxResults = 40
    
    @page = 0
      
    @loading = false
      
    @previousSearch = null

    @totalItems = null

    @

  search: (searchTerm) ->
      self = this
      @page = 0
      @fetchBooks(searchTerm, (books) ->
        if books.length < 1
          BooksApp.vent.trigger("search:noResults")
        else 
          self.reset(books)
      )
      
      @previousSearch = searchTerm

  moreBooks: =>
    self = this
    if @length >= @totalItems
        return true
 
    @fetchBooks(@previousSearch, (books) =>
               self.add(books)
    )

  fetchBooks: (searchTerm, callback) =>
    debug.info 'fetchBooks'
    if @loading
      return true

    @loading = true

    self = this
    BooksApp.vent.trigger("search:start")

    query = encodeURIComponent(searchTerm)+'&maxResults='+@maxResults+'&startIndex='+(@page * @maxResults)+'&fields=totalItems,items(id,volumeInfo/title,volumeInfo/subtitle,volumeInfo/authors,volumeInfo/publishedDate,volumeInfo/description,volumeInfo/imageLinks)'

    debug.info query

    $.ajax(
        url: 'https://www.googleapis.com/books/v1/volumes'
        dataType: 'jsonp'
        data: 'q='+query
        success: (res) =>
          BooksApp.vent.trigger("search:stop")
          
          if res.totalItems is 0
            callback([]);
            return []

          if res.items 
            @page++;
            @totalItems = res.totalItems
            searchResults = []
            _.each(res.items, (item) =>
              thumbnail = null
              if item.volumeInfo and item.volumeInfo.imageLinks and item.volumeInfo.imageLinks.thumbnail 
                thumbnail = item.volumeInfo.imageLinks.thumbnail
              
              searchResults[searchResults.length] = new BooksApp.Book(
                thumbnail: thumbnail 
                title: item.volumeInfo.title 
                subtitle: item.volumeInfo.subtitle 
                description: item.volumeInfo.description 
                googleId: item.id
              )
            )
            callback(searchResults)
            self.loading = false
            return searchResults
          else if res.error 
            BooksApp.vent.trigger("search:error")
            self.loading = false
      )

