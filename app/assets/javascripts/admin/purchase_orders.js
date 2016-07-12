var Hadean = window.Hadean || {};

// If we already have the Admin namespace don't override
if (typeof Hadean.Admin == "undefined") {
    Hadean.Admin = {};
}

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
          });

          jQuery('.select_variants').live('change', function(){
            //alert($(this).val());
            Hadean.Admin.purchaseOrder.prefillCost(this);
            return false;
          });
        },
        prefillCost : function(obj) {
          jQuery.ajax( {
             type : "GET",
             url : "/admin/merchandise/products/"+ 0 +"/variants/"+ $(obj).val(),
             complete : function(json) {
              variant = JSON.parse(json.responseText);
              variant.cost;
              $('#'+ obj.id.replace("variant_id", "cost")).val(variant.cost);
             },
             dataType : 'json'
          });
        }
    };

    jQuery(function() {
      Hadean.Admin.purchaseOrder.initialize();
    });
}
