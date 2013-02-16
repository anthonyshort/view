delegate = require "delegate"
event = require "event"
type = require "type"
splitEvent = require "event-splitter"

# View
class View

  ###
  View
  @param {Object} options Any options
  ###
  constructor: (options) ->
    @options = options or {}
    @events = @options.events or @events or {}
    @_bindings = {}
    @subviews = []
    @reset @options.el
    @initialize options

  ###
  Create a new view sub-class

    var MyView = View.create({
      doSomething: function(){}
    });
    var view = new MyView();
    view.doSomething();

  @param  {Object} obj Prototype of the new view
  @return {Function} View constructor function
  ###
  @create: (proto) ->
    parent = this
    fn = -> 
    fn.prototype = parent.prototype
    child = -> parent.apply this, arguments
    child.prototype = new fn
    child::constructor = child
    for key, value of proto
      child::[key] = value
    for key, value of parent
      child[key] = value
    child

  ###
  Simple method to mixin objects into the view. This allows
  for a bit of syntax sugar for mixins and extending views.

    var MyView = View.create();
    MyView.include(DraggableView);
    var view = new MyView();
    view.drag();

  Or with Coffeescript

    class MyView extends View
      @include DraggableView

  @param  {Object}
  @return {void}
  ###
  @include = (obj) ->
    for key, value of obj
      View::[key] = value

  ###
  The element of this view
  @type {String}
  ###
  tagName: "div"

  ###
  Called during contruction so you don't need to override the
  actual constructor method in sub-classes
  @param  {Object} options The options passed in when creating the view
  @return {void}
  ###
  initialize: (options) ->

  ###
  Set the element of the view.
  @param {Element} el The new DOM element for this view
  ###
  reset: (element) ->
    @unbind()
    @el = element or document.createElement(@tagName)
    @bind @events
    this

  ###
  Bind to an event with the given `str`, and invoke `method`:

    this.bind('click .remove', 'remove')
    this.bind('click .complete', 'complete')
    this.bind('dblclick .info a', 'showDetails')
    this.bind({
      'click': 'remove',
      'click .complete': 'complete'
    })

  @param {String} str
  @param {Function} method
  @api public
  @return {View}
  ###
  bind: (str, method) ->
    if str is Object(str)
      for key, method of str
        @bind key, method
    else
      if type(method) is 'string'
        fn = @[method]
        throw new TypeError("method \"" + method + "\" is not defined") unless fn
      else
        fn = method
      bound = fn.bind(this)
      eventData = splitEvent(str)
      if eventData.selector is ""
        event.bind @el, eventData.name, bound
      else
        delegate.bind @el, eventData.selector, eventData.name, bound
      @_bindings[str] = bound
    this

  ###
  Unbind all listeners, all for a specific event, or
  a specific combination of event / selector.

    view.unbind()
    view.unbind('click')
    view.unbind('click .remove')
    view.unbind('click .details')

  @param {String} [str]
  @api public
  @return {View}
  ###
  unbind: (str) ->
    if str
      fn = @_bindings[str]
      return unless fn
      event.unbind @el, splitEvent(str).name, fn
    else
      for key of @_bindings
        @unbind key
    this

  ###
  No default action. This is called when you when to prepare the view
  for insertion into the DOM and render it from a template
  @return {View}
  @api public
  ###
  render: ->
    this

  ###
  Find an element matching a selector within the view
  @param  {String} selector querySelector string
  @return {Element}
  ###
  find: (selector) ->
    @el.querySelector selector

  ###
  Find all elements matching a selector within the view
  @param  {String} selector querySelector string
  @return {NodeList}
  ###
  findAll: (selector) ->
    @el.querySelectorAll selector

  ###
  Append an element to the view
  @param {Element}
  @return {View}
  ###
  append: (el) ->
    @el.appendChild el
    this

  ###
  Set or get the HTML of the element
  @param {String}
  @return {Mixed}
  ###
  html: (str) ->
    if str
      this.el.innerHTML = str
      return this
    else
      return this.el.innerHTML

  ###
  Remove and cleanup all events of this view
  @return {View}
  ###
  destroy: ->
    @removeSubview()
    @remove()
    this

  ###
  Remove the element from the DOM
  @return {View} Fluid interface
  ###
  remove: ->
    @unbind()
    parent = @el.parentNode
    return unless parent
    parent.removeChild(@el)
    this

  ###
  Removes all sub-views or a single view
  @param {View} [optional] Pass in a view and only that view will be removes
  @return {View}
  ###
  removeSubview: (view) ->
    if view
      return unless view in @subviews
      view.destroy?()
      @subviews.splice @subviews.indexOf(view), 1
    else
      for subview in @subviews
        @removeSubview subview
    this

  ###
  Add a view as a subview, this will be disposed
  of before this view is destroyed
  @param {View} view
  ###
  addSubview: (view) ->
    @subviews.push view


if module?
  module.exports = View
else
  window.View = View