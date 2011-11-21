var Hadean = window.Hadean || {};

// If we already have the Admin namespace don't override
if (typeof Hadean.Admin == "undefined") {
    Hadean.Admin = {};
}
var kk = null;
// If we already have the purchaseOrder object don't override
if (typeof Hadean.Admin.purchaseOrder == "undefined") {

    Hadean.Admin.purchaseOrder = {
        //test    : null,
        initialize      : function( ) {
          jQuery(".chzn-select").chosen();

          jQuery('.add_variant').bind('click', function(){
            var assoc = $(this).attr('data-association');
            var content = $('#' + assoc + '_fields_template').html();
            var regexp = new RegExp('new_' + assoc, 'g');
            var new_id = new Date().getTime();
            $(this).parent().before(content.replace(regexp, new_id));
            jQuery('#purchase_order_purchase_order_variants_attributes_'+ new_id +'_variant_id').addClass('chzn-select');
            jQuery(".chzn-select").chosen();
            return false;
          })
        }
    };

    jQuery(function() {
      Hadean.Admin.purchaseOrder.initialize();
    });
}
