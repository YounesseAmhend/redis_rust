use std::time::Duration;

pub enum Expiry {
    Ex,
    Px,
}

impl Expiry {
    const VAL: [Self; 2] = [Self::Ex, Self::Px];

    pub fn from(value: &[u8]) -> Self {
        for val in Self::VAL {
            if val.value() == value {
                return val;
            }
        }
        panic!(
            "Failed to find a matching value for EXPIRY '{}'",
            String::from_utf8(value.to_vec()).unwrap()
        );
    }
    pub fn value(&self) -> &[u8] {
        match self {
            Self::Ex => b"EX",
            Self::Px => b"PX",
        }
    }
    pub fn to_duration(&self, value: u64) -> Duration {
        match self {
            Self::Ex => Duration::from_secs(value),
            Self::Px => Duration::from_millis(value),
        }
    }
}
