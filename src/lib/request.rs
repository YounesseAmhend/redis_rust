use std::net::TcpStream;
use std::{io::Write, thread};

use crate::{
    BUCKET,
    lib::{DELIMITER, Expiry, RespType, Response},
};
use crate::{DB_FILENAME, DIR};

#[derive(PartialEq)]
pub enum Request {
    Ping,
    Echo,
    Get,
    Set,
    Config,
}
impl Request {
    const ALL: [Self; 5] = [Self::Ping, Self::Set, Self::Echo, Self::Get, Self::Config];

    pub const fn value(&self) -> &[u8] {
        match self {
            Request::Ping => b"PING",
            Request::Echo => b"ECHO",
            Request::Get => b"GET",
            Request::Set => b"SET",
            Request::Config => b"CONFIG",
        }
    }

    pub fn handle(&self, _stream: &mut TcpStream, parts: Box<[&[u8]]>) {
        let _ = match self {
            Request::Ping => handle_ping(_stream),
            Request::Set => handle_set(_stream, &parts),
            Request::Get => handle_get(_stream, &parts),
            Request::Echo => handle_echo(_stream, &parts),
            Request::Config => handle_config(_stream, &parts),
        };
    }
    pub fn from(value: &[u8]) -> Self {
        for re in Self::ALL {
            if re.value() == value {
                return re;
            }
        }
        panic!(
            "Found no request type with '{}'",
            String::from_utf8(value.to_vec()).unwrap()
        );
    }
}

fn handle_config(_stream: &mut TcpStream, parts: &Box<[&[u8]]>) -> Result<usize, std::io::Error> {
    let command = parts[1];
    if command == b"GET" {
        let request_config = parts[2];
        if request_config == b"dir" {
            let buf = &DIR.read().unwrap().clone().unwrap();
            return _stream.write(&encode_bulk_string(buf));
        } else if request_config == b"dbfilename" {
            let buf = &DB_FILENAME.read().unwrap().clone().unwrap();
            return _stream.write(&encode_bulk_string(buf));
        }
    }
    panic!("FUCK YOU")
}

fn handle_echo(_stream: &mut TcpStream, parts: &Box<[&[u8]]>) -> Result<usize, std::io::Error> {
    parts.iter().for_each(|part| {
        println!("part {}", String::from_utf8(part.to_vec()).unwrap());
    });
    _stream.write(&encode_bulk_string(parts[1]))
}

fn handle_get(_stream: &mut TcpStream, parts: &Box<[&[u8]]>) -> Result<usize, std::io::Error> {
    let key = String::from_utf8(parts[1].to_vec()).expect("Failed to decode");

    if let Some(value) = BUCKET.read().unwrap().get(&key) {
        _stream.write(&encode_bulk_string(value.as_bytes()))
    } else {
        _stream.write(&RespType::NullBulkString.encode(&[]))
    }
}

fn handle_set(_stream: &mut TcpStream, parts: &Box<[&[u8]]>) -> Result<usize, std::io::Error> {
    let key = String::from_utf8(parts[1].to_vec()).expect("Failed to decode key");
    let value = String::from_utf8(parts[2].to_vec()).expect("Failed to decode value");

    println!("key {} value {}", key, value);
    BUCKET.write().unwrap().insert(key.clone(), value);

    if parts.len() == 5 {
        let expiry = Expiry::from(parts[3]);
        let value: u64 = str::from_utf8(parts[4]).unwrap().parse().unwrap();
        let duration = expiry.to_duration(value);
        thread::spawn(move || {
            thread::sleep(duration);
            BUCKET.write().unwrap().remove(&key);
        });
    }

    _stream.write(Response::Ok.value())
}

fn handle_ping(_stream: &mut TcpStream) -> Result<usize, std::io::Error> {
    _stream.write(Response::Pong.value())
}

fn encode_bulk_string(buf: &[u8]) -> Box<[u8]> {
    let len: u8 = buf.len() as u8 + b'0';

    [RespType::BulkString.token()]
        .iter()
        .chain(&[len])
        .chain(DELIMITER)
        .chain(buf)
        .chain(DELIMITER)
        .map(|&x| x)
        .collect()
}
