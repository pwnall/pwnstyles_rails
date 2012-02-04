# PwnFx: AJAX sprinkles via unobtrusive JavaScript.
# @author Victor Costan

# The author sorely misses Rails' AJAX helpers such as observe_field. This
# library provides a replacement that adheres to the new philosophy of
# unobtrusive JavaScript triggered by HTML5 data- attributes.

# Fires off an AJAX request (almost) every time when an element changes.
#
# The text / HTML returned by the request is placed in another element.
#
# Element attributes:
#   data-pwnfx-refresh-url: URL to perform an AJAX request to
#   data-pwnfx-refresh-method: the HTTP method of AJAX request (default: POST)
#   data-pwnfx-refresh-ms: interval between a change on the source element and
#                          AJAX refresh requests (default: 200ms)
#   data-pwnfx-target: the element populated with the AJAX response
class PwnFxRefresh
  constructor: (element, xhrUrl) ->
    targetSelector = '#' + element.getAttribute('data-pwnfx-refresh-target') 
    refreshInterval = parseInt(
        element.getAttribute('data-pwnfx-refresh-ms') || '200');
    xhrMethod = element.getAttribute('data-pwnfx-refresh-method') || 'POST'
    xhrForm = @parentForm element
    
    onXhrSuccess = ->
      data = @responseText
      for targetElement in document.querySelectorAll(targetSelector)
        targetElement.innerHTML = data
        for scriptElement in targetElement.querySelectorAll('script')
          parent = scriptElement.parentElement
          nextSibling = scriptElement.nextSibling
          parent.removeChild scriptElement
          parent.insertBefore scriptElement.cloneNode(true), nextSibling
        
    
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
      
    element.addEventListener 'change', onChange
    element.addEventListener 'keydown', onChange
    element.addEventListener 'keyup', onChange
    
    
  # The closest form element wrapping a node.
  parentForm: (element) ->
    while element
      return element if element.nodeName == 'FORM'
      element = element.parentNode
    null
    
# Shows elements conditionally, depending on whether some inputs' values match.
#
# Element attributes:
#   data-pwnfx-confirm: all elements with the same value for this attribute
#       belong to the same confirmation group; their values have to match to
#       trigger the "win" condition
#   data-pwnfx-confirm-win: CSS selector identifying the elements to be shown
#       when the "win" condition is triggered, and hidden otherwise
#   data-pwnfx-confirm-fail: CSS selector identifying the elements to be hidden
#       when the "win" condition is triggered, and shown otherwise
class PwnFxConfirm
  constructor: (element, identifier) ->
    sourceSelector = "[data-pwnfx-confirm-done=\"#{identifier}\"]"
    winSelector = "[data-pwnfx-confirm-win=\"#{identifier}\"]"
    failSelector = "[data-pwnfx-confirm-fail=\"#{identifier}\"]"

    onChange = ->
      value = null
      matching = true
      for element, index in document.querySelectorAll(sourceSelector)
        if index == 0
          value = element.value
        else if element.value != value
          matching = false
          break

      hideSelector = if matching then failSelector else winSelector
      showSelector = if matching then winSelector else failSelector
      for targetElement in document.querySelectorAll(showSelector)
        targetElement.classList.remove 'hidden'
      for targetElement in document.querySelectorAll(hideSelector)
        targetElement.classList.add 'hidden'
      true
    onChange()
      
    element.addEventListener 'change', onChange
    element.addEventListener 'keydown', onChange
    element.addEventListener 'keyup', onChange
        
# Moves an element using data-pwnfx-move.
class PwnFxMove
  constructor: (element, identifier) ->
    targetSelector = 
    target = document.querySelector "[data-pwnfx-move-target=\"#{identifier}\"]"
    target.appendChild element

# Shows / hides elements when an element is clicked or checked / unchecked.
#
# Attributes:
#   data-pwnfx-reveal: a name for the events caused by this element's triggering
#   data-pwnfx-trigger: 'click' means events are triggered when the element is
#       clicked, 'check' means events are triggered when the element is checked;
#       (default: click)
#   data-pwnfx-positive: set to the same value as data-pwnfx-reveal on elements
#       that will be shown when a positive event (click / check) is triggered,
#       and hidden when a negative event (uncheck) is triggered
#   data-pwnfx-negative: set to the same value as data-pwnfx-reveal on elements
#       that will be hidden when a positive event (click / check) is triggered,
#       and shown when a negative event (uncheck) is triggered
class PwnFxReveal
  constructor: (element, identifier) ->
    trigger = element.getAttribute('data-pwnfx-reveal-trigger') || 'click'      
    positiveSelector = "[data-pwnfx-reveal-positive=\"#{identifier}\"]"
    negativeSelector = "[data-pwnfx-reveal-negative=\"#{identifier}\"]"
    onChange = (event) ->
      positive = (trigger == 'click') || element.checked
      
      showSelector = if positive then positiveSelector else negativeSelector
      hideSelector = if positive then negativeSelector else positiveSelector
      for targetElement in document.querySelectorAll(showSelector)
        targetElement.classList.remove 'hidden'
      for targetElement in document.querySelectorAll(hideSelector)
        targetElement.classList.add 'hidden'
      if trigger == 'click'
        event.preventDefault()
        false
      else
        true
    
    if trigger == 'click'
      element.addEventListener 'click', onChange
    else if trigger == 'check'
      element.addEventListener 'change', onChange
      onChange()


# List of effects.
pwnEffects = [
  ['data-pwnfx-move', PwnFxMove],
  ['data-pwnfx-refresh-url', PwnFxRefresh],
  ['data-pwnfx-confirm', PwnFxConfirm],
  ['data-pwnfx-reveal', PwnFxReveal]
]

# Wires JS to elements with data-pwnfx attributes.
window.PwnFx = ->
  for effect in pwnEffects
    attrName = effect[0]
    effectClass = effect[1]
    doneAttrName = "#{attrName}-done"
    attrSelector = "[#{attrName}]"
    for element in document.querySelectorAll(attrSelector)
      attrValue = element.getAttribute attrName
      continue unless attrValue
      element.removeAttribute attrName
      element.setAttribute doneAttrName, attrValue
      new effectClass element, attrValue
  null

# Honor data-pwnfx attributes after the DOM is loaded.
window.addEventListener 'load', -> window.PwnFx()
