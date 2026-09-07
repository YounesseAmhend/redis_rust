pub enum Response {
    Ok,
    Pong,
}

impl Response {
    pub const fn value(&self) -> &[u8] {
        match self {
            Self::Ok => b"+OK\r\n",
            Self::Pong => b"+PONG\r\n",
        }
    }
}
