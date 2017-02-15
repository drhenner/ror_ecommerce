jQuery(document).ready(function($) {
  $("#create-shipment-button").click(function() {
    var url = $(this).data("url");
    jQuery.ajax( {
      type : "PUT",
      url : url,
      dataType: 'script'
    });
    return false;
  });
});

var Hadean = window.Hadean || {};

Hadean.Fulfillment = {
  captureInvoiceButton      : '#capture-invoice-button-',
  capturePartInvoiceButton  : '#capture-partial-invoice-button-',
  cancelInvoiceButton       : '#cancel-invoice-button-',
  orderId                   : null,

  initialize : function(invoiceId, order_id) {

    var captureTag      = jQuery(Hadean.Fulfillment.captureInvoiceButton + invoiceId );
    var capturePartTag  = jQuery(Hadean.Fulfillment.capturePartInvoiceButton + invoiceId);
    var cancelTag       = jQuery(Hadean.Fulfillment.cancelInvoiceButton + invoiceId);
    Hadean.Fulfillment.orderId = order_id;

    jQuery("#dialog").dialog({
      //bgiframe: true,
      autoOpen: false,
      height: 190,
      width: 460,
      modal: true
    });

    captureTag.
            bind('click',
              function() {
                // submit to collect all payments
                Hadean.Fulfillment.captureInvoice(invoiceId);
              }
            );


    capturePartTag.
            bind('click',
              function() {
                // submit to go to capture part form
                // capture part form has cancel order-items
              }
            );

    cancelTag.
            bind('click',
              function() {
                // submit to go to cancel order and payment

                Hadean.Fulfillment.cancelInvoice(invoiceId);
              }
            );
  },//END of INITIALIZE
  captureInvoice : function(invoiceId) {
    jQuery('#dialog').dialog( 'option',
                              'buttons',
                              [
                                {
                                  text: "OK" ,
                                  click: function() {
                                    // Make an ajax request to cancel the invoice
                                    jQuery.ajax( {
                                      type : "PUT",
                                      url : '/admin/fulfillment/orders/' + Hadean.Fulfillment.orderId ,
                                      data : {invoice_id : invoiceId, amount : 'all' } ,
                                      complete : function(htmlText) {
                                        if (htmlText.status == 200) {
                                          //jQuery('#invoice-line-' + invoiceId).html( htmlText.responseText);
                                          //$(this).dialog("close");
                                          jQuery('#dialog-message').html(htmlText.responseText);
                                        } else {
                                          jQuery('#dialog-message').html(htmlText.responseText);
                                        }

                                      },
                                      dataType : 'html'
                                    });
                                  }
                                },
                                {
                                  text: "Close",
                                  click: function() { $(this).dialog("close"); }
                                }
                              ]
                            );
    jQuery('#dialog-message').html('Are you sure you want to COLLECT FUNDS for this order?');
    jQuery('#dialog-message').css('background-color', '#CFD');
    jQuery('.ui-dialog-title').text('Collect Invoice');
    jQuery('#dialog').dialog('open');
    return false;
  },// cancelInvoice
  cancelInvoice : function(invoiceId) {

    jQuery('#dialog').dialog( 'option',
                              'buttons',
                              [
                                {
                                  text: "OK" ,
                                  click: function() {
                                    // Make an ajax request to cancel the invoice
                                    jQuery.ajax( {
                                      type : "DELETE",
                                      url : '/admin/fulfillment/orders/' + Hadean.Fulfillment.orderId ,
                                      data : {invoice_id : invoiceId } ,
                                      complete : function(htmlText) {
                                        if (htmlText.status == 200) {
                                          jQuery('#invoice-line-' + invoiceId).html( htmlText.responseText);
                                          jQuery('#dialog').dialog("close");
                                        } else {
                                          jQuery('#dialog-message').html('Sorry there was an error.');
                                        }

                                      },
                                      dataType : 'html'
                                    });
                                  }
                                },
                                {
                                  text: "Close",
                                  click: function() { $(this).dialog("close"); }
                                }
                              ]
                            );
    jQuery('#dialog-message').html('Are you sure you want to CANCEL the Order and Shipment?');
    jQuery('#dialog-message').css('background-color', '#FCD');
    jQuery('.ui-dialog-title').text('Cancel Invoice');
    jQuery('#dialog').dialog('open');
    return false;
  }// cancelInvoice
};

jQuery(function() {
  jQuery.each(jQuery('.order-invoice'), function(index, obj){
    Hadean.Fulfillment.initialize(jQuery(obj).data('invoice_id'), jQuery(obj).data('order_id'));
  })

});
