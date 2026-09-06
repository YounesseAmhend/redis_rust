#![allow(unused_imports, special_module_name)]
use std::{
    collections::HashMap,
    io::{Read, Write},
    net::{TcpListener, TcpStream},
    sync::{LazyLock, RwLock},
    thread,
};

use crate::lib::{DELIMITER, DELIMITER_LEN, Request, RespType, Response};
use const_map::const_map;
use std::env;
mod lib;

static BUCKET: LazyLock<RwLock<HashMap<String, String>>> =
    LazyLock::new(|| RwLock::new(HashMap::new()));

static DIR: RwLock<Option<Box<[u8]>>> = RwLock::new(None);
static DB_FILENAME: RwLock<Option<Box<[u8]>>> = RwLock::new(None);

fn main() {
    // You can use print statements as follows for debugging, they'll be visible when running tests.
    println!("Logs from your program will appear here!");

    let args: Box<[String]> = env::args().into_iter().collect();
    for (i, arg) in args.clone().into_iter().enumerate() {
        if arg == "--dir" {
            let mut dir = DIR.write().unwrap();
            *dir = Some(args[i + 1].to_owned().into_bytes().into_boxed_slice());
        }
        else if arg == "--dbfilename" {
            let mut db_filename = DB_FILENAME.write().unwrap();
            *db_filename = Some(args[i + 1].to_owned().into_bytes().into_boxed_slice());
        }
    }

    let listener = TcpListener::bind("127.0.0.1:6379").unwrap();

    for stream in listener.incoming() {
        thread::spawn(|| {
            handle_response(stream);
        });
    }
}

fn handle_response(stream: Result<std::net::TcpStream, std::io::Error>) {
    match stream {
        Ok(mut _stream) => {
            let mut buf: [u8; 512] = [0; 512];
            loop {
                match _stream.read(&mut buf) {
                    Ok(_) => {
                        let parts = split_parts(&buf);
                        let request = Request::from(parts[0]);
                        request.handle(&mut _stream, parts);
                    }
                    Err(_) => break,
                }
            }
            println!("accepted new connection");
        }
        Err(e) => {
            println!("error: {}", e);
        }
    }
}

fn split_parts<'a>(buf: &'a [u8; 512]) -> Box<[&'a [u8]]> {
    if buf[0] != RespType::Array.token() {
        panic!(
            "split_parts part is only used for arrays not for {}",
            buf[0]
        )
    }
    let mut index = 1 as u16;
    let len = buf[index as usize] - b'0';

    index += 1 + DELIMITER_LEN as u16;
    let mut parts: Vec<&[u8]> = Vec::with_capacity(len as usize);
    for _ in 0..len {
        if buf[index as usize] != RespType::BulkString.token() {
            break;
        }
        index += 1;
        let len = buf[index as usize] - b'0';
        index += 1 + DELIMITER_LEN as u16;
        parts.push(&buf[index as usize..len as usize + index as usize]);
        index += len as u16 + DELIMITER_LEN as u16;
    }
    parts.into_boxed_slice()
}
