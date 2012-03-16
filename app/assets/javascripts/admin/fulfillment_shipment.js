var Hadean = window.Hadean || {};

Hadean.FulfillmentNote = {
  orderId    : null,
  initialize : function() {
    $("#new_comment").submit(function(event) {
      // disable the submit button to prevent repeated clicks
      $('.comment-submit-button').attr("disabled", "disabled");

      //var amount = 1000; //amount you want to charge in cents
      Hadean.FulfillmentNote.submitForm();

      // prevent the form from submitting with the default action
      return false;
    });
  },
  submitForm : function() {
    jQuery.ajax({
      type : "POST",
      url: "/admin/fulfillment/orders/" + $('#new_comment').data('order_id') + "/comments",
      data : jQuery('#new_comment').serialize() ,
      success: function(jsonText){
        jQuery("#order_comments ul").append('<li>'+ jQuery("#comment_note").val() +'<li><hr/>');
        jQuery('#comment_note').val('');

        jQuery('.comment-submit-button').attr("disabled", false);
      },
      dataType: 'json'
    });
  }
};

jQuery(function() {
  Hadean.FulfillmentNote.initialize();
});