# PwnFx: AJAX sprinkles via unobtrusive JavaScript.
# @author Victor Costan

# The author sorely misses Rails' AJAX helpers such as observe_field. This
# library provides a replacement that adheres to the new philosophy of
# unobtrusive JavaScript triggered by HTML5 data- attributes.


# The class of the singleton instance that tracks all the effects on the page.
class PwnFxClass
  # Creates an instance that isn't aware of any effects.
  #
  # After defining an effect class, call registerEffect on this instance to make
  # it aware of the effect.
  constructor: ->
    @effects = []
    @effectsByName = {}
  
  # Wires JS to elements with data-pwnfx attributes.
  #
  # @param [Element] root the element whose content is wired; use document at
  #                       load time
  wire: (root) ->
    for effect in @effects
      attrName = "data-pwnfx-#{effect[0]}"
      effectClass = effect[1]
      scopeAttrName = "#{attrName}-scope"
      doneAttrName = "#{attrName}-done"
      attrSelector = "[#{attrName}]"
      for element in document.querySelectorAll(attrSelector)
        attrValue = element.getAttribute attrName
        continue unless attrValue
        element.removeAttribute attrName
        element.setAttribute doneAttrName, attrValue
        scopeId = element.getAttribute scopeAttrName
        new effectClass element, attrValue, scopeId
    null     
  
  # Registers a PwnFx effect.
  #
  # @param [String] attrName string following data-pwnfx- in the effect's
  #                          attribute names
  # @param klass the class that wraps the effect's implementation
  registerEffect: (attrPrefix, klass) ->
    if @effectsByName[attrPrefix]
      throw new Error("Effect name {attrPrefix} already registered")
    @effects.push [attrPrefix, klass]
  
  # Finds a scoping container.
  #
  # @param [String] scopeId the scope ID to look for
  # @param [Element] element the element where the lookup starts
  # @return [Element] the closest parent of the given element whose
  #     data-pwnfx-scope matches the scopeId argument; window.document is
  #     returned if no such element exists or if scope is null
  resolveScope: (scopeId, element) ->
    element = null if scopeId is null
    while element != null && element.getAttribute('data-pwnfx-scope') != scopeId
      element = element.parentElement
    element || document
  
  # Performs a scoped querySelectAll.
  #
  # @param [Element] scope the DOM element serving as the search scope
  # @param [String] selector the CSS selector to query
  # @return [NodeList, Array] the elements in the scope that match the CSS
  #     selector; the scope container can belong to the returned array
  queryScope: (scope, selector) ->
    scopeMatches = false
    if scope != document
      # TODO: machesSelector is in a W3C spec, but only implemented using 
      #       prefixes; the code below should be simplified once browsers
      #       implement it without vendor prefixes
      if scope.matchesSelector
        scopeMatches = scope.matchesSelector selector
      else if scope.webkitMatchesSelector
        scopeMatches = scope.webkitMatchesSelector selector
      else if scope.mozMatchesSelector
        scopeMatches = scope.mozMatchesSelector
    
    if scopeMatches
      matches = Array.prototype.slice.call scope.querySelectorAll(selector)
      matches.push scope
      matches
    else
      scope.querySelectorAll selector
  
  
# Singleton instance.
PwnFx = new PwnFxClass


# Moves an element using data-pwnfx-move.
#
# Attributes:
#   data-pwnfx-move: an identifier connecting the move's target element
#   data-pwnfx-move-target: set to the same value as data-pwnfx-move on the
#       element that will receive the moved element as its last child
class PwnFxMove
  constructor: (element, identifier, scopeId) ->
    scope = PwnFx.resolveScope scopeId, element
    target = document.querySelector "[data-pwnfx-move-target=\"#{identifier}\"]"
    target.appendChild element

