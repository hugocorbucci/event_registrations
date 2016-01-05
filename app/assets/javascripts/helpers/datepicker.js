//= require extensions/bootstrap-datepicker
//= require extensions/locales/bootstrap-datepicker.pt-BR

function set_datepicker(){
    var opts = {
        format: "dd/mm/yyyy",
        autoclose: true,
        todayBtn: true,
        todayHighlight: true,
        keyboardNavigation: true,
        language: 'pt-BR'
    };

    $('.datepicker').datepicker(opts);

    opts.startView = 1;
    opts.minViewMode = 1;
    $('.monthpicker').datepicker(opts);
}

function set_date(date){
  var date = date.split('/');
  $('.datepicker').datepicker('setDate', new Date(date[2], date[1]-1, date[0]));
}

$(function() {
  set_datepicker();
  $(document).on('persisted', set_datepicker);
  $(document).ajaxSuccess(set_datepicker);
});