import "./tailwind.css";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import Main from "./elm/Main.elm";

const app = Main.init({
  node: document.querySelector("main"),
});

// Listen for render events from Crux
listen("render", (event) => {
  const viewModel = event.payload;
  console.log(viewModel);
  app.ports.listenForViewModel.send(viewModel);
});

// Handle commands from Elm
if (app.ports?.sendACommandToCrux) {
  app.ports.sendACommandToCrux.subscribe(async (command) => {
    try {
      await invoke(command);
    } catch (error) {
      console.error("Tauri error:", error);
    }
  });
}
