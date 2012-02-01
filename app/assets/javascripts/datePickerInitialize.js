
jQuery(document).ready(function(){
  jQuery('input.ui-datepicker').datepicker();
  jQuery('input.ui-futurepicker').datepicker({ yearRange: '2010:2020', changeYear: true });
  jQuery('input.ui-yearpicker').datepicker({ yearRange: '1910:2000',
                                              changeYear: true,
                                              constrainInput: true, showOn: "button",
                                                        buttonImage: '/assets/icons/calendar_sm.png',
                                                        buttonImageOnly: true});
});
