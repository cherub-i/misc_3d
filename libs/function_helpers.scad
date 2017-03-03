////////////////////////////////////////////////////////////////////////////////////////////////////
// copyright by Bastian Baumeister | openscad@bastianbaumeister.de 
// function helpers, not rendering any objects
////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// assert_greater(a ,b, errormessage)
// assert_greater_or_equal(a ,b, errormessage)
// assert_lesser(a ,b, errormessage)
// assert_lesser_or_equal(a ,b, errormessage)
//   asserts, that a is in relation to b what the function name says
//   errormessage should explain what a and b are (semantics), numeric values of a and b are output by the functions
//
// assert_is_element_of: to check wether value is part of a list
//   asserts if the given string-element is part of a list, list must be formes as a nested array: [["listitem1",1],["listitem2",2],...]
// 
// assert(bool,msg) 
//   if assertion criteria "err" evaluates to true, the assertion fails and outputs msg
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module assert_greater(a,b,msg) {
  //asserts if a is bigger than b
  if (a<=b) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo("a>b failed for a:",a, " b:",b, msg);
    echo("", assertion_failed());
  }
}

module assert_greater_or_equal(a,b,msg) {
  //asserts if a is bigger than b
  if (a<b) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo("a>=b failed for a:",a, " b:",b, msg);
    echo("", assertion_failed());
  }
}

module assert_lesser(a,b,msg) {
  //asserts if a is bigger than b
  if (a>=b) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo("a<b failed for a:",a, " b:",b, msg);
    echo("", assertion_failed());
  }
}

module assert_lesser_or_equal(a,b,msg) {
  //asserts if a is bigger than b
  if (a>b) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo("a<=b failed for a:",a, " b:",b, msg);
    echo("", assertion_failed());
  }
}

module assert_is_element_of(elem,list,msg) {
  found=search([elem],list);
  if(!(found[0]>=0)) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo("element must be part of list failed for elem:",elem, " list:",list, msg);
    echo("", assertion_failed());
  }    
}

module assert(bool,msg) {
  if (bool) {
    echo("<font color='red'><b>assertion failed</b></font>");
    echo(msg);
    echo("", assertion_failed());
  }
}

function assertion_failed() = (assertion_failed());