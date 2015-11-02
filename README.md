# Signup App

Chrome app for people at events to sign up for Bernie Sanders mails.

## Development

### Prerequisites

* git
* npm
* bower (`npm install -g bower`)

### Setup

1. Clone the repository (`git clone git@github.com:Bernie-2016/SignupApp.git`)
2. Copy `coffee/secret.coffee.example` to `coffee/secret.coffee` and fill in the API secret.
3. Install npm dependencies: `npm install`
4. Install bower dependencies: `bower install`
5. Build assets: `grunt`
6. Follow step 5 on [this page](https://developer.chrome.com/apps/first_app#five) to open the app in Chrome.

The default grunt task compiles CoffeeScript and concatenates/minifies everything into `dist/`. `grunt watch` re-runs the default task whenever a source file changes. `grunt build` runs the default task and builds necessary files into a zipfile, to be uploaded through the Chrome developer console.

## Contributing

1. Fork it ( https://github.com/Bernie-2016/SignupApp/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## License

[AGPL](http://www.gnu.org/licenses/agpl-3.0.en.html)
