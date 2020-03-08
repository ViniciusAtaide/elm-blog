import { Elm } from "./src/Main.elm"

const APP_NAME = "__MY_APP__"

const app = Elm.Main.init({
  node: document.querySelector("#elm"),
  flags: {
    storedToken: localStorage.getItem(APP_NAME)
  }
})

app.ports.sendTokenToStorage.subscribe(token => {
  localStorage.setItem(APP_NAME, token)
})

app.ports.clearTokenFromStorage.subscribe(() => {
  localStorage.removeItem(APP_NAME)
})
