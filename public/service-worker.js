self.addEventListener('install', () => {
  console.log('AssinaFacil App installed')
})

self.addEventListener('activate', () => {
  console.log('AssinaFacil App activated')
})

self.addEventListener('fetch', (event) => {
  event.respondWith(fetch(event.request))
})