PwnFx.registerEffect 'move', PwnFxMove
    
    
# Renders the contents of a template into a DOM element.
#
# Attributes:
#   data-pwnfx-render: identifier for the render operation
#   data-pwnfx-render-where: insertAdjacentHTML position argument; can be
#       beforebegin, afterbegin, beforeend, afterend; defaults to beforeend
#   data-pwnfx-render-randomize: regexp pattern whose matches will be replaced
#       with a random string; useful for generating unique IDs
#   data-pwnfx-render-target: set on the element(s) receiving the rendered HTML;
#       set to the identifier in data-pwnfx-render 
#   data-pwnfx-render-source: set on the <script> tag containing the source HTML
#       to be rendered; set to the identifier in data-pwnfx-render
class PwnFxRender
  constructor: (element, identifier, scopeId) ->
    sourceSelector = "script[data-pwnfx-render-source=\"#{identifier}\"]"
    targetSelector = "[data-pwnfx-render-target=\"#{identifier}\"]"
    insertionPoint = element.getAttribute('data-pwnfx-render-where') ||
                     'beforeend'
    randomizedPatten = element.getAttribute('data-pwnfx-render-randomize')
    if randomizedPatten
      randomizeRegExp = new RegExp(randomizedPatten, 'g')
    else
      randomizeRegExp = null
    
    onClick = (event) ->
      scope = PwnFx.resolveScope scopeId, element
      source = scope.querySelector sourceSelector
      html = source.innerHTML
      if randomizeRegExp
        randomId = 'r' + Date.now() + '_' + Math.random()
        html = html.replace randomizeRegExp, randomId
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        targetElement.insertAdjacentHTML insertionPoint, html
        PwnFx.wire targetElement
      event.preventDefault()
      false
    element.addEventListener 'click', onClick, false

PwnFx.registerEffect 'render', PwnFxRender


# Fires off an AJAX request (almost) every time when an element changes.
#
# The text / HTML returned by the request is placed in another element.
#
# Element attributes:
#   data-pwnfx-refresh: URL to perform an AJAX request to
#   data-pwnfx-refresh-method: the HTTP method of AJAX request (default: POST)
#   data-pwnfx-refresh-ms: interval between a change on the source element and
#                          AJAX refresh requests (default: 200ms)
#   data-pwnfx-target: the element populated with the AJAX response
class PwnFxRefresh
  constructor: (element, xhrUrl, scopeId) ->
    targetSelector = '#' + element.getAttribute('data-pwnfx-refresh-target') 
    refreshInterval = parseInt(
        element.getAttribute('data-pwnfx-refresh-ms') || '200');
    xhrMethod = element.getAttribute('data-pwnfx-refresh-method') || 'POST'
    xhrForm = @parentForm element
    
    onXhrSuccess = ->
      data = @responseText
      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        targetElement.innerHTML = data
        # HACK: <script>s are removed and re-inserted so the browser runs them
        for scriptElement in targetElement.querySelectorAll('script')
          parent = scriptElement.parentElement
          nextSibling = scriptElement.nextSibling
          parent.removeChild scriptElement
          parent.insertBefore scriptElement.cloneNode(true), nextSibling        
        PwnFx.wire targetElement
            
    refreshPending = false
    refreshOldValue = null
    ajaxRefresh = ->
      refreshPending = false
      xhr = new XMLHttpRequest
      xhr.onload = onXhrSuccess
      xhr.open xhrMethod, xhrUrl
      xhr.send new FormData(xhrForm)
      
    onChange = ->
      value = element.value
      return true if value == refreshOldValue
      refreshOldValue = value
      
      return true if refreshPending
      refreshPending = true
      window.setTimeout ajaxRefresh, refreshInterval
      true
      
    element.addEventListener 'change', onChange, false
    element.addEventListener 'keydown', onChange, false
    element.addEventListener 'keyup', onChange, false
    
    
  # The closest form element wrapping a node.
  parentForm: (element) ->
    while element
      return element if element.nodeName == 'FORM'
      element = element.parentNode
    null

PwnFx.registerEffect 'refresh', PwnFxRefresh


