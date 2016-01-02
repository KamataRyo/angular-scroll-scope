'use strict'
app = angular.module 'myApp', []

app.directive 'scrollScope', () ->
    return {
        restrict:'A'
        link: ScrollScope
    }


jQuery = {}

# Main object
ScrollScope = (options) ->
    self = this

    # We bind the on handler to this element, but
    # it's not the one that is being scrolled
    self.mainContainer = null

    # This will be evaluated later
    self.selector = null

    # Some options
    self.settings = jQuery.extend {
        elements: '[data-scroll-scope]'
        forcedElements: '[data-scroll-scope="force"]'
        events: 'DOMMouseScroll mousewheel scroll touchstart touchmove'

    # Only extend if one of the keys are included
    }
    , (options and (if options.elements or options.forcedElements or options.events then options else {}))



    # Magic

    # Fetch targeted elements on the page
    self.getTargetedElements = () ->
        return self.mainContainer.find(self.selector)

    # Get working selector that targets all items
    self.getSelector = (selectors) ->
        legits = []
        # body...
        for selector in selectors
            if selector and selector.length
                legits.push selector
        return if legits.length then legits.join(', ') else null

    # Turns selector into jQuery object if needed
    self.normalizeJqueryObject = (container) ->
        if container
            return if (container instanceof jQuery) then container else jQuery(container)
        return null

    # Cancel an event for good
    self.killScrolling = (event, force) ->

        # Preventing touchmove disables click events on mobile Safari, so we require user to force
        if force or (event.type isnt 'touchmove' and event.type isnt 'touchstart')
            event.preventDefault()
            event.stopPropagation()
            event.returnValue = false
            return false


    # Prevents parent element from scrolling when a child element is scrolled to its boundaries
    self.onScroll = (event) ->

        # Event has been evaluated on lower level and deemed legit
        if event.isLegitScroll then return true

        # Start handling
        element = jQuery(this)
        force = self.settings.forcedElements && element.is(self.settings.forcedElements)
        scrollHeight = this.scrollHeight
        apparentHeight = element.outerHeight()
        scrollingLeft = scrollHeight - apparentHeight - this.scrollTop

        # Let targeted elements scroll parent when they're not scrollable at all
        if scrollHeight <= apparentHeight
            # Unless we're using force
            if force and (event.type isnt 'touchstart')
                return self.killScrolling(event, force)
            return true

        # Normalize fetching delta
        delta = event.originalEvent.wheelDelta

        # Mobile doesn't let us kill scrolling in some situations, but
        # if we cheat for just 1px the native scoping works with bounce
        if force and (typeof delta is 'undefined') and (event.type is 'touchstart')
            # When we're on top, move down one pixel
            if this.scrollTop <= 0
                element.scrollTop(1)
            # When we're at the bottom, move up one pixel
            else if (scrollingLeft <= 0)
                element.scrollTop(scrollHeight - apparentHeight - 1)

        # Firefox doesn't return wheel delta, but we don't need it since Firefox works without our hacks
        # if typeof delta === 'undefined') {
        # 	delta = event.originalEvent.detail
        # }

        # Intervene only if we know we're actually moving
        goingUp = delta > 0

        # Scrolling down, but this will take us past the bottom
        if !goingUp and -delta > scrollingLeft
            element.scrollTop(this.scrollHeight)
            return self.killScrolling(event, force)
        # Scrolling up, but this will take us past the top
        else if goingUp and delta > this.scrollTop
            element.scrollTop(0)
            return self.killScrolling(event, force)

        # Nothing intervened, I guess we're good
        event.isLegitScroll = true
        return true



    # Remove listener from parent
    self.unbind = () ->

        # Detach event handler
        if self.mainContainer
            self.mainContainer.off(self.settings.events, self.selector, self.onScroll)
        return self

    # Bind listener to parent
    self.bind = (container) ->
        container = self.normalizeJqueryObject(container)

        # Existing container, let's clean up
        if container
            self.unbind()

        # Store container
        self.mainContainer = container

        # Attach event handler
        self.mainContainer.on(self.settings.events, self.selector, self.onScroll)

        return self


    # Normalize selectors
    self.settings.elements = self.getSelector([self.settings.elements])
    self.settings.forcedElements = self.getSelector([self.settings.forcedElements])
    self.selector = self.getSelector([self.settings.elements, self.settings.forcedElements])






# AMD: Register as anonymous module
if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
    define(() -> return ScrollScope)
# Generic export
else if (typeof module isnt 'undefined') and (module.exports)
    # module.exports = ScrollScope.bind
    # module.exports.ScrollScope = ScrollScope
    module.exports = ScrollScope
else
    # Export to window for advanced usage
    window.ScrollScope = ScrollScope
    # jQuery plugin
    jQuery.fn.scrollScope = (options) ->
        # Create and bind new instance
        obj = new ScrollScope(options)
        obj.bind(this)
        # Allow jQuery chaining
        return obj.mainContainer
