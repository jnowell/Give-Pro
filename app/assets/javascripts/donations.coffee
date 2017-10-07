# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# //$(".donation-thermometer").html("<%= raw render 'shared/income.html.erb' %>")

$(document).ready ->
  $("#goal_form").on 'submit', -> calculateGoal()
  $(".edit_user").on("ajax:success", (e, data, status, xhr) ->  
    $(".donation-thermometer").html(data)
    $(".donation-thermometer").show()
    $(".edit_user").hide()
    goal = $("#span_goal_percent")
    $('.donation-meter .glass .amount').css('height',goal[0].firstChild.textContent);
  ).on "ajax:error", (e, xhr, status, error) ->
    #Flesh this out a little
    $(".edit_user").hide()

calculateGoal = ->
  	ga('send', 'event', 'Donations', 'Submit', 'Calculate Goal')
  	console.log 'All good'