# Shows elements conditionally, depending on whether some inputs' values match.
#
# Element attributes:
#   data-pwnfx-confirm: all elements with the same value for this attribute
#       belong to the same confirmation group; their values have to match to
#       trigger the "win" condition
#   data-pwnfx-confirm-class: the CSS class that is added to hidden elements;
#       (default: hidden)
#   data-pwnfx-confirm-win: CSS selector identifying the elements to be shown
#       when the "win" condition is triggered, and hidden otherwise
#   data-pwnfx-confirm-fail: CSS selector identifying the elements to be hidden
#       when the "win" condition is triggered, and shown otherwise
class PwnFxConfirm
  constructor: (element, identifier, scopeId) ->
    hiddenClass = element.getAttribute('data-pwnfx-confirm-class') || 'hidden'
    sourceSelector = "[data-pwnfx-confirm-done=\"#{identifier}\"]"
    winSelector = "[data-pwnfx-confirm-win=\"#{identifier}\"]"
    failSelector = "[data-pwnfx-confirm-fail=\"#{identifier}\"]"

    onChange = ->
      scope = PwnFx.resolveScope scopeId, element
      value = null
      matching = true
      for sourceElement, index in PwnFx.queryScope(scope, sourceSelector)
        if index == 0
          value = sourceElement.value
        else if sourceElement.value != value
          matching = false
          break

      hideSelector = if matching then failSelector else winSelector
      showSelector = if matching then winSelector else failSelector
      for targetElement in PwnFx.queryScope(scope, winSelector)
        targetElement.classList.remove hiddenClass
      for targetElement in PwnFx.queryScope(scope, hideSelector)
        targetElement.classList.add hiddenClass
      true
    onChange()
      
    element.addEventListener 'change', onChange, false
    element.addEventListener 'keydown', onChange, false
    element.addEventListener 'keyup', onChange, false

PwnFx.registerEffect 'confirm', PwnFxConfirm


# Shows / hides elements when an element is clicked or checked / unchecked.
#
# Attributes:
#   data-pwnfx-hide: a name for the events caused by this element's triggering
#   data-pwnfx-hide-trigger: "click" means events are triggered when the
#       element is clicked, "checked" means events are triggered when the
#       element is checked; (default: click)
#   data-pwnfx-hide-class: the CSS class that is added to hidden elements;
#       (default: hidden)
#   data-pwnfx-hide-positive: set to the same value as data-pwnfx-hide on
#       elements that will be hidden when a positive event (click / check) is
#       triggered, and shown when a negative event (uncheck) is triggered
#   data-pwnfx-hide-negative: set to the same value as data-pwnfx-hide on
#       elements that will be shown when a positive event (click / check) is
#       triggered, and hidden when a negative event (uncheck) is triggered
class PwnFxHide
  constructor: (element, identifier, scopeId) ->
    trigger = element.getAttribute('data-pwnfx-hide-trigger') || 'click'
    hiddenClass = element.getAttribute('data-pwnfx-hide-class') || 'hidden'
    positiveSelector = "[data-pwnfx-hide-positive=\"#{identifier}\"]"
    negativeSelector = "[data-pwnfx-hide-negative=\"#{identifier}\"]"
    onChange = (event) ->
      positive = (trigger == 'click') || element.checked
      hideSelector = if positive then positiveSelector else negativeSelector
      showSelector = if positive then negativeSelector else positiveSelector
      
      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, hideSelector)
        targetElement.classList.add hiddenClass
      for targetElement in PwnFx.queryScope(scope, showSelector)
        targetElement.classList.remove hiddenClass
      if trigger == 'click'
        event.preventDefault()
        false
      else
        true
    
    if trigger == 'click'
      element.addEventListener 'click', onChange, false
    else if trigger == 'checked'
      element.addEventListener 'change', onChange, false
      onChange()
    else
      throw new Error("Unimplemented trigger #{trigger}")

PwnFx.registerEffect 'hide', PwnFxHide


# Removes elements from the DOM when an element is clicked.
#
# Attributes:
#   data-pwnfx-remove: an identifier connecting the elements to be removed
#   data-pwnfx-remove-target: set to the same value as data-pwnfx-remove on
#       elements that will be removed when the element is clicked 
class PwnFxRemove
  constructor: (element, identifier, scopeId) ->
    targetSelector = "[data-pwnfx-remove-target=\"#{identifier}\"]"

    onClick = (event) ->
      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        targetElement.parentNode.removeChild targetElement
      event.preventDefault()
      false
    element.addEventListener 'click', onClick, false

PwnFx.registerEffect 'remove', PwnFxRemove


# Export the PwnFx instance.
window.PwnFx = PwnFx

# Wire up the entire DOM after the document is loaded.
window.addEventListener 'load', -> PwnFx.wire(document)
