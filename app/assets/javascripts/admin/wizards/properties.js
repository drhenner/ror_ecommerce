var Hadean = window.Hadean || {};

// If we already have the Admin namespace don't override
if (typeof Hadean.Admin == "undefined") {
    Hadean.Admin = {};
}
var kk = null;
// If we already have the purchaseOrder object don't override
if (typeof Hadean.Admin.properties == "undefined") {

    Hadean.Admin.properties = {
        //test    : null,
        initialize      : function( ) {
          // jQuery(".chzn-select").chosen();
          jQuery(".chzn-select").data("placeholder","Select Properties...").chosen();
        }
    };

    jQuery(function() {
      Hadean.Admin.properties.initialize();
    });
}
