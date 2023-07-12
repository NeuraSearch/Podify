# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin 'ahoy', to: 'ahoy.js'
pin 'tailwind-scrollbar-hide', to: 'https://ga.jspm.io/npm:tailwind-scrollbar-hide@1.1.7/src/index.js'
pin 'tailwindcss/plugin', to: 'https://ga.jspm.io/npm:tailwindcss@3.1.8/plugin.js'
pin 'stimulus-dropdown', to: 'https://ga.jspm.io/npm:stimulus-dropdown@2.0.0/dist/stimulus-dropdown.es.js'
pin '@hotwired/stimulus', to: 'https://ga.jspm.io/npm:@hotwired/stimulus@3.0.1/dist/stimulus.js'
pin 'hotkeys-js', to: 'https://ga.jspm.io/npm:hotkeys-js@3.9.3/dist/hotkeys.esm.js'
pin 'stimulus-use', to: 'https://ga.jspm.io/npm:stimulus-use@0.50.0/dist/index.js'
pin 'sortablejs', to: 'https://ga.jspm.io/npm:sortablejs@1.15.0/modular/sortable.esm.js'
pin '@rails/ujs', to: 'https://ga.jspm.io/npm:@rails/ujs@6.0.5/lib/assets/compiled/rails-ujs.js'
pin 'flowbite', to: 'https://ga.jspm.io/npm:flowbite@1.6.3/lib/esm/index.js'
pin '@popperjs/core', to: 'https://ga.jspm.io/npm:@popperjs/core@2.11.6/lib/index.js'

pin 'like_dislike'
pin_all_from 'app/javascript/controllers', under: 'controllers'
