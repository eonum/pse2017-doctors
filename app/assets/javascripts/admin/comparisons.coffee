# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

toggleRawHTMLField = () =>
  iconDropdown = $("#icon-dropdown")
  rawHTMLField = $("#rawHTMLField")
  if(iconDropdown.val() == '')
    rawHTMLField.show()
  else
    rawHTMLField.hide()

$(document).on 'ready page:load', () =>
  $("#icon-dropdown").change => toggleRawHTMLField()
  toggleRawHTMLField()