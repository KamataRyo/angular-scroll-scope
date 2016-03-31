a = () ->
    console.log 'a'
    @.test = 'a-test'

b = new a()
c = new a()
b.test = 'b-test'
b.met = () ->
    console.log 'proto!'
