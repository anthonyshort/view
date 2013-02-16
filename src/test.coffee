describe 'View', ->

  View = require 'view'
  assert = require 'component-assert'

  beforeEach ->
    @view = new View

  afterEach ->
    @view.destroy()

  it 'should work', ->
    assert(true, 'it works')

  it 'should be subclassed', ->
    Subview = View.create({ foo: 'bar' })
    view = new Subview
    assert view.foo is 'bar'
    assert Subview.create is View.create

  it 'should have an element by default', ->
    assert @view.el.toString() is '[object HTMLDivElement]'

  it 'should accept an element in the options', ->
    el = document.createElement('div')
    view = new View({ el: el })
    assert view.el is el

  it 'should call initialize', ->
    Subview = View.create
      initialize: -> @matched = true
    view = new Subview
    assert view.matched is true

  it 'should set the options', ->
    options = { foo: 'bar' }
    view = new View(options)
    assert view.options is options

  it 'should include an object', ->
    Subview = View.create()
    Subview.include({ foo: 'bar' })
    view = new Subview
    assert view.foo is 'bar'

  it 'should bind methods to the element', ->
    clicked = false
    @view.bind 'click', -> clicked = true
    @view.el.click()
    assert clicked is true

  it 'should append elements to the view', ->
    foo = document.createElement('div')
    foo.className = 'foo'
    @view.append(foo)    
    found = @view.find '.foo'
    assert found is foo

  it 'should unbind events from the element', ->
    document.body.appendChild @view.el
    count = 0
    @view.bind 'click', -> count += 1
    @view.el.click()
    @view.unbind('click')
    @view.el.click()
    assert count is 1

  it 'should unbind all events from the element', ->
    document.body.appendChild @view.el
    count = 0
    @view.bind 'click', -> count += 1
    @view.el.click()
    @view.unbind()
    @view.el.click()
    assert count is 1

  it 'should find elements within', ->
    foo = document.createElement('div')
    foo.className = 'foo'
    @view.el.appendChild foo
    found = @view.find '.foo'
    assert found is foo

  it 'should add subviews', ->
    view = new View
    @view.addSubview(view)
    assert @view.subviews.length is 1

  it 'should remove subviews', ->
    view = new View
    @view.addSubview(view)
    @view.removeSubview(view)
    assert @view.subviews.length is 0

  it 'should not remove views that arent subviews', ->
    view = new View
    destroyed = false
    view.destroy = -> destroyed = true 
    @view.removeSubview(view)
    assert destroyed is false

  it 'should remove the view', ->
    @view.el.className = 'foo'
    document.body.appendChild @view.el
    @view.remove()
    matching = document.querySelector '.foo'
    assert matching is null

  it 'should bind methods on events to the view', ->
    @view.bind 'click', -> @clicked = true
    @view.el.click()
    assert @view.clicked is true

  it 'should reset the view and clear all events', ->
    @view.clicked = false
    @view.bind 'click', -> @clicked = true
    @view.reset()
    @view.el.click()
    assert @view.clicked is false

  it 'should reset the view and change elements', ->
    el = @view.el
    @view.reset()
    assert @view.el isnt el

  it 'should bind all events at once', ->
    @view._onClick = -> @clicked = true
    @view.bind
      'click': '_onClick'
    @view.el.click()
    assert @view.clicked is true

  it 'should delegate all events on load', ->
    Subview = View.create
      events:
        'click': -> @clicked = true
    view = new Subview
    view.el.click()
    assert view.clicked is true

  it 'should bind events by method name', ->
    @view.doSomething = -> @done = true
    @view.bind 'click', 'doSomething'
    @view.el.click()
    assert @view.done is true