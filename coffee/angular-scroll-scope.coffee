'use strict'
app = null
if angular then app = angular.module 'myApp', []

app.directive 'ngScrollScope', () ->
    return {
        restrict: 'A'
        link: ScrollScope
    }


# Main object
ScrollScope = (scope, element, attr) ->
    self = ScrollScope
    self.events = 'scroll'#'DOMMouseScroll mousewheel scroll touchstart touchmove'
    # Existing container, let's clean up

    # Prevents parent element from scrolling when a child element is scrolled to its boundaries
    self.onScroll = (event) ->
        # Event has been evaluated on lower level and deemed legit
        if event.isLegitScroll
            return true
        # Start handling
        scrollHeight = this.scrollHeight
        apparentHeight = jQuery(this).outerHeight() # jquery dep
        scrollingLeft = scrollHeight - apparentHeight - this.scrollTop
        # Let targeted elements scroll parent when they're not scrollable at all
        if scrollHeight <= apparentHeight
            return true
        # Normalize fetching delta
        console.log event
        delta = event.originalEvent.wheelDelta

        # Mobile doesn't let us kill scrolling in some situations, but
        # if we cheat for just 1px the native scoping works with bounce
        if typeof delta is 'undefined' and (event.type is 'touchstart')
            # When we're on top, move down one pixel
            if this.scrollTop <= 0
                    this.scrollTop = 1
            # When we're at the bottom, move up one pixel
            else if scrollingLeft <= 0
                this.scrollTop = scrollHeight - apparentHeight - 1

        # Firefox doesn't return wheel delta, but we don't need it since Firefox works without our hacks
        # if (typeof delta === 'undefined') {
        # 	delta = event.originalEvent.detail
        # }

        # Intervene only if we know we're actually moving
        goingUp = delta > 0

        # Scrolling down, but this will take us past the bottom
        if !goingUp and -delta > scrollingLeft
            this.scrollTop = this.scrollHeight
            return self.killScrolling event

        # Scrolling up, but this will take us past the top
        else if goingUp and delta > this.scrollTop
            this.scrollTop = 0
            return self.killScrolling event

        # Nothing intervened, I guess we're good
        event.isLegitScroll = true
        return true


    # Magic
    # Cancel an event for good
    self.killScrolling = (event) ->
        # Preventing touchmove disables click events on mobile Safari, so we require user to force
        if event.type isnt 'touchmove' and event.type isnt 'touchstart'
            event.preventDefault()
            event.stopPropagation()
            event.returnValue = false
            return false


    if element
        element.unbind self.events, self.onScroll # Store element
    # Attach event handler
    element.bind self.events, self.onScroll


# # AMD: Register as anonymous module
# if (typeof define is 'function' and typeof define.amd is 'object' and define.amd)
#     define(() -> return ScrollScope)
# # Generic export
# else if (typeof module isnt 'undefined' and module.exports)
#     # module.exports = ScrollScope.bind
#     # module.exports.ScrollScope = ScrollScope
#     module.exports = ScrollScope
# else
#     # Export to window for advanced usage
#     window.ScrollScope = ScrollScope
