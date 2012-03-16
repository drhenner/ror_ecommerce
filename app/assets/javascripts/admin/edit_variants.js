var Hadean = window.Hadean || {};

// If we already have the Appointments namespace don't override
if (typeof Hadean.Admin == "undefined") {
    Hadean.Admin = {};
}
var kk = null;
// If we already have the Appointments object don't override
if (typeof Hadean.Admin.products == "undefined") {

    Hadean.Admin.products = {
        //scheduled_at    : null,
        initialize      : function( ) {
          // If the user clicks add new variant button
          jQuery('.add_variant_child').live('click', function() {
            Hadean.Admin.products.addVariant();// product_table_body
          });
          jQuery('.remove_variant_child').live('click', function() {
            Hadean.Admin.products.removeVariant(this);// product_table_body
          });
        },
        addVariant : function(){
          var content =  $('#variants_fields_template').html() ;
          var regexp  = new RegExp('new_variants', 'g');
          var new_id  = new Date().getTime();
          $('#variants_container').append(content.replace(regexp, new_id));
          return false;
        },
        removeVariant : function(obj){
          kk = obj;
          jQuery(obj).closest( '.new_variant_container' ).html('');
        }
    };

    jQuery(function() {
      Hadean.Admin.products.initialize();
    });
};
