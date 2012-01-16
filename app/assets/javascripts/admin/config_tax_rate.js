var Hadean = window.Hadean || {};


Hadean.Utility = {
  registerOnLoadHandler : function(callback) {
    jQuery(window).ready(callback);
  }
}

Hadean.TaxRateForm = {
  stateSelect : '#tax_rate_state_id',

  initialize : function() {
    var select_country  = '#select_country'
    jQuery(select_country).
            bind('change',
              function() {
                Hadean.TaxRateForm.getState(jQuery(select_country).val());
              }
            );
  },
  getState : function(id) {
    if ( ! isNaN(id - 0) && id  != "" ) {
      jQuery.getJSON(
         '/states',
         { country_id : id },
        function(json) {
           Hadean.TaxRateForm.refreshStates(json);
         }
      );
    }
  },
  refreshStates : function(json) {
    var newOptions = json;
    var select = jQuery(Hadean.TaxRateForm.stateSelect);
    var options = select.attr('options');

    jQuery('option', select).remove();// remove old options
    i = 1;
    jQuery.each(newOptions, function(val, text) {
      select[0].options[i] = new Option(text[0], text[1]);
      i = i + 1;
    });
  }
}