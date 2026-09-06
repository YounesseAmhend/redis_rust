use crate::lib::DELIMITER;


pub enum RespType {
    Array,
    BulkString,
    NullBulkString,
}

impl RespType {
    pub const fn token(&self) -> u8 {
        match self {
            Self::Array => b'*',
            Self::BulkString => b'$',
            Self::NullBulkString => panic!("this should never be called"),
        }
    }

    pub fn encode(&self, value: &[u8]) -> Box<[u8]> {
        match self {
            Self::BulkString => encode_bulk_string(value),
            Self::NullBulkString => Box::new(*b"$-1\r\n"),
            _ => panic!("Not implemented"),
        }
    }
}
fn encode_bulk_string(buf: &[u8]) -> Box<[u8]> {
    let len: u8 = buf.len() as u8 + b'0';
    println!(
        "buff '{}'",
        String::from_utf8(buf.to_vec()).expect("failed to decode utf8")
    );
    [RespType::BulkString.token()]
        .iter()
        .chain(&[len])
        .chain(DELIMITER)
        .chain(buf)
        .chain(DELIMITER)
        .map(|&x| x)
        .collect()
}