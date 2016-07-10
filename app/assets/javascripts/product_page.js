var Hadean = window.Hadean || { };
if (typeof Hadean.Product == "undefined") {
    Hadean.Product = {};
}
dd = null;
if (typeof Hadean.Product.tabs == "undefined") {
  Hadean.Product.tabs = {
    newFormId : '#new_cart_item',
    addToCart : true,

    initialize      : function() {
      $('#product_tabs .section-container section ').click(function() {
        //setTimeout('Hadean.Product.tabs.updateProductTabs()', 100);
      })
      //$('#product_tabs .section-container .section').first().find('a').click();
      //Hadean.Product.tabs.updateProductTabs();
    },
    updateProductTabs : function() {
      var heightOfTabContent = $('#product_tabs .section-container .section.active').height();
      if ( heightOfTabContent ) {
        $('#product_tabs .section-container').height(heightOfTabContent + 75);
      } else {
        $('#product_tabs .section-container').height(170);
        setTimeout('Hadean.Product.tabs.updateProductTabs()', 200);
      }
    }
  };
  jQuery(function() {
    Hadean.Product.tabs.initialize();
  });
};
