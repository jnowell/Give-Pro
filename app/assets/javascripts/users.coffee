# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
	$('#other_options').on 'click', -> otherOptions()

otherOptions = ->
  	ga('send', 'event', 'Register', 'Click', 'Other Options');
  	console.log 'All good' 
  	alert 'We are still working on this. Try again soon!'
  	return false