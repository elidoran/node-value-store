assert = require 'assert'
corepath = require 'path'

buildStore = require '../../lib'

helperFile = (name) -> corepath.resolve __dirname, '..', 'helpers', name

describe 'test value store', ->

  describe 'with bad arguments', ->

    store = buildStore()

    it 'to source() should return undefined', ->
      assert.equal store.source(-1), undefined
      assert.equal store.source(), undefined
      assert.equal store.source(0), undefined
      assert.equal store.source(99), undefined

    it 'to get() should return undefined', ->
      assert.equal store.get(), undefined
      assert.equal store.get('nada'), undefined
      assert.equal store.get(0), undefined
      assert.equal store.get('nada', 5), undefined
      assert.equal store.get(0,2), undefined
      assert.equal store.get(0.1), undefined
      assert.equal store.get(false), undefined
      assert.equal store.get(true), undefined

    it 'to has() should return false', ->
      assert.equal store.has(), false
      assert.equal store.has('nada'), false
      assert.equal store.has(0), false
      assert.equal store.has(0.1), false
      assert.equal store.has(false), false
      assert.equal store.has(true), false
      assert.equal store.has('nada', 5), false
      assert.equal store.has(0,2), false

    it 'to in() should return -1', ->
      assert.equal store.in(), -1
      assert.equal store.in('nada'), -1
      assert.equal store.in(0), -1
      assert.equal store.in(0.1), -1
      assert.equal store.in(false), -1
      assert.equal store.in(true), -1
      assert.equal store.in('nada', 5), -1
      assert.equal store.in(0,2), -1

    it 'to info() should return undefined type results', ->

      assert.deepEqual store.info(), {
        in: -1, key:undefined, value:undefined, overridden:false
      }

      assert.deepEqual store.info('nada'), {
        in: -1, key:'nada', value:undefined, overridden:false
      }

      assert.deepEqual store.info(0), {
        in: -1, key:0, value:undefined, overridden:false
      }

      assert.deepEqual store.info(0.1), {
        in: -1, key:0.1, value:undefined, overridden:false
      }

      assert.deepEqual store.info(false), {
        in: -1, key:false, value:undefined, overridden:false
      }

      assert.deepEqual store.info(true), {
        in: -1, key:true, value:undefined, overridden:false
      }

      assert.deepEqual store.info('nada', 5), {
        in: 5, key:'nada', value:undefined, overridden:false
      }

      assert.deepEqual store.info(0,2), {
        in: 2, key:0, value:undefined, overridden:false
      }

    it 'to all() should return empty array', ->
      empty = []
      assert.deepEqual store.all(), empty
      assert.deepEqual store.all('nada'), empty
      assert.deepEqual store.all(0), empty
      assert.deepEqual store.all(0.1), empty
      assert.deepEqual store.all(false), empty
      assert.deepEqual store.all(true), empty

    it 'to add() should return error', ->

      assert.deepEqual store.add(), error:'No key specified'
      assert.deepEqual store.add('key'), error:'No value specified'
      assert.deepEqual store.add('key', 'value'), error:'Invalid index: 0'
      assert.deepEqual store.add('key', 'value', -1), error:'Invalid index: -1'
      assert.deepEqual store.add('key', 'value', 99), error:'Invalid index: 99'

    it 'to remove() should return error', ->

      assert.deepEqual store.remove(), error:'No key specified'
      assert.deepEqual store.remove('key', -1), error:'Invalid index: -1'
      assert.deepEqual store.add('key', 'value'), error:'Invalid index: 0'

    it 'to set() should return error', ->

      assert.deepEqual store.set(), error:'No key specified'
      assert.deepEqual store.set('key'), error:'No value specified'
      assert.deepEqual store.set('key', 'value'), error:'Invalid index: 0'
      assert.deepEqual store.set('key', 'value', -1), error:'Invalid index: -1'
      assert.deepEqual store.set('key', 'value', 99), error:'Invalid index: 99'

    it 'to append() should return error', ->

      assert.deepEqual store.append(), {
        error:'Must provide a string or object', value:undefined
      }

      assert.deepEqual store.append(0), {
        error:'Must provide a string or object', value:0
      }

      assert.deepEqual store.append(0.1), {
        error:'Must provide a string or object', value:0.1
      }

      assert.deepEqual store.append(true), {
        error:'Must provide a string or object', value:true
      }

      assert.deepEqual store.append(false), {
        error:'Must provide a string or object', value:false
      }

      assert.deepEqual store.append('bad'), {
        error:'String must be a require()\'able file with extension \'.json\''
      }

      assert.deepEqual store.append('./nonexistent.json'), {
        error:'File doesn\'t exist: ./nonexistent.json'
      }


    it 'to prepend() should return error', ->

      assert.deepEqual store.prepend(), {
        error:'Must provide a string or object', value:undefined
      }

      assert.deepEqual store.prepend(0), {
        error:'Must provide a string or object', value:0
      }

      assert.deepEqual store.prepend(0.1), {
        error:'Must provide a string or object', value:0.1
      }

      assert.deepEqual store.prepend(true), {
        error:'Must provide a string or object', value:true
      }

      assert.deepEqual store.prepend(false), {
        error:'Must provide a string or object', value:false
      }

      assert.deepEqual store.prepend('bad'), {
        error:'String must be a require()\'able file with extension \'.json\''
      }

      assert.deepEqual store.prepend('./nonexistent.json'), {
        error:'File doesn\'t exist: ./nonexistent.json'
      }

    it 'to shift() should return empty array', ->

      empty = removed:[]

      assert.deepEqual store.shift(-1), empty
      assert.deepEqual store.shift(0), empty
      assert.deepEqual store.shift(100), empty

    it 'to pop() should return error', ->

      empty = removed:[]

      assert.deepEqual store.pop(-1), empty
      assert.deepEqual store.pop(0), empty
      assert.deepEqual store.pop(100), empty


  describe 'built with no initial objects', ->

    store = buildStore()

    it 'should have an empty array', ->
      assert store.array
      assert.equal store.array.length, 0

    it 'should return zero for count', ->
      assert.equal store.count(), 0

    it 'should return nada for get()', ->
      assert.equal store.get('nada'), undefined

    it 'should return false for has()', ->
      assert.equal store.has('nada'), false

    it 'should return -1 for in()', ->
      assert.equal store.in('nada'), -1

    it 'should return undefined type results for info()', ->
      assert.deepEqual store.info('nada'), {
        in:-1
        key: 'nada'
        value: undefined
        overridden: false
      }

    it 'should return [] for all()', ->
      assert.deepEqual store.all('nada'), []

    it 'should return error for add() because there\'s no object', ->
      assert.deepEqual store.add('key', 'value'), error:'Invalid index: 0'

    it 'should return error for remove() because there\'s no object', ->
      assert.deepEqual store.remove('key'), error:'Invalid index: 0'

    it 'should return error for set()  because there\'s no object', ->
      assert.deepEqual store.set('key', 'value'), error:'Invalid index: 0'

    it 'should return true for append(object)', ->
      assert store.array, 'array should exist'
      assert.equal store.array.length, 0, 'array should be empty'
      assert store.append({appended:true})
      assert store.array, 'array should still exist'
      assert.equal store.array.length, 1, 'array should have one source'
      assert.deepEqual store.array[0], {appended:true, __source:'append'}
      # reset
      store.array.pop()

    it 'should return true for append(string)', ->

      assert store.array, 'array should exist'
      assert.equal store.array.length, 0, 'array should be empty'

      file = helperFile 'empty.json'
      assert store.append(file)

      assert.equal store.array.length, 1, 'array should have new object'

      assert.deepEqual store.array[0], {
        __source:
          file: file
          fn: 'append'
      }
      # reset
      store.array.pop()
      # ensure it's empty again
      delete require.cache[file].exports.__source

    it 'should return true for prepend(object)', ->
      assert store.array, 'array should exist'
      assert.equal store.array.length, 0, 'array should be empty'
      assert store.prepend({prepended:true})
      assert store.array, 'array should still exist'
      assert.equal store.array.length, 1, 'array should have one source'
      assert.deepEqual store.array[0], {prepended:true, __source:'prepend'}
      # reset
      store.array.pop()

    it 'should return true for prepend(string)', ->

      assert store.array, 'array should exist'
      assert.equal store.array.length, 0, 'array should be empty'

      file = helperFile 'empty.json'
      assert store.prepend(file)

      assert.equal store.array.length, 1, 'array should have new object'

      assert.deepEqual store.array[0], {
        __source:
          file: file
          fn: 'prepend'
      }
      # reset
      store.array.pop()
      # ensure it's empty again
      delete require.cache[file].exports.__source

    it 'should return removed:[] for shift()', ->
      assert.deepEqual store.shift(), removed:[]

    it 'should return removed:[] for pop()', ->
      assert.deepEqual store.pop(), removed:[]



  describe 'built with initial empty object', ->

    store = buildStore [{}]

    it 'should return one for count', ->
      assert.equal store.count(), 1

    it 'should return nada for get()', ->
      assert.equal store.get('nada'), undefined

    it 'should return false for has()', ->
      assert.equal store.has('nada'), false

    it 'should return -1 for in()', ->
      assert.equal store.in('nada'), -1

    it 'should return undefined type results for info()', ->
      assert.deepEqual store.info('nada'), {
        in:-1
        key: 'nada'
        value: undefined
        overridden: false
      }

    it 'should return [] for all()', ->
      assert.deepEqual store.all('nada'), []

    it 'should return true for add() of new value', ->
      assert.equal store.add('new', 'value'), true
      assert.equal store.array[0].new, 'value'

    it 'should return true for add() to existing value', ->
      assert.equal store.add('new', 'value2'), true
      assert.deepEqual store.array[0].new, [ 'value', 'value2' ]
      # reset
      delete store.array[0].new

    it 'should return true for remove()', ->
      store.array[0].out = 'remove'
      assert.equal store.remove('out'), true
      assert.equal store.array[0].out, undefined, 'should have removed it'

    it 'should return true for set() initial', ->
      assert.equal store.array[0].over, undefined, 'should not be an "over" value'
      assert.equal store.set('over', 'value'), true
      assert.equal store.array[0].over, 'value'
      # reset
      delete store.array[0].over

    it 'should return true for set() overwrite', ->
      store.array[0].over = 'value'
      assert.equal store.array[0].over, 'value', 'should be a value to overwrite'
      assert.equal store.set('over', 'value2'), true
      assert.equal store.array[0].over, 'value2'
      # reset
      delete store.array[0].over

    it 'should return true for append(object)', ->
      assert store.array, 'array should exist'
      assert.equal store.array.length, 1, 'array should have one'
      assert store.append({appended:true})
      assert store.array, 'array should still exist'
      assert.equal store.array.length, 2, 'array should have two'
      assert.deepEqual store.array[0], {__source:'constructor'}
      assert.deepEqual store.array[1], {appended:true, __source:'append'}
      # reset
      store.array.pop()

    it 'should return true for append(string)', ->

      assert store.array, 'array should exist'
      assert.equal store.array.length, 1, 'array should have one'

      file = helperFile 'empty.json'
      assert store.append(file)

      assert.equal store.array.length, 2, 'array should have two'

      assert.deepEqual store.array[0], {__source:'constructor'}
      assert.deepEqual store.array[1], {
        __source:
          file: file
          fn: 'append'
      }
      # reset
      store.array.pop()
      # ensure it's empty again
      delete require.cache[file].exports.__source

    it 'should return true for prepend(object)', ->
      assert store.array, 'array should exist'
      assert.equal store.array.length, 1, 'array should have one'
      assert store.prepend({prepended:true})
      assert store.array, 'array should still exist'
      assert.equal store.array.length, 2, 'array should have two'
      assert.deepEqual store.array[0], {prepended:true, __source:'prepend'}
      assert.deepEqual store.array[1], {__source:'constructor'}
      # reset
      store.array.shift()

    it 'should return true for prepend(string)', ->

      assert store.array, 'array should exist'
      assert.equal store.array.length, 1, 'array should have one'

      file = helperFile 'empty.json'
      assert store.prepend(file)

      assert.equal store.array.length, 2, 'array should have two'

      assert.deepEqual store.array[1], {__source:'constructor'}
      assert.deepEqual store.array[0], {
        __source:
          file: file
          fn: 'prepend'
      }
      # reset
      store.array.shift()
      # ensure it's empty again
      delete require.cache[file].exports.__source

    it 'should return object in `removed` for shift()', ->
      hold = store.array[0]
      assert.deepEqual store.shift(), removed:[hold]
      # reset
      store.array.push hold

    it 'should return object in `removed` for pop()', ->
      hold = store.array[0]
      assert.deepEqual store.pop(), removed:[hold]
      # reset
      store.array.push hold
