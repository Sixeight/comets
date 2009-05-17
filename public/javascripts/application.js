
var reload = function() {
  $.ajax({
    url: '/serv',
    success: function(res) {
      $('#log').html(res);
      reload();
    },
    error: function() {
      reload();
    }
  });
}
$(function() {
  reload();
  $('form').submit(function() {
    var input = $(this).find('input#say');
    var say = input.val()
    input.val('');
    $.post('/say', { say: say }, function() {});
    return false;
  });
});

