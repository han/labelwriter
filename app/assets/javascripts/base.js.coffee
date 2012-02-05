$ ->
  $(".alert").alert()

  $(".delete").on 'click', (event) ->
    $("#deletion_modal").data('url', $(event.target).data('url'))
    $("#deletion_modal_desc").html($(event.target).data('desc'))
    $("#deletion_modal").modal("show")
    false

  $("#delete_ok").on 'click', ->
    url = $("#deletion_modal").data('url')
    authenticityCode = $('meta[name="csrf-token"]').attr('content');
    $(this).html("<form style='display:none' method='POST' action='#{url}'>
      <input type='hidden' name='_method' value='delete'>
      <input type='hidden' name='authenticity_token' value='#{authenticityCode}'>
      </form>"
    )
    $("form", this)[0].submit()

  $("#delete_cancel").on 'click', ->
    $("#deletion_modal").modal("hide")

