
# TODO:
# consider extending EventEmitter to provide events when:
#  1. value is set, can provide old value
#  2. value is added (set, but combined)
#  3. value is removed, can provide old value
#  4. object is appended/prepended
#  5. object is shift()'ed or pop()'ed

class ValueStore

  constructor: (options) ->

    # builder function can validate and return an error instead of throwing it
    # so, it marks it with __validated.
    # if that doesn't exist, then, we need to do it here, and, in a constructor
    # we can't return an error, so, we must throw it instead
    unless options.__validated
      # find array as options object, in options object, or create an empty one
      array = if Array.isArray(options) then options else options.array ? []

      # verify each element is an object
      for element,index in array
        if typeof element isnt 'object'
          # Note: throwing an error cuz we're in a constructor.
          # should use the exported builder function instead of the class
          throw new Error 'ValueStore accepts only objects. Invalid element at ' + index + ': ' + element

        else # mark these are from the constructor, unless it's already set
          element.__source ?= 'constructor'

    else # it was validated and is ready to go, so grab array and delete marker
      array = options.array
      delete array.__validated

    # store it
    @array = array


  # how many value sources do we have
  count: () -> @array.length

  # where did the specified source come from
  source: (index = 0) -> @array[index]?.__source

  # get a value from a source, get from the first one by default
  get: (key, index = 0) -> @array?[index]?[key]

  # same as get except return a boolean representing whether the value exists
  has: (key, index = 0) -> @array?[index]?[key]?

  # return the index of the first object source which contains the key
  in: (key) ->
    for object,index in @array
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

  # delete the key from the indexed source, defaults to the first one
  remove: (key, index = 0) -> @set key, undefined, index, false

  # used by add() with `add` = true
  # used by remove() with `add` = false
  # is set() when `add` is undefined
  # set() will set this value as "the value",
  # it overwrites a current value if there is one.
  set: (key, value, index = 0, add) ->

    # make sure we have what we need
    unless key? then return error:'No key specified'

    # if add is false then it's remove() so we don't need the value,
    # or, if value exists, we're good
    unless add is false or value? then return error:'No value specified'

    # also index must reference a valid source
    unless index > -1 and index < @array.length
      return error:'Invalid index: '+index

    # add() sends us here
    if add is true # then combine values into an array
      # get current value
      existingValue = @array[index][key]

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

    # remove() sends us here
    else if add is false # then remove value
      delete @array[index][key]

    # set() gets here
    else # set the value
      @array[index][key] = value

    return true

  # object or a string referencing a json file to require()
  # put it at the end of the array
  append: (thing) -> @_insert false, thing

  # object or a string referencing a json file to require()
  # put it at the front of the array
  prepend: (thing) -> @_insert true, thing

  # used by both append() and prepend()
  # append() sets first = false
  # prepend() sets first = true
  _insert: (first, thing) ->

    switch typeof thing
      when 'string'

        # check if it's a json file...
        if thing[-5..] is '.json'

          # try to require it
          try
            object = require thing

            # record the source is a file and the function called to add it
            object.__source ?=
              file: thing
              fn  : if first then 'prepend' else 'append'

          catch error
            # if it couldn't find the file then say so
            if error.code is 'MODULE_NOT_FOUND'
              return error:'File doesn\'t exist: '+thing

            # otherwise, be generic and include the real error object as `reason`
            return error:'Failed to require file', reason:error

        # it's not a json file!
        else
          return error:'String must be a require()\'able file with extension \'.json\''

      # objects only need their source set, unless it is already
      when 'object'
        # record the source is the function called to add it
        object = thing
        object.__source ?= if first then 'prepend' else 'append'

      else # bad type, error out!
        return error:'Must provide a string or object', value:thing

    # we made it, it's a good value, it has a __source, so add it in
    if first then @array.unshift object else @array.push object

    # all done
    return true

  # like with an array, remove sources from the front of the array
  # it returns the ones removed
  shift: (count = 1) ->
    if count < 1 then return removed:[]
    removed:@array[...count]

  # like with an array, remove sources from the end of the array
  # it returns the ones removed
  pop: (count = 1) ->
    if count < 1 then return removed:[]
    removed:@array[-count..]

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

  for element,index in array
    if typeof element isnt 'object'
      # Note: returning an object with error property, not throwing an error
      return error: 'ValueStore accepts only objects. Invalid element at ' + index + ': ' + element

    else # mark these are from the constructor
      element.__source = 'constructor'

  # let constructor know we've validated the options
  options.__validated = true

  new ValueStore options

# export the class as a sub property on the function
module.exports.ValueStore = ValueStore
