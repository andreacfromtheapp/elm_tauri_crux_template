use crux_core::{
    App, Command,
    macros::effect,
    render::{RenderOperation, render},
};
use serde::{Deserialize, Serialize};

mod counter;
pub use counter::{Event as CounterEvent, Model as CounterModel, ViewModel as CounterViewModel};

#[effect]
#[derive(Debug)]
pub enum Effect {
    Render(RenderOperation),
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum Event {
    Counter(CounterEvent),
}

#[derive(Default)]
pub struct Model {
    counter: CounterModel,
}

#[derive(Default)]
pub struct ElmTauriCruxExample;

impl App for ElmTauriCruxExample {
    type Event = Event;
    type Model = Model;
    type ViewModel = ViewModel;
    type Effect = Effect;

    fn update(&self, event: Event, model: &mut Model) -> Command<Effect, Event> {
        match event {
            Event::Counter(counter_event) => model.counter.update(counter_event),
        }

        render()
    }

    fn view(&self, model: &Model) -> ViewModel {
        ViewModel {
            counter: model.counter.view(),
        }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ViewModel {
    pub counter: CounterViewModel,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn routes_counter_events() {
        let app = ElmTauriCruxExample;
        let mut model = Model::default();

        app.update(Event::Counter(CounterEvent::Increment), &mut model)
            .expect_only_render();
        app.update(Event::Counter(CounterEvent::Increment), &mut model)
            .expect_only_render();

        let view = app.view(&model);
        assert_eq!(view.counter.count, 2);
    }

    #[test]
    fn independent_tab_states() {
        let app = ElmTauriCruxExample;
        let mut model = Model::default();

        app.update(Event::Counter(CounterEvent::Increment), &mut model)
            .expect_only_render();

        let view = app.view(&model);
        assert_eq!(view.counter.count, 1);
    }
}
