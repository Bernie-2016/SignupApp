$ ->
  # Set up masks for input fields
  $('#phone').mask('(999) 999-9999')
  $('#zip').mask('99999')

  # Size the form
  $('#form-container').css 'height', $(window).height() - $('#form-container').offset().top - $('.footer').height() - 50

  # Set up Dexie DB
  db = new Dexie('SignupApp')
  db.version(1).stores
    signups: '++id, first_name, last_name, email, phone, zip, canText, isStored'
  db.open()

  # Method to add signup to IndexedDB
  addSignup = (signup) ->
    db.signups.add(signup)

  # Method to store signup in file synced to Google Drive
  storeSignup = (signup) ->
    chrome.syncFileSystem.requestFileSystem (fs) ->
      now = new Date()
      file = "#{now.getMonth() + 1}-#{now.getDate()}-#{now.getFullYear()}-signups.csv"
      fs.root.getFile file, { create: true }, (f) ->
        f.createWriter (fileWriter) ->
          # Move to end of file
          fileWriter.seek(fileWriter.length)
          signupStr = "#{signup.name},#{signup.email},#{signup.phone},#{signup.zip},#{signup.canText}"
          fileWriter.write(new Blob([signupStr], { type: 'text/plain' }))
          console.log 'written'

  # Method to send signups to the API
  sendSignups = ->
    db.signups.where('isStored').equals(0).toArray().then( (unsent) ->
      return if unsent.length == 0
      $.ajax
        method: 'post'
        # url: 'https://sanders-api.herokuapp.com/api/v1/signups'
        url: 'http://localhost:3000/api/v1/signups'
        data: 
          signups: unsent
          secret: window.secret
        success: (response) ->
          for id in response.processed_ids
            db.signups.where('id').equals(parseInt(id)).delete()
    ).catch( (error) ->
      console.log error
    )

  # Validate inputs when they blur
  $('#signup-form input').on 'blur', ->
    if $(@).is(':invalid')
      $(@).addClass 'invalid'
    else
      $(@).removeClass 'invalid'

  # Handle form submission
  $('#signup-form').on 'submit', (event) =>
    event.preventDefault()
    if !$('#signup-form').is(':invalid')
      data = 
        first_name: $('#first_name').val()
        last_name: $('#last_name').val()
        email: $('#email').val()
        phone: $('#phone').val()
        zip: $('#zip').val()
        canText: $('#canText').is(':checked')
        isStored: 0

      addSignup(data)
      sendSignups()
      storeSignup(data)

      $('.submit').animate
        backgroundColor: '#4ACC66'
      , 500
      setTimeout ->
        $('.submit').val('Thanks!')
      , 250
      setTimeout ->
        $('.submit').animate
          backgroundColor: '#fd505e'
        , 500
      , 1500
      setTimeout ->
        $('.submit').val('Sign Me Up')
      , 1750
      setTimeout ->
        $('#signup-form')[0].reset()
        $('#name').focus()
      , 2000

  # "Secret" click to send the queue
  $('.footer img').on 'click', =>
    sendSignups()