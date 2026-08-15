use shared::app::CounterEvent;
use shared::{Core, Effect, ElmTauriCruxExample, Event};
use std::sync::{Arc, LazyLock};
use tauri::Emitter;

// https://redbadger.github.io/crux/part-3/platforms/tauri.html#the-rust-backend
// The Rust backend is where the Crux core runs. We create a static Core instance and expose
// Tauri commands that forward events to the core. When the core requests a Render effect,
// we emit a Tauri event to the frontend with the updated view model.

// The Core is stored in a LazyLock<Arc<...>> so it can be shared across Tauri command handlers.
static CORE: LazyLock<Arc<Core<ElmTauriCruxExample>>> = LazyLock::new(|| Arc::new(Core::new()));

// Because the core is running directly in Rust, there is no serialization
// boundary between the shell and the core — we call core.process_event() directly.
pub fn handle_event(event: Event, core: &Arc<Core<ElmTauriCruxExample>>, app: &tauri::AppHandle) {
    for effect in core.process_event(event) {
        process_effect(&effect, core, app);
    }
}

// The Render effect is handled by calling app.emit("render", view), which sends
// the serialized ViewModel to the frontend as a Tauri event.
fn process_effect(effect: &Effect, core: &Arc<Core<ElmTauriCruxExample>>, app: &tauri::AppHandle) {
    match effect {
        Effect::Render(_) => {
            let view = core.view();
            let _ = app.emit("render", view);
        }
    }
}

#[tauri::command]
async fn increment(app_handle: tauri::AppHandle) {
    handle_event(Event::Counter(CounterEvent::Increment), &CORE, &app_handle);
}

#[tauri::command]
async fn decrement(app_handle: tauri::AppHandle) {
    handle_event(Event::Counter(CounterEvent::Decrement), &CORE, &app_handle);
}

#[tauri::command]
async fn reset(app_handle: tauri::AppHandle) {
    handle_event(Event::Counter(CounterEvent::Reset), &CORE, &app_handle);
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![increment, decrement, reset])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
