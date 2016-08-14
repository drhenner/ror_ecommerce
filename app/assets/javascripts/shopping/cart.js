var Hadean = window.Hadean || { };
if (typeof Hadean.Cart == "undefined") {
    Hadean.Cart = {};
}
dd = null;
if (typeof Hadean.Cart.newForm == "undefined") {
  Hadean.Cart.newForm = {
    newFormId : '#new_cart_item',
    addToCart : true,

    initialize      : function() {
      jQuery('#submit_add_to_cart').click( function() {
          if (jQuery('#cart_item_variant_id').val() == '' ) { // Select to see if variant is selected in hidden field
            alert('Please click on a specific item to add.');
          } else
          if (Hadean.Cart.newForm.addToCart) {

            Hadean.Cart.newForm.addToCart = false;// ensure no double clicking
            jQuery(Hadean.Cart.newForm.newFormId).submit();

          }
        }
      )
      // This code is to change the color of the selected and non-selected variants
      jQuery('.variant_select').click( function() {

          jQuery('.variant_properties').each( function(index, obj) {
            jQuery(obj).addClass('is-hidden');
          });

          var stockId = '.variant_stock_' + $(this).data("variant_id");
          jQuery('.variant_stock').addClass('is-hidden');
          jQuery(stockId).removeClass('is-hidden');

          var propId = '#variant_properties_' + $(this).data("variant_id");
          jQuery(propId).removeClass('is-hidden');
          jQuery('#cart_item_variant_id').val($(this).data("variant_id"));
          jQuery(".variant_select").removeClass('success');
          jQuery(".variant_select").addClass('secondary');
          jQuery(".variant_select").removeClass('selected_variant');
          jQuery(this).addClass('selected_variant');
          jQuery(this).removeClass('secondary');
          jQuery(this).addClass('success');
          //jQuery('#submit_add_to_cart').removeClass('add-to-cart').addClass('ready-to-add-to-cart');
        }
      );
    }
  };
  jQuery(function() {
    Hadean.Cart.newForm.initialize();
  });
};
