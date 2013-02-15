# View

A tiny view class based on Backbone.View. I wanted to be able to use views to solve simpler problems without needing to rely on needing a framework. This includes jQuery. The view provides functionality similar to the Backbone view but a little bit simpler. 

What it does and what it is:

  * Doesn't rely on jQuery
  * Similar interface to Backbone.View
  * Uses event hash to delegate events on the element
  * The ability to add and control sub-views
  * Clean up views and sub-views using the `destroy` method
  * Methods for interacting with the element, eg. append, find, remove etc.
  
Currently it doesn't do anything in the way of template rendering. It supplies a render method like Backbone.

## Installation

    $ component install anthonyshort/view

## API

Create a sub-class of the View by calling `View.create`.

```js
var MyView = View.create({
  events: {
    'click .item': 'clickIt'
  },
  initialize: function(options) {
    var item = new View({ el: this.find('.item') });
    this.addSubview(item)
  },
  clickIt: function(event) {
    event.preventDefault();
  },
  render: function() {
    this.subviews.forEach(function(view){
      view.render();
    });
    this.html('<div>foo!</div>');
  }
});

var view = new MyView({
  el: $(".js-view")
});

view.render();
view.destroy();
```

## License

  MIT
