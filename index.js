var events    = require('timoxley-backbone-events');
var delegate  = require('component-delegate');
var each      = require('manuelstofer-each');
var extend    = require('anthonyshort-extend');
var dom       = require('component-dom');
var bind      = require('component-bind');
var object    = require('component-object');
var keys      = object.keys;

/**
 * View
 * @param {Object} options Any options
 */
var View = function(options) {
  this.events = options.events || this.events || {};
  this.bindings = [];
  this.views = {};
  this.reset(options.el);
  this.initialize(options);
};

/**
 * Create a new view sub-class
 * @param  {Object} obj Prototype of the new view
 * @return {Function} View constructor function
 */
View.create = function(proto, stat) {
  var fn = function() {
    View.call(this, arguments);
  };
  extend(fn.prototype, View.prototype, proto);
  extend(fn, View, stat);
  fn.prototype.super = View;
  return fn;
};

/**
 * Simple method to mixin objects into the view. This allows
 * for a bit of syntax sugar for mixins and extending views.
 *
 *    var MyView = View.create();
 *    MyView.include(DraggableView);
 *
 *  Or with Coffeescript
 *
 *     class MyView extends View
 *       @include DraggableView
 * 
 * @param  {Object} obj Object to mixin
 * @return {void}
 */
View.include = function(obj) {
  extend(View.prototype, obj);
};

/**
 * Stores event bindings so we can remove them later
 * @type {Array}
 * @api private
 */
View.prototype.bindings = null;

/**
 * Each view maps to a single DOM element
 * @type {DOMElement}
 */
View.prototype.el = null;

/**
 * Wrapped DOMElement
 * @type {dom}
 */
View.prototype.$el = null;

/**
 * Automatically delegate events on the view
 * @type {Object}
 */
View.prototype.events = null;

/**
 * The element of this view
 * @type {String}
 */
View.prototype.tag = 'div';

/**
 * Called during contruction so you don't need to override the 
 * actual constructor method in sub-classes
 * @param  {Object} options The options passed in when creating the view
 * @return {void}
 */
View.prototype.initialize = function(options) {

};

/**
 * Set the element of the view. 
 * @param {[type]} el [description]
 */
View.prototype.reset = function(element) {
  this.off();
  this.unbind();
  this.el = element || document.createElement(this.tag);
  this.$el = dom(this.el);
  this.delegate(this.events);
  return this;
};

/**
 * Delegate events using a object of event names and methods
 * @param  {Object} events Events in the format "click .foo": "method"
 * @return {View}
 */
View.prototype.delegate = function(events) {
  var self = this;
  each(events, function(name, method) {
    self.on(name, method);
  });
  return this;
};

/**
 * Bind to an event with the given `str`, and invoke `method`:
 *
 *    this.on('click .remove', 'remove')
 *    this.on('click .complete', 'complete')
 *    this.on('dblclick .info a', 'showDetails')
 *
 * @param {String} str
 * @param {String} method
 * @api public
 * @return {View}
 */
View.prototype.bind = function(str, method) {
  var parts = str.split(' ');
  var event = parts.shift();
  var selector = parts.join(' ');
  var meth = this[method];
  if (!meth) throw new TypeError('method "' + method + '" is not defined');
  var fn = delegate.bind(this.el, selector, event, bind(this, meth));
  this.bindings[str] = fn;
  return this;
};

/**
 * Unbind all listeners, all for a specific event, or 
 * a specific combination of event / selector.
 *
 *    view.unbind()
 *    view.unbind('click')
 *    view.unbind('click .remove')
 *    view.unbind('click .details')
 *
 * @param {String} [str]
 * @api public
 * @return {View}
 */
View.prototype.unbind = function(str){
  if (str) {
    var fn = this.bindings[str];
    if (!fn) return;
    var parts = str.split(' ');
    var event = parts.shift();
    delegate.unbind(this.el, event, fn);
  } else {
    each(keys(this.bindings), bind(this, this.unbind));
  }
  return this;
};

/**
 * No default action. This is called when you when to prepare the view
 * for insertion into the DOM and render it from a template
 * 
 * @return {View}
 * @api public
 */
View.prototype.render = function() {
  return this;
};

/**
 * Find an element matching a selector within the view
 * 
 * @param  {String} selector querySelector string
 * @return {List}
 */
View.prototype.find = function(selector) {
  return this.el.find(selector);
};

/**
 * Remove and cleanup all events of this view
 * @return {View}
 */
View.prototype.dispose = function() {
  this.off();
  this.removeView();
  this.remove();
  this.trigger('dispose');
  return this;
};

/**
 * Remove the element from the DOM
 * @return {View} Fluid interface
 */
View.protoype.remove = function() {
  this.$el.remove();
  this.trigger('remove');
  return this;
};

/**
 * Removes all sub-views or a single view
 * @param {View} [optional] Pass in a view and only that view will be removes
 * @return {View}
 */
View.prototype.removeView = function(view) {
  each(this.views, function(subview, key){
    if( subview === view || !view ) {
      view.dispose();
      delete this.views[key];
    }
  });
  return this;
};

/**
 * Make this view an event emitter
 */
View.include(events);

/**
 * Export it!
 */
exports = View;