$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Set up Dexie DB
  db = new Dexie('SignupApp')
  db.version(1).stores
    signups: '++id, name, email, phone, zip, canText'
  db.open()

  $('#signup-form input').on 'blur', ->
    if $(@).valid()
      $(@).removeClass 'invalid'
    else
      $(@).addClass 'invalid'

  $('#signup-form').on 'submit', (event) ->
    event.preventDefault()
    if $('#signup-form').validate().valid()
      db.signups.add
        name: $('#name').val()
        email: $('#email').val()
        phone: $('#phone').val()
        zip: $('#zip').val()
        canText: $('#canText').is(':checked')
    else
      alert 'not valid'