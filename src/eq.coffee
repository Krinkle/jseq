


############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'jsEq/jseq'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
urge                      = TRM.get_logger 'urge',      badge
praise                    = TRM.get_logger 'praise',    badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
LODASH                    = require 'lodash'



#-----------------------------------------------------------------------------------------------------------
options =
  'ordering':             no
  'signed-zeroes':        no
  'functions':            yes
  'NaN':                  yes
  'properties':           yes
  'primitive-and-object': yes

#-----------------------------------------------------------------------------------------------------------
type_of   = ( x           ) -> Object::toString.call x
types_eq  = ( x, y, probe ) -> probe == ( type_of x ) == ( type_of y )

#-----------------------------------------------------------------------------------------------------------
have_same_object_type = ( a, b ) ->
  return true if ( a instanceof String ) and ( b instanceof String )
  return true if ( a instanceof Number ) and ( b instanceof Number )
  return true if ( a instanceof Boolean ) and ( b instanceof Boolean )
  return true if ( a instanceof Array ) and ( b instanceof Array )
  return true if ( a instanceof RegExp ) and ( b instanceof RegExp )
  return false

#-----------------------------------------------------------------------------------------------------------
new_ = ( options_or_handler, self ) ->
  if ( type_of options_or_handler ) is '[object Function]'
    handler   = options_or_handler
    settings  = options
  else
    settings  = LODASH.merge {}, options, ( options_or_handler ? {} )
    handler   = null
  #---------------------------------------------------------------------------------------------------------
  properties_are_equal = ( a, b, all = true ) ->
    ### TAINT should we check for property descriptors? ###
    pa = {}; pa[ name ] = value for name, value of a when all or not ( 0 <= name < a.length )
    pb = {}; pb[ name ] = value for name, value of b when all or not ( 0 <= name < b.length )
    # whisper a instanceof String
    # whisper pa, pb
    return eq pa, pb
  #---------------------------------------------------------------------------------------------------------
  return eq = ( P... ) ->
    if ( arity = P.length ) < 2
      throw new Error "need at least 2 arguments, got #{arity}"
    else
      # stackA = []
      # stackB = []
      # eq_ =
      # length = stackA.length;
      # while ( length -= 1 ) >= 0
      #   if stackA[ length ] is a
      #     return stackB[ length ] is b
      R = true
      for idx in [ 1 ... P.length ]
        #...................................................................................................
        R = R and LODASH.isEqual P[ 0 ], P[ idx ], ( a, b ) ->
          if handler? then return handler a, b
          #.................................................................................................
          if a == 0 and b == 0 and settings[ 'signed-zeroes' ]
            ### taken verbatim from lodash: ###
            return not `a !== 0 || (1 / a == 1 / b )`
          #.................................................................................................
          if settings[ 'functions' ]
            if types_eq a, b, '[object Function]'
              if a.toString() isnt b.toString() then return false
              if settings[ 'properties' ]       then return properties_are_equal a, b, true
          #.................................................................................................
          if not settings[ 'NaN' ]
            ### isNaN is broken as per MDN, so we don't use it ###
            if ( a != a ) and ( b != b ) then return false
          #.................................................................................................
          if settings[ 'properties' ] and have_same_object_type a, b
            all = not ( type_of a, '[object Array]' ) or ( type_of a, '[object String]' )
            if not properties_are_equal a, b, all then return false
          #.................................................................................................
          return undefined
        #...................................................................................................
        return R if not R
      return R

#-----------------------------------------------------------------------------------------------------------
module.exports      = new_()
module.exports.new  = new_

