describe 'angular-scroll-scope directive', () ->
    beforeEach module('myApp', 'index.html')

    it 'should be attribute directive', () ->
        expect(true).toEqual true


    describe 'class spec', () ->
        it 'should that the class `ScrollScope exists`.', () ->
            expect(new ScrollScope()).not.toBe undefined

        describe 'class member spec', () ->
            # public methods to have
            methods = [
                'killScrolling'
                'onScroll'
                'unbind'
                'bind'
            ]
            properties = [
                'mainContainer'
                'events'
            ]
            instance = new ScrollScope()
            for method in methods
                it "should that the instance has public method `#{method}`.", () ->
                    expect(instance[method]).toEqual(jasmine.any(Function))
            for property in properties
                it "should that the instance has property `#{property}`.", () ->
                    expect(instance[method]).toBeDefined()
