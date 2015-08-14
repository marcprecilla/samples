/*
    (c) 2013 by DBJ.ORG, GPL/MIT applies

    expr argument is any legal jQuery selector.
    returns array of { element: , events: } objects
    events: is jQuery events structure attached (as  data)
    to the element:
    return is null if no events are found
 */
jQuery.events = function (expr ) {
      var rez = [], evo ;
       jQuery(expr).each(
          function () {
             if ( evo = jQuery._data( this, "events"))
               rez.push({ element: this, events: evo }) ;
         });
     return rez.length > 0 ? rez : null ;
}
