
var reload = function() {
  $.ajax({
    url: '/serv',
    success: function(res) {
      if (res) {
        $('#log ul').html(res);
      }
      reload();
    },
    error: function() {
      reload();
    }
  });
}
$(function() {
  reload();
  $('#forms form#statement').submit(function() {
    var input = $(this).find('input#say');
    var say = input.val()
    if (say == '') { return false; }
    input.val('');
    $.post('/say', { say: say }, function() {});
    return false;
  });
});

