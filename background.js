chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create(
    'window.html', 
    {
      'innerBounds': {
        'width': 1366,
        'height': 768
      }
    },
    function (window) {
      window.fullscreen();
    }
  );

  chrome.runtime.onMessage.addListener(
    function(signup) {
      chrome.syncFileSystem.requestFileSystem(function(fs) {
        var now = new Date();
        var file = (now.getMonth() + 1) + "-" + (now.getDate()) + "-" + (now.getFullYear()) + "-signups.csv";
        fs.root.getFile(file, {
          create: true
        }, function(f) {
          f.createWriter(function(fileWriter) {
            fileWriter.seek(fileWriter.length);
            var signupStr = signup.name + "," + signup.email + "," + signup.phone + "," + signup.zip + "," + signup.canText;
            fileWriter.write(new Blob([signupStr], {
              type: 'text/plain'
            }));
          });
        });
      });
    }
  );
});
