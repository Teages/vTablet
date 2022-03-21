import { createApp } from 'vue'
import App from './App.vue'
import pinia from './plugins/pinia.js'
import './index.css'

createApp(App)
  .use(pinia)
  .mount('#app')
