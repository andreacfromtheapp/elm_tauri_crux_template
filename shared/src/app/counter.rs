use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug, Copy)]
pub enum Event {
    Increment,
    Decrement,
    Reset,
}

#[derive(Default)]
pub struct Model {
    pub count: isize,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ViewModel {
    pub count: isize,
}

impl Model {
    pub const fn update(&mut self, event: Event) {
        match event {
            Event::Increment => self.count += 1,
            Event::Decrement => self.count -= 1,
            Event::Reset => self.count = 0,
        }
    }

    #[must_use]
    pub const fn view(&self) -> ViewModel {
        ViewModel { count: self.count }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn increments() {
        let mut model = Model::default();
        model.update(Event::Increment);
        assert_eq!(model.view().count, 1);
    }

    #[test]
    fn decrements() {
        let mut model = Model::default();
        model.update(Event::Decrement);
        assert_eq!(model.view().count, -1);
    }

    #[test]
    fn resets() {
        let mut model = Model::default();
        model.update(Event::Increment);
        model.update(Event::Reset);
        assert_eq!(model.view().count, 0);
    }
}
