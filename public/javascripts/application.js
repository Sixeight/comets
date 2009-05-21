var error_count = 0;
var reload = function() {
  $.ajax({
    url: '/serv',
    success: function(res) {
      if (res) {
        var statement = $(res).hide();
        $('#log ul').prepend(statement);
        statement.slideDown('fast');
      }
      reload();
    },
    error: function() {
      if (++error_count == 5) { return false; }
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

