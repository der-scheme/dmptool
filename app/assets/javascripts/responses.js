// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
  if (!Modernizr.inputtypes.date) {
    $("#response_date_value" ).datepicker({
    showOn: "button",
    buttonImage: "http://jqueryui.com/resources/demos/datepicker/images/calendar.gif",
    dateFormat: "yy-mm-dd",
    changeMonth: true,
    buttonImageOnly: true
    });
  }
});

$(function() {
	$('#save_only, #save_and_next').bind("click",function(e) {
    var selected = CKEDITOR.instances['response_text_value'].getData();
    if(selected == ""){
      $('#alert_message').dialog('open');
      e.preventDefault();
    }else{
      // let it go ahead
    }
  });

  $('#alert_message').dialog({
      autoOpen: false,
      width: 400,
      height: 100,
      modal: true,
      closeOnEscape: true,
      draggable: true,
      resizable: false,
      autoOpen: false,
      title: t('.alert_title'),
      show: {
        effect: "blind"
      },
      hide: {
        effect: "toggle"
      },
      open: function()
      {
        $('#alert_message').dialog("open");
      },
      close: function() {
        $('#alert_message').dialog("close");
      }
  });
});