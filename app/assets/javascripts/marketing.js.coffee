# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  offset = $("#the-main-container").offset()
  if offset.left > 160
    offset.top =  offset.top + 10 
    offset.left =  offset.left - 170 
    $("#the-left-side-ad").css("position", "absolute")
    $("#the-left-side-ad").offset(offset)
   
  $("#the-left-side-ad").show()


  