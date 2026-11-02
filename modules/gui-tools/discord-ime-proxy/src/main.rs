//! 引数で指定されたプログラムを Wayland プロキシ経由で起動し、zwp_text_input_v3 の set_cursor_rectangle の値を SCALE 倍してコンポジタへ渡す。
//! Discord が倍率 2 倍の画面でキャレットの矩形を半分の値で送信し、IME の候補位置がずれる問題を補正する。

use std::{env, process::Command, rc::Rc};
use wl_proxy::{
    baseline::Baseline,
    object::{ConcreteObject, Object, ObjectCoreApi, ObjectRcUtils},
    protocols::{
        text_input_unstable_v3::{
            zwp_text_input_manager_v3::{ZwpTextInputManagerV3, ZwpTextInputManagerV3Handler},
            zwp_text_input_v3::{ZwpTextInputV3, ZwpTextInputV3Handler},
        },
        wayland::{
            wl_display::{WlDisplay, WlDisplayHandler},
            wl_registry::{WlRegistry, WlRegistryHandler},
            wl_seat::WlSeat,
        },
    },
    simple::{SimpleCommandExt, SimpleProxy},
};

// キャレット矩形に乗算する補正倍率。
// ponytail: 倍率を固定しているため、倍率の異なるモニターで使用する場合はウィンドウの倍率を追跡する。
const SCALE: i32 = 2;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let server = SimpleProxy::new(Baseline::ALL_OF_THEM).expect("create proxy");
    Command::new(&args[0])
        .args(&args[1..])
        .with_wayland_display(server.display())
        .spawn_and_forward_exit_code()
        .expect("spawn child");
    let err = server.run(|| Display);
    panic!("proxy terminated: {err}");
}

struct Display;
impl WlDisplayHandler for Display {
    fn handle_get_registry(&mut self, slf: &Rc<WlDisplay>, registry: &Rc<WlRegistry>) {
        registry.set_handler(Registry);
        slf.send_get_registry(registry);
    }
}

struct Registry;
impl WlRegistryHandler for Registry {
    fn handle_bind(&mut self, slf: &Rc<WlRegistry>, name: u32, id: Rc<dyn Object>) {
        if id.interface() == ZwpTextInputManagerV3::INTERFACE {
            id.clone().downcast::<ZwpTextInputManagerV3>().set_handler(Manager);
        }
        slf.send_bind(name, id);
    }
}

struct Manager;
impl ZwpTextInputManagerV3Handler for Manager {
    fn handle_get_text_input(
        &mut self,
        slf: &Rc<ZwpTextInputManagerV3>,
        id: &Rc<ZwpTextInputV3>,
        seat: &Rc<WlSeat>,
    ) {
        id.set_handler(TextInput);
        slf.send_get_text_input(id, seat);
    }
}

struct TextInput;
impl ZwpTextInputV3Handler for TextInput {
    fn handle_set_cursor_rectangle(
        &mut self,
        slf: &Rc<ZwpTextInputV3>,
        x: i32,
        y: i32,
        width: i32,
        height: i32,
    ) {
        slf.send_set_cursor_rectangle(x * SCALE, y * SCALE, width * SCALE, height * SCALE);
    }
}
