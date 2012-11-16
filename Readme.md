# View

A tiny view class based on Backbone.View. I wanted to be able to use views to solve simpler problems without needing to rely on needing a framework. This provides functionality similar to the Backbone view but a little bit simpler. 

  * Uses Backbone.Events so the API is the same.
  * Doesn't rely on jQuery
  * Similar interface to Backbone.View 
  
Currently it doesn't do anything in the way of template rendering. This may change in the future to at least provide some common methods.

## Installation

    $ component install anthonyshort/view

## API

Create a sub-class of the View by calling `View.create`.

```js
var MyView = View.create({
  events: {
    'click .item': 'click'
  },
  initialize: function(options) {
    this.views.items = new Vew(this.find('.items'));
  },
  click: function(event) {
    event.preventDefault();
  },
  render: function() {

  }
});

var view = new MyView({
  el: $(".js-view")
});

view.render();
view.dispose();
```

## License

  MIT
