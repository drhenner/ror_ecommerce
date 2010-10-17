var Hadean = window.Hadean || { };
Hadean.Utility = {
  registerOnLoadHandler : function(callback) {
    jQuery(window).ready(callback);
  }
};

Hadean.Cart = {
  NewForm : {
    newFormId : '#new_cart_item',
    addToCart : true,
    
    initialize      : function() {
      jQuery('.add-to-cart').click( function() { 
          if (jQuery('#cart_item_variant_id').val() == '' ) { // Select to see if variant is selected in hidden field
            alert('Please click on a specific item to add.');
          } else 
          if (Hadean.Cart.NewForm.addToCart) {
            
           // Hadean.Cart.NewForm.addToCart = false;// ensure no double clicking
            jQuery(Hadean.Cart.NewForm.newFormId).submit();
            // We might want to submit as an ajax request. Then return the result to a light box.  (create an overlay on click)
            
          }
        } 
      )
      // This code is to change the color of the selected and non-selected variants
      jQuery('.variant_border').click( function() { 
          jQuery('#cart_item_variant_id').val(this.getAttribute("data-variant"));
          jQuery('.variant_border')
          jQuery(".variant_border").css("border","solid 2px #ddc");
          jQuery(".variant_border").css("background-color","#EED");
          jQuery(this).css("border","solid 2px #cee");
          jQuery(this).css("background-color","#dFF");
        } 
      )

    }
  }
}