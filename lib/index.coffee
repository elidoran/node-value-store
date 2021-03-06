fs = require 'fs'
corepath = require 'path'
ini = require 'ini'

readJson = (file) -> JSON.parse fs.readFileSync(file, 'utf8')
readIni  = (file) -> ini.parse fs.readFileSync(file, 'utf8')

setSource = (object, value) ->
  Object.defineProperty object, '__source',
    value: value
    writable: false
    enumerable: false
    configurable: false
  return

# TODO:
# consider extending EventEmitter to provide events when:
#  1. value is set, can provide old value
#  2. value is added (set, but combined)
#  3. value is removed, can provide old value
#  4. object is appended/prepended
#  5. object is shift()'ed or pop()'ed

class ValueStore

  constructor: (options, validated) ->

    # builder function can validate and return an error instead of throwing it
    # so, it tells us validated=true.
    # if that doesn't exist, then, we need to do it here, and, in a constructor
    # we can't return an error, so, we must throw it instead
    unless validated
      # find array as options object, in options object, or create an empty one
      array = if Array.isArray(options) then options else options.array ? []

      # verify each element is an object
      for element, index in array
        if typeof element isnt 'object'
          # Note: throwing an error cuz we're in a constructor.
          # should use the exported builder function instead of the class
          throw new Error 'ValueStore accepts only objects. Invalid element at ' +
            index + ': ' + element

        else # mark these are from the constructor, unless it's already set
          unless element.__source? then setSource element, 'constructor'

    else # it was validated and is ready to go, so grab array
      array = options.array

    # store it
    @array = array


  # how many value sources do we have
  count: () -> @array.length

  # where did the specified source come from
  source: (index = 0) -> @array?[index]?.__source

  # get a value from a source, get from the first one by default
  get: (key, index) ->
    # if they specified an exact object, then, use it
    if index? then return @array?[index]?[key]

    # search for the object with the key
    index = @in key

    # return the value if the key was found, or, undefined...
    if index > -1 then @array[index][key] else undefined

  # same as get except return a boolean representing whether the value exists
  has: (key, index) ->
    if index? then @array?[index]?[key]? else @in(key) > -1

  # return the index of the first object source which contains the key
  in: (key) ->
    for object, index in @array
      if object[key]? then return index

    # didn't find it...
    return -1

  # describe the key's existence, which source is it in, what's its value,
  # was it overridden by a higher object source?
  # if index is specified then it searches only that object source
  info: (key, index) ->
    index ?= @in key

    result =
      in   : index
      key  : key
      value: @array?[index]?[key]
      overridden: @_isOverridden key, index

  # used by info() to check if an earlier object source has the key too
  _isOverridden: (key, index) ->
    if index < 1 then return false
    if index > @array.length then index = @array.length
    for index in [0..index]
      if @array?[index]?[key]? then return true

    # nope, didn't find one ahead of it
    return false

  # return an array of all existent values for the key from all sources
  all: (key) ->
    # defaults to an empty array result
    result = []
    # search them all
    for object in @array
      # append each one found
      if object[key]? then result.push object[key]

    return result

  # add is like set() except it doesn't overwrite existing values,
  # instead, it combines them into an array
  # adds to the indexed source, defaults to the first one
  add: (key, value, index = 0) -> @set key, value, index, true

  # remove the key from the indexed source, defaults to the first one
  remove: (key, index) -> @set key, undefined, index, false

  # used by add() with `add` = true
  # used by remove() with `add` = false
  # is set() when `add` is undefined
  # set() will set this value as "the value",
  # it overwrites a current value if there is one.
  set: (key, value, index, add) ->

    # jump to the front, if there are no objects... error
    unless @array.length > 0 then return error:'Invalid index: ' + (index ? 0)

    # make sure we have what we need
    unless key? then return error:'No key specified'

    # if add is false then it's remove() so we don't need the value,
    # or, if value exists, we're good
    unless add is false or value? then return error:'No value specified'

    # also index must reference a valid source
    if index?
      unless index > -1 and index < @array.length
        return error:'Invalid index: ' + index

    # if we're removing and an index wasn't specified, then find the key
    else if add is false
      index = @in key

      # if we don't find it, then we can't remove it.
      # we could return an error, but, let's instead consider remove()
      # an order to ensure the key doesn't exist.
      # if we don't find it, then, we've already succeeded.
      # don't error, but, don't return the value which was removed.
      # when we find it to remove, return its value so they know we found it.
      if index is -1 then return

    # otherwise, use index = 0 for set/add
    else index = 0

    # get current value
    existingValue = @array?[index]?[key]

    result = {}

    # add() sends us here
    if add is true # then combine values into an array

      # if there is a current value then we need to combine them
      if existingValue?

        # if we've already combined them then it's currently an array
        if Array.isArray existingValue
          existingValue.push value

        # otherwise, create the array now with the two values
        else
          @array[index][key] = [ existingValue, value ]

      # otherwise it's the same as setting the first value
      else @array[index][key] = value

      result.addedTo = existingValue

    # remove() sends us here
    else if add is false # then remove value
      result.removed = existingValue
      @array[index][key] = undefined

    # set() gets here
    else # set the value
      result.replaced = existingValue
      @array[index][key] = value

    return result

  # object or a string referencing a json file to require()
  # put it at the end of the array
  append: (thing, options) -> @_insert false, thing, options

  # object or a string referencing a json file to require()
  # put it at the front of the array
  prepend: (thing, options) -> @_insert true, thing, options

  # used by both append() and prepend()
  # append() sets first = false
  # prepend() sets first = true
  # coffeelint: disable cyclomatic_complexity
  _insert: (first, thing, options) ->

    switch typeof thing

      # a string should be a path to a file to read
      when 'string'

        # ensure absolute path
        thing = corepath.resolve thing

        # decide which way to conver the file contents into an object
        parse =
          # for a .json file, use require()
          if thing[-5..] is '.json' or options?.format is 'json' then readJson

          # for an '.ini' file, use readIni()
          else if thing[-4..] is '.ini' or options?.format is 'ini' then readIni

          # otherwise, it's not going to work
          else null

        # if it wasn't the right type, then parse doesn't exist
        unless parse? # so, return an error
          return error:'String must be a json or ini file'

        # now really try to parse the thing
        try
          object = parse thing

          # record the source is a file and the function called to add it
          # record the format too
          unless object.__source? then setSource object,
            file  : thing
            format: if parse is readJson then 'json' else 'ini'
            fn    : if first then 'prepend' else 'append'


        catch error
          # if it couldn't find the file then say so
          if error.code is 'MODULE_NOT_FOUND' or error.code is 'ENOENT'
            return error: 'File doesn\'t exist: ' + thing, exists: false

          # otherwise, be generic and include the real error object as `reason`
          return error: 'Failed to require file', reason: error


      # objects only need their source set, unless it is already
      when 'object'
        # record the source is the function called to add it
        object = thing
        unless object.__source?
          setSource object, (if first then 'prepend' else 'append')

      else # bad type, error out!
        return error: 'Must provide a string or object', value: thing

    # we made it, it's a good value, it has a __source, so add it in
    if first then @array.unshift object else @array.push object

    # all done
    return true

  # like with an array, remove sources from the front of the array
  # it returns the ones removed
  shift: (count = 1) ->
    if count < 1 then return removed:[]
    result = removed: @array[0...count]
    if count > 1 then @array.splice 0, count else @array.shift()
    return result

  # like with an array, remove sources from the end of the array
  # it returns the ones removed
  pop: (count = 1) ->
    if count < 1 then return removed:[]
    result = removed: @array[-count..]
    if count > 1 then @array.splice -count, count else @array.pop()
    return result


  write: (index = 0, options) ->

    # index must reference a valid source
    unless index > -1 and index < @array.length
      return error: 'Invalid index: ' + index

    # get the object we're supposed to write out
    object = @array[index]

    # get the 'source' of that object
    source = @source index

    # source must be a file...or, it must be specified in options
    file = options?.file ? source?.file
    unless file?
      return error:'No `file` in source #' + index + ' or in options'

    # get the extension of the file path so we can determine format
    ext = corepath.extname file

    # choose stringify based on specified format option or file extension
    # or the format it was read in as.
    # basically, it's ini only if they say so or the extension is, otherwise,
    # it's json
    stringify =
      if options?.format is 'ini' or source.format is 'ini' or ext is '.ini'
        ini.stringify.bind ini, object, whitespace:true

      # bind it so we can specify args and make it pretty print
      else JSON.stringify.bind JSON, object, null, 2

    # wrap it so we can return an `fs` modules error as an object
    try

      # do the work (add a newline at the end to ensure it's there...)
      fs.writeFileSync file, stringify() + '\n', 'utf8'

    catch error
      # return error, include a good message and the thrown error
      return error: 'Failed to write source #' + index, reason: error

    # restore the __source into the object
    finally
      setSource object, source

    # all done
    return

# export a function which creates a ValueStore instance
# it's not in a constructor so it can validate the input options and
# return an error all before trying to create the ValueStore
module.exports = (options) ->

  # find array as options object, in options object, or create an empty one
  if options?

    if Array.isArray options
      array = options
      options = array:array

    else if options.array?
      array = options.array

    else
      array = []
      options.array = array

  else
    array = []
    options = array:array

  for element, index in array
    if typeof element isnt 'object'
      # Note: returning an object with error property, not throwing an error
      return error: 'ValueStore accepts only objects. Invalid element at ' + index + ': ' + element

    else # mark these are from the constructor
      setSource element, 'constructor'

  new ValueStore options, true # true = validated

# export the class as a sub property on the function
module.exports.ValueStore = ValueStore
