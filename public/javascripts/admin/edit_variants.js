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
          })
        },
        addVariant : function(){
          var content = '<tr>' + $('#variants_fields_template tr').html() + '</tr>';
          var regexp  = new RegExp('new_variants', 'g');
          var new_id  = new Date().getTime();
          $('#product_table_body').append(content.replace(regexp, new_id));
          return false;
        },
        removeVariant : function(){
          //
        }
    };

    jQuery(function() {
      Hadean.Admin.products.initialize();
    });
}
