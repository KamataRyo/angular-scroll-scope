'use strict'
app = angular.module 'myApp', []

app.directive 'scrollScope', () ->
    return {
        restrict:'A'
        link: () ->
            console.log 'scroll-scope!'
    }
